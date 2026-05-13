/**
 * GönüllüNet - Firebase Cloud Functions
 *
 * ── Auth Functions ────────────────────────────────────────────────────────────
 * registerUser       : E-posta/şifre ile yeni kullanıcı kaydı.
 *                      Admin SDK ile kullanıcı oluşturur, Firestore profilini
 *                      yazar ve e-posta doğrulama linki gönderir.
 *
 * createUserProfile  : Google Sign-In sonrası Firestore profili oluşturur.
 *                      Idempotent — zaten varsa hiçbir şey yazmaz.
 *
 * deleteUserAccount  : Kullanıcının kendi hesabını silmesi (callable).
 *                      Firestore profilini ve Auth kaydını siler.
 *
 * ── Auth Trigger Functions ───────────────────────────────────────────────────
 * onUserDeleted      : Firebase Auth'dan herhangi bir yolla (Console, Admin SDK,
 *                      vb.) kullanıcı silindiğinde otomatik tetiklenir.
 *                      Kullanıcının Firestore profili ve tüm postları silinir.
 *
 * ── Firestore Trigger Functions ──────────────────────────────────────────────
 * onEventCreated     : Yeni etkinlik Firestore'a eklendiğinde çalışır.
 *                      Kurumun tüm takipçilerine in-app + FCM push bildirim gönderir.
 *
 * onApplicationStatusUpdated: Başvuru durumu (status) değiştiğinde çalışır.
 *                      Gönüllüye başvurusunun onaylandığını veya reddedildiğini bildirir.
 */

const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { auth } = require("firebase-functions/v1");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { getAuth } = require("firebase-admin/auth");
const { getRemoteConfig } = require("firebase-admin/remote-config");
const { VertexAI } = require("@google-cloud/vertexai");

initializeApp();

// ─────────────────────────────────────────────────────────────────────────────
// registerUser
// İstemci Gönderir : { email, password, userType, name?, surname?, stkName? }
// Ne Yapar         : Admin SDK ile Firebase Auth kullanıcısı oluşturur,
//                    Firestore'a profil yazar, e-posta doğrulama linki
//                    oluşturup kullanıcıya gönderir.
// Döndürür         : { uid }
// ─────────────────────────────────────────────────────────────────────────────
exports.registerUser = onCall(async (request) => {
  const { email, password, userType, name, surname, stkName } = request.data;

  // ── Girdi Doğrulama ──────────────────────────────────────────────
  if (!email || !password || !userType) {
    throw new HttpsError(
      "invalid-argument",
      "E-posta, şifre ve kullanıcı türü zorunludur."
    );
  }

  if (!["volunteer", "ngo"].includes(userType)) {
    throw new HttpsError("invalid-argument", "Geçersiz kullanıcı türü.");
  }

  if (userType === "ngo" && !stkName) {
    throw new HttpsError("invalid-argument", "STK adı zorunludur.");
  }

  if (userType === "volunteer" && (!name || !surname)) {
    throw new HttpsError("invalid-argument", "Ad ve soyad zorunludur.");
  }

  const db = getFirestore();
  const adminAuth = getAuth();

  // ── Kullanıcı Oluştur ────────────────────────────────────────────
  let userRecord;
  try {
    userRecord = await adminAuth.createUser({
      email,
      password,
      displayName: userType === "ngo" ? stkName : `${name} ${surname}`,
      emailVerified: false,
    });
  } catch (err) {
    console.error("Auth kullanıcısı oluşturma hatası:", err);

    // Firebase Auth hata kodlarını anlamlı mesajlara çevir
    if (err.code === "auth/email-already-exists") {
      throw new HttpsError("already-exists", "Bu e-posta adresi zaten kayıtlı.");
    }
    if (err.code === "auth/invalid-password") {
      throw new HttpsError(
        "invalid-argument",
        "Şifre en az 6 karakter olmalıdır."
      );
    }
    throw new HttpsError("internal", "Kullanıcı oluşturulamadı: " + err.message);
  }

  const uid = userRecord.uid;

  // ── Firestore Profil Yaz ─────────────────────────────────────────
  const profileData = {
    uid,
    email,
    userType,
    createdAt: FieldValue.serverTimestamp(),
    imageUrl: "",
    following: [],
    followers: [],
    followersCount: 0,
    xp: 0,
  };

  if (userType === "ngo") {
    profileData.stkName = stkName;
    profileData.description = "";
    profileData.location = "";
  } else {
    profileData.name = name;
    profileData.surname = surname;
  }

  try {
    await db.collection("users").doc(uid).set(profileData);
  } catch (err) {
    // Firestore yazma başarısız olursa oluşturulan Auth kullanıcısını temizle
    console.error("Firestore profil yazma hatası, Auth kullanıcısı siliniyor:", err);
    await adminAuth.deleteUser(uid).catch(() => {});
    throw new HttpsError("internal", "Profil oluşturulamadı: " + err.message);
  }

  // ── E-posta Doğrulama ────────────────────────────────────────────────
  // Not: Doğrulama e-postası istemci tarafında (Firebase Auth SDK)
  // user.sendEmailVerification() ile gönderilir.
  // Admin SDK'nın generateEmailVerificationLink() fonksiyonu yalnızca
  // link üretir; e-posta göndermez. Bu nedenle gönderim istemciye bırakılmıştır.

  console.log(`[registerUser] Kayıt tamamlandı: ${uid} (${userType})`);
  return { uid };
});

// ─────────────────────────────────────────────────────────────────────────────
// createUserProfile
// Tetikleyici  : Google Sign-In sonrası istemci çağırır (onCall, kimlik doğrulamalı)
// İstemci Gönderir : { userType, displayName?, photoUrl? }
// Ne Yapar     : Firestore'da profil yoksa oluşturur (idempotent).
// Döndürür     : { created: bool } — true: yeni oluşturuldu, false: zaten vardı
// ─────────────────────────────────────────────────────────────────────────────
exports.createUserProfile = onCall(async (request) => {
  // ── Auth Kontrolü ────────────────────────────────────────────────
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Bu işlem için giriş yapmalısınız."
    );
  }

  const uid = request.auth.uid;
  const { userType, displayName, photoUrl } = request.data;

  if (!userType || !["volunteer", "ngo"].includes(userType)) {
    throw new HttpsError("invalid-argument", "Geçerli bir kullanıcı türü gereklidir.");
  }

  const db = getFirestore();
  const userRef = db.collection("users").doc(uid);

  // ── Mevcut Profil Kontrolü (Idempotent) ──────────────────────────
  const existing = await userRef.get();
  if (existing.exists) {
    console.log(`[createUserProfile] Profil zaten mevcut: ${uid}`);
    return { created: false };
  }

  // ── Ad/Soyad Ayrıştır ────────────────────────────────────────────
  let name = "";
  let surname = "";
  if (displayName) {
    const parts = displayName.split(" ");
    if (parts.length > 1) {
      surname = parts.pop();
      name = parts.join(" ");
    } else {
      name = displayName;
    }
  }

  // ── Profil Oluştur ───────────────────────────────────────────────
  const profileData = {
    uid,
    email: request.auth.token.email || "",
    userType,
    createdAt: FieldValue.serverTimestamp(),
    imageUrl: photoUrl || "",
    following: [],
    followers: [],
    followersCount: 0,
    xp: 0,
  };

  if (userType === "ngo") {
    profileData.stkName = name || "İsimsiz Kurum";
    profileData.description = "";
    profileData.location = "";
  } else {
    profileData.name = name;
    profileData.surname = surname;
  }

  await userRef.set(profileData);
  console.log(`[createUserProfile] Yeni profil oluşturuldu: ${uid} (${userType})`);

  return { created: true };
});

exports.onEventCreated = onDocumentCreated(
  "events/{eventId}",
  async (event) => {
    const db = getFirestore();
    const messaging = getMessaging();

    const snap = event.data;
    if (!snap) return;

    const eventData = snap.data();
    const eventId = event.params.eventId;

    const organizerId = eventData.organizerId;
    const eventTitle = eventData.title || "Yeni Etkinlik";
    const eventType = eventData.type || "Etkinlik";

    if (!organizerId) {
      console.log("organizerId bulunamadı, atlanıyor.");
      return;
    }

    // 1. Kurumun adını ve takipçi listesini al
    const ngoDoc = await db.collection("users").doc(organizerId).get();
    if (!ngoDoc.exists) {
      console.log(`NGO dokümanı bulunamadı: ${organizerId}`);
      return;
    }

    const ngoData = ngoDoc.data();
    const organizerName =
      ngoData.stkName || ngoData.name || "İsimsiz Kurum";
    const followerIds = ngoData.followers || [];

    if (followerIds.length === 0) {
      console.log("Takipçi yok, bildirim gönderilmedi.");
      return;
    }

    const notifTitle = `🎉 Yeni ${eventType}: ${eventTitle}`;
    const notifBody = `${organizerName} yeni bir ${eventType} yayınladı!`;

    console.log(
      `${followerIds.length} takipçiye bildirim gönderiliyor: "${notifTitle}"`
    );

    // 2. Her takipçi için işlem yap
    const promises = followerIds.map(async (followerId) => {
      try {
        // 2a. Firestore in-app bildirim yaz
        await db
          .collection("users")
          .doc(followerId)
          .collection("notifications")
          .add({
            title: notifTitle,
            body: notifBody,
            type: "new_event",
            relatedId: eventId,
            isRead: false,
            createdAt: FieldValue.serverTimestamp(),
          });

        // 2b. FCM push bildirim gönder (token varsa)
        const followerDoc = await db
          .collection("users")
          .doc(followerId)
          .get();
        if (!followerDoc.exists) return;

        const fcmToken = followerDoc.data().fcmToken;
        if (!fcmToken) return;

        await messaging.send({
          token: fcmToken,
          notification: {
            title: notifTitle,
            body: notifBody,
          },
          android: {
            priority: "high",
            notification: {
              sound: "default",
              channelId: "high_importance_channel",
            },
          },
          apns: {
            payload: {
              aps: { sound: "default" },
            },
          },
          data: {
            type: "new_event",
            relatedId: eventId,
          },
        });
      } catch (err) {
        console.error(`Takipçi ${followerId} için bildirim hatası:`, err);
      }
    });

    await Promise.all(promises);
    console.log("Tüm bildirimler gönderildi.");
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// onApplicationStatusUpdated
// Tetikleyici: events/{eventId}/applications/{userId} dokümanı güncellendiğinde
// Ne Yapar  : status alanı değiştiğinde (pending → approved / rejected)
//             gönüllüye Firestore in-app bildirim + FCM push bildirim gönderir.
// ─────────────────────────────────────────────────────────────────────────────
exports.onApplicationStatusUpdated = onDocumentUpdated(
  "events/{eventId}/applications/{userId}",
  async (event) => {
    const db = getFirestore();
    const messaging = getMessaging();

    const before = event.data.before.data();
    const after = event.data.after.data();

    // Durum değişmemişse işlem yapma
    if (before.status === after.status) {
      console.log("Status değişmedi, atlanıyor.");
      return;
    }

    const newStatus = after.status;

    // Yalnızca anlamlı geçişlerde bildirim gönder
    if (newStatus !== "approved" && newStatus !== "rejected") {
      console.log(`Bildirim gönderilmeyecek durum: ${newStatus}`);
      return;
    }

    const { eventId, userId } = event.params;

    // 1. Etkinlik adını al
    const eventDoc = await db.collection("events").doc(eventId).get();
    const eventTitle = eventDoc.exists
      ? eventDoc.data().title || "Etkinlik"
      : "Etkinlik";

    // 2. Kullanıcı FCM token'ını al
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      console.log(`Kullanıcı dokümanı bulunamadı: ${userId}`);
      return;
    }
    const fcmToken = userDoc.data().fcmToken;

    // 3. Bildirim metnini oluştur
    const isApproved = newStatus === "approved";
    const notifTitle = isApproved
      ? "✅ Başvurunuz Onaylandı!"
      : "❌ Başvurunuz Reddedildi";
    const notifBody = isApproved
      ? `"${eventTitle}" etkinliğine başvurunuz kabul edildi. İyi gönüllülükler!`
      : `"${eventTitle}" etkinliğine başvurunuz maalesef reddedildi.`;

    console.log(
      `Kullanıcı ${userId} için bildirim hazırlanıyor: "${notifTitle}"`
    );

    // 4. Firestore in-app bildirim yaz
    try {
      await db
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .add({
          title: notifTitle,
          body: notifBody,
          type: isApproved ? "application_approved" : "application_rejected",
          relatedId: eventId,
          isRead: false,
          createdAt: FieldValue.serverTimestamp(),
        });
      console.log(`In-app bildirim yazıldı: ${userId}`);
    } catch (err) {
      console.error("In-app bildirim yazma hatası:", err);
    }

    // 5. FCM push bildirim gönder (token varsa)
    if (!fcmToken) {
      console.log(`FCM token bulunamadı, push atlanıyor: ${userId}`);
      return;
    }

    try {
      await messaging.send({
        token: fcmToken,
        notification: {
          title: notifTitle,
          body: notifBody,
        },
        android: {
          priority: "high",
          notification: {
            sound: "default",
            channelId: "high_importance_channel",
          },
        },
        apns: {
          payload: {
            aps: { sound: "default" },
          },
        },
        data: {
          type: isApproved ? "application_approved" : "application_rejected",
          relatedId: eventId,
        },
      });
      console.log(`FCM push bildirimi gönderildi: ${userId}`);
    } catch (err) {
      console.error(`FCM push hatası (${userId}):`, err);
    }
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// getChatResponse
// GönüllüNet AI Asistanı için server-side logic ve günlük limit
// ─────────────────────────────────────────────────────────────────────────────

const AI_DAILY_LIMIT = 20;
const PROJECT_ID = "gonullunet-863c5";
const vertexAI = new VertexAI({ project: PROJECT_ID, location: "us-central1" });

exports.getChatResponse = onCall(async (request) => {
  // 1. Auth Kontrolü
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { content, history } = request.data;

  if (!content) {
    throw new HttpsError("invalid-argument", "Mesaj içeriği boş olamaz.");
  }

  const db = getFirestore();
  const today = new Date().toISOString().split("T")[0]; // YYYY-MM-DD
  const usageRef = db.collection("users").doc(uid).collection("ai_usage").doc(today);

  // 2. Günlük Limit Kontrolü
  const usageDoc = await usageRef.get();
  let count = 0;
  if (usageDoc.exists) {
    count = usageDoc.data().count || 0;
  }

  if (count >= AI_DAILY_LIMIT) {
    throw new HttpsError(
      "resource-exhausted",
      `Günlük ${AI_DAILY_LIMIT} soru limitine ulaştınız. Yarın tekrar bekleriz! 🚀`
    );
  }

  // 3. AI İşlemi
  try {
    // Remote Config'den model ve talimatları çek
    const remoteConfig = getRemoteConfig();
    const template = await remoteConfig.getTemplate();
    
    const modelName = template.parameters["ai_model_name"]?.defaultValue?.value || "gemini-1.5-flash";
    const systemInstructionText = template.parameters["ai_system_instruction"]?.defaultValue?.value || 
      'Sen GönüllüNet dijital gençlik çalışanı asistanısın. '
      'Sadece Avrupa Birliği projeleri, gönüllülük, sivil toplum kuruluşları (STK), '
      'sosyal sorumluluk projeleri ve Erasmus+ hakkında bilgi verirsin. '
      'Bu konular dışındaki sorulara nazikçe cevap veremeyeceğini belirtirsin '
      've kullanıcıyı Türkiye Ulusal Ajansı\'nın resmi web sitesine (www.ua.gov.tr) yönlendirirsin. '
      'Kullanıcılardan TC Kimlik No, pasaport numarası gibi kişisel veriler talep etme. '
      'Her zaman nazik, profesyonel ve teşvik edici ol. '
      'Cevaplarını kısa ve öz tut. En fazla 3-4 paragraf ile yanıt ver.';

    console.log(`[AI] Model: ${modelName}, User: ${uid}, Today Count: ${count}`);

    const model = vertexAI.getGenerativeModel({
      model: modelName,
      systemInstruction: {
        role: "system",
        parts: [{ text: systemInstructionText }],
      },
    });

    const chat = model.startChat({
      history: (history || []).map((msg) => ({
        role: msg.role === "user" ? "user" : "model",
        parts: [{ text: msg.content }],
      })),
    });

    const result = await chat.sendMessage(content);
    const responseText =
      result.response.candidates[0].content.parts[0].text ||
      "Üzgünüm, bir yanıt oluşturamadım.";

    // 4. Kullanım Sayacını Artır
    await usageRef.set(
      {
        count: FieldValue.increment(1),
        lastUsed: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return { response: responseText };
  } catch (error) {
    console.error("AI Error Detailed:", error);
    
    // Vertex AI / Google Cloud Kotası dolduğunda (429)
    if (error.message?.includes("429") || error.status === 429 || error.code === 8) {
      throw new HttpsError(
        "resource-exhausted",
        "Şu an çok fazla istek alıyorum. Lütfen 1 dakika bekleyip tekrar deneyin. ⏳"
      );
    }

    throw new HttpsError("internal", "Yapay zeka yanıtı oluştururken bir hata oluştu: " + error.message);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// createPost
// İstemci Gönderir : { title, description, imageUrl }
// Ne Yapar         : Gönüllüler için günde 1 post limiti kontrolü yapar,
//                    Firestore'a postu yazar ve XP ödülü verir.
// ─────────────────────────────────────────────────────────────────────────────
exports.createPost = onCall(async (request) => {
  // 1. Auth Kontrolü
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { title, description, imageUrl } = request.data;

  if (!title || !description) {
    throw new HttpsError("invalid-argument", "Başlık ve açıklama zorunludur.");
  }

  const db = getFirestore();

  // 2. Kullanıcı Türü ve Limit Kontrolü
  const userDoc = await db.collection("users").doc(uid).get();
  if (!userDoc.exists) {
    throw new HttpsError("not-found", "Kullanıcı profili bulunamadı.");
  }

  const userData = userDoc.data();
  const isVolunteer = userData.userType === "volunteer";

  if (isVolunteer) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Bugün paylaşılan postları say
    const postsToday = await db.collection("posts")
      .where("publisherId", "==", uid)
      .where("createdAt", ">=", today)
      .limit(1)
      .get();

    if (!postsToday.empty) {
      throw new HttpsError(
        "resource-exhausted",
        "Günde sadece 1 gönderi paylaşabilirsiniz. Yarın tekrar bekleriz! ✨"
      );
    }
  }

  // 3. Postu Oluştur
  const batch = db.batch();
  const postRef = db.collection("posts").doc();

  batch.set(postRef, {
    title,
    description,
    imageUrl: imageUrl || "",
    publisherId: uid,
    publisherType: isVolunteer ? "volunteer" : "ngo",
    createdAt: FieldValue.serverTimestamp(),
    likeCount: 0,
    commentCount: 0,
  });

  // Paylaşım için 10 XP ödülü (zaten repository'de vardı, CF'e taşıdık)
  const userRef = db.collection("users").doc(uid);
  batch.update(userRef, {
    xp: FieldValue.increment(10),
  });

  try {
    await batch.commit();
    console.log(`[createPost] Yeni gönderi oluşturuldu: ${postRef.id} (User: ${uid})`);
    return { postId: postRef.id };
  } catch (err) {
    console.error("Post oluşturma hatası:", err);
    throw new HttpsError("internal", "Gönderi paylaşılamadı: " + err.message);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// deleteUserAccount
// İstemci Gönderir : {}
// Ne Yapar         : Kullanıcının Firestore profilini ve Auth kaydını siler.
// ─────────────────────────────────────────────────────────────────────────────
exports.deleteUserAccount = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const db = getFirestore();
  const adminAuth = getAuth();

  try {
    // 1. Firestore Profilini Sil
    await db.collection("users").doc(uid).delete();
    
    // 2. Auth Kaydını Sil
    await adminAuth.deleteUser(uid);

    console.log(`[deleteUserAccount] Kullanıcı başarıyla silindi: ${uid}`);
    return { success: true };
  } catch (err) {
    console.error("Hesap silme hatası:", err);
    throw new HttpsError("internal", "Hesap silinirken bir hata oluştu: " + err.message);
  }
});

// ─── AUTH SİLME TRIGGER ────────────────────────────────────────────────────
// Firebase Console, Admin SDK veya herhangi bir yerden kullanıcı silinince
// Firestore'daki tüm ilgili verileri otomatik olarak temizler.
exports.onUserDeleted = auth.user().onDelete(async (user) => {
  const uid = user.uid;
  const db = getFirestore();

  console.log(`[onUserDeleted] Kullanıcı silindi, veriler temizleniyor: ${uid}`);

  try {
    // 1. Kullanıcı profilini sil
    await db.collection("users").doc(uid).delete();
    console.log(`[onUserDeleted] Firestore profili silindi: ${uid}`);

    // 2. Kullanıcının postlarını sil
    const postsSnap = await db
      .collection("posts")
      .where("publisherId", "==", uid)
      .get();

    const postDeletes = postsSnap.docs.map((doc) => doc.ref.delete());
    await Promise.all(postDeletes);
    console.log(`[onUserDeleted] ${postsSnap.size} post silindi.`);

    // 3. Kullanıcının etkinliklerini sil (NGO ise)
    const eventsSnap = await db
      .collection("events")
      .where("organizerId", "==", uid)
      .get();

    const eventDeletes = eventsSnap.docs.map((doc) => doc.ref.delete());
    await Promise.all(eventDeletes);
    console.log(`[onUserDeleted] ${eventsSnap.size} etkinlik silindi.`);

    // 4. Kullanıcının başvurularını sil
    const appsSnap = await db
      .collection("applications")
      .where("applicantId", "==", uid)
      .get();

    const appDeletes = appsSnap.docs.map((doc) => doc.ref.delete());
    await Promise.all(appDeletes);
    console.log(`[onUserDeleted] ${appsSnap.size} başvuru silindi.`);

    console.log(`[onUserDeleted] Tüm veriler başarıyla temizlendi: ${uid}`);
  } catch (err) {
    console.error(`[onUserDeleted] Veri temizleme hatası (${uid}):`, err);
    // Trigger'da throw edilmemeli — sadece log yeterli
  }
});
