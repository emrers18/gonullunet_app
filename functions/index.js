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
 *
 * ── Event Functions ──────────────────────────────────────────────────────────
 * createEvent        : NGO kontrolü + Firestore etkinlik oluşturma.
 *                      Sadece NGO kullanıcıları etkinlik oluşturabilir.
 *
 * updateApplicationStatus: Başvuru durumu güncelleme + XP ödülü.
 *                      Organizatör kontrolü yapılır; XP sunucu tarafında verilir.
 *
 * toggleJoinEvent    : Etkinliğe katılma/ayrılma + XP güvenliği.
 *                      Pending başvuru, onaylı katılım ve iptal mantığı sunucuda.
 *
 * ── Social Functions ─────────────────────────────────────────────────────────
 * toggleFollowNgo    : NGO takip/takipten çıkma + followersCount sayacı.
 *
 * toggleLikePost     : Post beğeni toggle + likeCount sayacı.
 *
 * deletePost         : Sahiplik kontrolü + Firestore silme + Storage temizleme.
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
const { getStorage } = require("firebase-admin/storage");

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

    // 2. Tüm takipçi dokümanlarını paralel oku (N+1 yerine tek batch)
    const followerDocs = await Promise.all(
      followerIds.map((id) => db.collection("users").doc(id).get())
    );

    // 3. In-app bildirimlerini paralel yaz
    const notifPromises = followerIds.map((followerId) =>
      db
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
        })
        .catch((err) =>
          console.error(`In-app bildirim hatası (${followerId}):`, err)
        )
    );
    await Promise.all(notifPromises);

    // 4. FCM token'larını topla ve toplu gönder (sendEachForMulticast)
    const tokens = followerDocs
      .filter((doc) => doc.exists && doc.data().fcmToken)
      .map((doc) => doc.data().fcmToken);

    if (tokens.length === 0) {
      console.log("FCM token'ı olan takipçi yok, push atlanıyor.");
      return;
    }

    // FCM multicast limiti 500 — gruplar halinde gönder
    const FCM_BATCH_SIZE = 500;
    for (let i = 0; i < tokens.length; i += FCM_BATCH_SIZE) {
      const batch = tokens.slice(i, i + FCM_BATCH_SIZE);
      try {
        const response = await messaging.sendEachForMulticast({
          tokens: batch,
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
        console.log(
          `FCM batch (${batch.length}): ${response.successCount} başarılı, ${response.failureCount} başarısız`
        );
      } catch (err) {
        console.error(`FCM batch gönderim hatası:`, err);
      }
    }

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

// Remote Config cache — her istekte getTemplate() çağırmamak için
let _cachedAiConfig = null;
let _aiConfigLastFetch = 0;
const AI_CONFIG_TTL = 5 * 60 * 1000; // 5 dakika

async function getAiConfig() {
  const now = Date.now();
  if (_cachedAiConfig && now - _aiConfigLastFetch < AI_CONFIG_TTL) {
    return _cachedAiConfig;
  }
  try {
    const remoteConfig = getRemoteConfig();
    const template = await remoteConfig.getTemplate();
    _cachedAiConfig = {
      modelName:
        template.parameters["ai_model_name"]?.defaultValue?.value ||
        "gemini-1.5-flash",
      systemInstructionText:
        template.parameters["ai_system_instruction"]?.defaultValue?.value ||
        "Sen GönüllüNet dijital gençlik çalışanı asistanısın. " +
          "Sadece Avrupa Birliği projeleri, gönüllülük, sivil toplum kuruluşları (STK), " +
          "sosyal sorumluluk projeleri ve Erasmus+ hakkında bilgi verirsin. " +
          "Bu konular dışındaki sorulara nazikçe cevap veremeyeceğini belirtirsin " +
          "ve kullanıcıyı Türkiye Ulusal Ajansı'nın resmi web sitesine (www.ua.gov.tr) yönlendirirsin. " +
          "Kullanıcılardan TC Kimlik No, pasaport numarası gibi kişisel veriler talep etme. " +
          "Her zaman nazik, profesyonel ve teşvik edici ol. " +
          "Cevaplarını kısa ve öz tut. En fazla 3-4 paragraf ile yanıt ver.",
    };
    _aiConfigLastFetch = now;
  } catch (err) {
    console.warn("[getAiConfig] Remote Config çekilemedi, varsayılan kullanılıyor:", err.message);
    if (!_cachedAiConfig) {
      _cachedAiConfig = {
        modelName: "gemini-1.5-flash",
        systemInstructionText:
          "Sen GönüllüNet dijital gençlik çalışanı asistanısın. " +
          "Sadece Avrupa Birliği projeleri, gönüllülük, STK ve Erasmus+ hakkında bilgi verirsin.",
      };
    }
  }
  return _cachedAiConfig;
}

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
    // Remote Config'den model ve talimatları çek (cache'li)
    const aiConfig = await getAiConfig();
    const { modelName, systemInstructionText } = aiConfig;

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
// Ne Yapar         : Sadece STK hesaplarının paylaşım yapmasına izin verir,
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

  // 2. Kullanıcı Türü Kontrolü — sadece STK'lar paylaşım yapabilir
  const userDoc = await db.collection("users").doc(uid).get();
  if (!userDoc.exists) {
    throw new HttpsError("not-found", "Kullanıcı profili bulunamadı.");
  }

  const userData = userDoc.data();

  if (userData.userType !== "ngo") {
    throw new HttpsError(
      "permission-denied",
      "Sadece STK hesapları gönderi paylaşabilir."
    );
  }

  // 3. Postu Oluştur
  const batch = db.batch();
  const postRef = db.collection("posts").doc();

  batch.set(postRef, {
    title,
    description,
    imageUrl: imageUrl || "",
    publisherId: uid,
    publisherType: "ngo",
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
    // 1. Kullanıcının postlarını sil
    const postsSnap = await db.collection("posts").where("publisherId", "==", uid).get();
    for (const postDoc of postsSnap.docs) {
      // Post beğenilerini sil
      const postLikesSnap = await db.collection("post_likes")
        .where("postId", "==", postDoc.id).get();
      const likeBatch = db.batch();
      postLikesSnap.docs.forEach((d) => likeBatch.delete(d.ref));
      await likeBatch.commit();

      // Post yorumlarını sil
      const commentsSnap = await postDoc.ref.collection("comments").get();
      const commentBatch = db.batch();
      commentsSnap.docs.forEach((d) => commentBatch.delete(d.ref));
      await commentBatch.commit();

      // Storage görselini sil
      const imageUrl = postDoc.data().imageUrl;
      if (imageUrl && imageUrl.includes("firebasestorage.googleapis.com")) {
        try {
          const storage = getStorage();
          const urlPath = decodeURIComponent(imageUrl.split("/o/")[1].split("?")[0]);
          await storage.bucket().file(urlPath).delete();
        } catch (e) { /* sessiz */ }
      }

      await postDoc.ref.delete();
    }

    // 2. Kullanıcının etkinliklerini sil (NGO ise)
    const eventsSnap = await db.collection("events").where("organizerId", "==", uid).get();
    for (const eventDoc of eventsSnap.docs) {
      const appsSnap = await eventDoc.ref.collection("applications").get();
      const appBatch = db.batch();
      appsSnap.docs.forEach((d) => appBatch.delete(d.ref));
      await appBatch.commit();

      const chatSnap = await eventDoc.ref.collection("chat").get();
      const chatBatch = db.batch();
      chatSnap.docs.forEach((d) => chatBatch.delete(d.ref));
      await chatBatch.commit();

      await eventDoc.ref.delete();
    }

    // 3. Kullanıcının beğenilerini sil
    const likesSnap = await db.collection("post_likes").where("userId", "==", uid).get();
    const likesBatch = db.batch();
    likesSnap.docs.forEach((d) => likesBatch.delete(d.ref));
    await likesBatch.commit();

    // 4. Subcollection'ları sil (notifications, ai_usage, chat_sessions)
    await _deleteSubcollections(db, uid);

    // 5. Firestore Profilini Sil
    await db.collection("users").doc(uid).delete();
    
    // 6. Auth Kaydını Sil
    await adminAuth.deleteUser(uid);

    console.log(`[deleteUserAccount] Kullanıcı ve tüm verileri başarıyla silindi: ${uid}`);
    return { success: true };
  } catch (err) {
    console.error("Hesap silme hatası:", err);
    throw new HttpsError("internal", "Hesap silinirken bir hata oluştu: " + err.message);
  }
});

// ─── AUTH SİLME TRIGGER ────────────────────────────────────────────────────
// Firebase Console, Admin SDK veya herhangi bir yerden kullanıcı silinince
// Firestore'daki tüm ilgili verileri otomatik olarak temizler.
// ── Yardımcı: Kullanıcı subcollection'larını sil ──────────────────────────
async function _deleteSubcollections(db, uid) {
  // Bildirimleri sil
  const notifSnap = await db.collection("users").doc(uid).collection("notifications").get();
  if (notifSnap.size > 0) {
    const notifBatch = db.batch();
    notifSnap.docs.forEach((d) => notifBatch.delete(d.ref));
    await notifBatch.commit();
    console.log(`[cleanup] ${notifSnap.size} bildirim silindi: ${uid}`);
  }

  // AI kullanım kayıtlarını sil
  const aiSnap = await db.collection("users").doc(uid).collection("ai_usage").get();
  if (aiSnap.size > 0) {
    const aiBatch = db.batch();
    aiSnap.docs.forEach((d) => aiBatch.delete(d.ref));
    await aiBatch.commit();
    console.log(`[cleanup] ${aiSnap.size} AI kullanım kaydı silindi: ${uid}`);
  }

  // Chat oturumlarını ve mesajlarını sil
  const sessionsSnap = await db.collection("users").doc(uid).collection("chat_sessions").get();
  for (const session of sessionsSnap.docs) {
    const msgsSnap = await session.ref.collection("messages").get();
    if (msgsSnap.size > 0) {
      const msgBatch = db.batch();
      msgsSnap.docs.forEach((d) => msgBatch.delete(d.ref));
      await msgBatch.commit();
    }
    await session.ref.delete();
  }
  if (sessionsSnap.size > 0) {
    console.log(`[cleanup] ${sessionsSnap.size} chat oturumu silindi: ${uid}`);
  }
}

exports.onUserDeleted = auth.user().onDelete(async (user) => {
  const uid = user.uid;
  const db = getFirestore();

  console.log(`[onUserDeleted] Kullanıcı silindi, veriler temizleniyor: ${uid}`);

  try {
    // 1. Subcollection'ları sil (notifications, ai_usage, chat_sessions)
    await _deleteSubcollections(db, uid);

    // 2. Kullanıcı profilini sil
    await db.collection("users").doc(uid).delete();
    console.log(`[onUserDeleted] Firestore profili silindi: ${uid}`);

    // 3. Kullanıcının postlarını sil
    const postsSnap = await db
      .collection("posts")
      .where("publisherId", "==", uid)
      .get();

    const postDeletes = postsSnap.docs.map((doc) => doc.ref.delete());
    await Promise.all(postDeletes);
    console.log(`[onUserDeleted] ${postsSnap.size} post silindi.`);

    // 4. Kullanıcının etkinliklerini sil (NGO ise)
    const eventsSnap = await db
      .collection("events")
      .where("organizerId", "==", uid)
      .get();

    const eventDeletes = eventsSnap.docs.map((doc) => doc.ref.delete());
    await Promise.all(eventDeletes);
    console.log(`[onUserDeleted] ${eventsSnap.size} etkinlik silindi.`);

    // 5. Kullanıcının beğenilerini sil
    const likesSnap = await db
      .collection("post_likes")
      .where("userId", "==", uid)
      .get();

    if (likesSnap.size > 0) {
      const likesBatch = db.batch();
      likesSnap.docs.forEach((d) => likesBatch.delete(d.ref));
      await likesBatch.commit();
      console.log(`[onUserDeleted] ${likesSnap.size} beğeni silindi.`);
    }

    console.log(`[onUserDeleted] Tüm veriler başarıyla temizlendi: ${uid}`);
  } catch (err) {
    console.error(`[onUserDeleted] Veri temizleme hatası (${uid}):`, err);
    // Trigger'da throw edilmemeli — sadece log yeterli
  }
});

// =============================================================================
// ── EVENT FUNCTIONS ───────────────────────────────────────────────────────────
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// createEvent
// İstemci Gönderir : { title, description, location, geoPoint: {lat, lng},
//                      startDate (ISO), endDate (ISO), category, type,
//                      imageUrl?, quota? }
// Ne Yapar         : Yalnızca NGO kullanıcılarının etkinlik oluşturmasına izin
//                    verir; Firestore'a etkinliği yazar.
// Döndürür         : { eventId }
// ─────────────────────────────────────────────────────────────────────────────
exports.createEvent = onCall(async (request) => {
  // 1. Auth Kontrolü
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const {
    title, description, location, geoPoint,
    startDate, endDate, category, type, imageUrl, quota, lastApplyDate
  } = request.data;

  // 2. Girdi Doğrulama
  if (!title || !description || !location || !geoPoint || !startDate || !endDate || !category || !type) {
    throw new HttpsError("invalid-argument", "Zorunlu alanlar eksik.");
  }

  const db = getFirestore();

  // 3. NGO Kontrolü
  const userDoc = await db.collection("users").doc(uid).get();
  if (!userDoc.exists) {
    throw new HttpsError("not-found", "Kullanıcı profili bulunamadı.");
  }

  const userData = userDoc.data();
  if (userData.userType !== "ngo") {
    throw new HttpsError("permission-denied", "Etkinlik yalnızca STK hesapları tarafından oluşturulabilir.");
  }

  // 4. Firestore'a Yaz
  try {
    const { GeoPoint, Timestamp } = require("firebase-admin/firestore");

    const eventData = {
      title,
      description,
      location,
      geoPoint: new GeoPoint(geoPoint.lat, geoPoint.lng),
      startDate: Timestamp.fromDate(new Date(startDate)),
      endDate: Timestamp.fromDate(new Date(endDate)),
      imageUrl: imageUrl || "",
      category,
      type,
      organizerId: uid,
      createdAt: FieldValue.serverTimestamp(),
      participants: [],
      approved_volunteers: [uid],
      active: true,
      isProject: type === "Proje",
    };

    if (quota !== undefined && quota !== null) {
      eventData.quota = quota;
    }

    if (lastApplyDate !== undefined && lastApplyDate !== null) {
      eventData.lastApplyDate = Timestamp.fromDate(new Date(lastApplyDate));
    }

    const eventRef = await db.collection("events").add(eventData);
    console.log(`[createEvent] Etkinlik oluşturuldu: ${eventRef.id} (NGO: ${uid})`);
    return { eventId: eventRef.id };
  } catch (err) {
    console.error("[createEvent] Hata:", err);
    throw new HttpsError("internal", "Etkinlik oluşturulamadı: " + err.message);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// updateApplicationStatus
// İstemci Gönderir : { eventId, targetUserId, newStatus }
// Ne Yapar         : Organizatör kontrolü yapar; başvuru durumunu günceller
//                    ve XP ödülü/cezası sunucu tarafında uygular.
// ─────────────────────────────────────────────────────────────────────────────
exports.updateApplicationStatus = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { eventId, targetUserId, newStatus } = request.data;

  if (!eventId || !targetUserId || !newStatus) {
    throw new HttpsError("invalid-argument", "eventId, targetUserId ve newStatus zorunludur.");
  }

  const validStatuses = ["pending", "approved", "rejected"];
  if (!validStatuses.includes(newStatus)) {
    throw new HttpsError("invalid-argument", `Geçersiz durum: ${newStatus}`);
  }

  const db = getFirestore();

  // 1. Organizatör Kontrolü
  const eventDoc = await db.collection("events").doc(eventId).get();
  if (!eventDoc.exists) {
    throw new HttpsError("not-found", "Etkinlik bulunamadı.");
  }

  if (eventDoc.data().organizerId !== uid) {
    throw new HttpsError("permission-denied", "Bu işlem için yetkiniz yok.");
  }

  // 2. Mevcut Durumu Kontrol Et (XP çiftlenmesini önlemek için)
  const appRef = db.collection("events").doc(eventId)
    .collection("applications").doc(targetUserId);

  const appDoc = await appRef.get();
  if (!appDoc.exists) {
    throw new HttpsError("not-found", "Başvuru bulunamadı.");
  }

  const oldStatus = appDoc.data().status;

  // 3. Batch Güncelle
  const batch = db.batch();
  const eventRef = db.collection("events").doc(eventId);
  const userRef = db.collection("users").doc(targetUserId);

  batch.update(appRef, { status: newStatus });

  if (newStatus === "approved" && oldStatus !== "approved") {
    batch.update(eventRef, {
      participants: FieldValue.arrayUnion(targetUserId),
      approved_volunteers: FieldValue.arrayUnion(targetUserId),
    });
    batch.update(userRef, { xp: FieldValue.increment(50) });
  } else if (newStatus !== "approved" && oldStatus === "approved") {
    batch.update(eventRef, {
      participants: FieldValue.arrayRemove(targetUserId),
      approved_volunteers: FieldValue.arrayRemove(targetUserId),
    });
    batch.update(userRef, { xp: FieldValue.increment(-50) });
  }

  try {
    await batch.commit();
    console.log(`[updateApplicationStatus] ${eventId}/${targetUserId}: ${oldStatus} -> ${newStatus}`);
    return { success: true };
  } catch (err) {
    console.error("[updateApplicationStatus] Hata:", err);
    throw new HttpsError("internal", "Durum güncellenemedi: " + err.message);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// toggleJoinEvent
// İstemci Gönderir : { eventId }
// Ne Yapar         : Kullanıcının etkinliğe katılma/ayrılma işlemini yönetir.
//                    XP ödülü/cezası sunucu tarafında güvenle uygulanır.
// ─────────────────────────────────────────────────────────────────────────────
exports.toggleJoinEvent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { eventId } = request.data;

  if (!eventId) {
    throw new HttpsError("invalid-argument", "eventId zorunludur.");
  }

  const db = getFirestore();
  const eventRef = db.collection("events").doc(eventId);
  const appRef = eventRef.collection("applications").doc(uid);

  // Transaction ile tutarlı okuma/yazma
  try {
    await db.runTransaction(async (transaction) => {
      const eventDoc = await transaction.get(eventRef);
      const appDoc = await transaction.get(appRef);

      if (!eventDoc.exists) {
        throw new HttpsError("not-found", "Etkinlik bulunamadı.");
      }

      const participants = eventDoc.data().participants || [];
      const isParticipant = participants.includes(uid);

      if (isParticipant) {
        // Onaylı katılımcı — ayrıl
        transaction.delete(appRef);
        transaction.update(eventRef, {
          participants: FieldValue.arrayRemove(uid),
          approved_volunteers: FieldValue.arrayRemove(uid),
        });
        transaction.update(db.collection("users").doc(uid), {
          xp: FieldValue.increment(-50),
        });
      } else if (appDoc.exists) {
        // Bekleyen başvuru — iptal et
        transaction.delete(appRef);
      } else {
        // Yeni başvuru oluştur (pending)
        // Son başvuru tarihi kontrolü
        const eventData = eventDoc.data();
        const lastApplyDate = eventData.lastApplyDate;
        const startDate = eventData.startDate;
        const deadline = lastApplyDate ? lastApplyDate.toDate() : startDate.toDate();
        if (new Date() > deadline) {
          throw new HttpsError("failed-precondition", "Bu etkinlik/proje için başvuru süresi dolmuştur.");
        }

        transaction.set(appRef, {
          userId: uid,
          eventId: eventId,
          status: "pending",
          appliedAt: FieldValue.serverTimestamp(),
        });
      }
    });

    console.log(`[toggleJoinEvent] User ${uid} toggled event ${eventId}`);
    return { success: true };
  } catch (err) {
    if (err instanceof HttpsError) throw err;
    console.error("[toggleJoinEvent] Hata:", err);
    throw new HttpsError("internal", "İşlem tamamlanamadı: " + err.message);
  }
});

// =============================================================================
// ── SOCIAL FUNCTIONS ──────────────────────────────────────────────────────────
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// toggleFollowNgo
// İstemci Gönderir : { ngoId }
// Ne Yapar         : Kullanıcının bir NGO'yu takip/takipten çıkma işlemini
//                    transaction ile atomik olarak yönetir.
// ─────────────────────────────────────────────────────────────────────────────
exports.toggleFollowNgo = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { ngoId } = request.data;

  if (!ngoId) {
    throw new HttpsError("invalid-argument", "ngoId zorunludur.");
  }

  if (uid === ngoId) {
    throw new HttpsError("invalid-argument", "Kendinizi takip edemezsiniz.");
  }

  const db = getFirestore();
  const userRef = db.collection("users").doc(uid);
  const ngoRef = db.collection("users").doc(ngoId);

  try {
    await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      const ngoDoc = await transaction.get(ngoRef);

      if (!userDoc.exists || !ngoDoc.exists) {
        throw new HttpsError("not-found", "Kullanıcı veya kurum bulunamadı.");
      }

      const following = userDoc.data().following || [];
      const isFollowing = following.includes(ngoId);

      if (isFollowing) {
        transaction.update(userRef, { following: FieldValue.arrayRemove(ngoId) });
        transaction.update(ngoRef, {
          followersCount: FieldValue.increment(-1),
          followers: FieldValue.arrayRemove(uid),
        });
      } else {
        transaction.update(userRef, { following: FieldValue.arrayUnion(ngoId) });
        transaction.update(ngoRef, {
          followersCount: FieldValue.increment(1),
          followers: FieldValue.arrayUnion(uid),
        });
      }
    });

    console.log(`[toggleFollowNgo] User ${uid} toggled follow on NGO ${ngoId}`);
    return { success: true };
  } catch (err) {
    if (err instanceof HttpsError) throw err;
    console.error("[toggleFollowNgo] Hata:", err);
    throw new HttpsError("internal", "İşlem tamamlanamadı: " + err.message);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// toggleLikePost
// İstemci Gönderir : { postId }
// Ne Yapar         : Post beğeni/beğeni kaldırma işlemini transaction ile
//                    atomik olarak yönetir; çift beğeniyi önler.
// ─────────────────────────────────────────────────────────────────────────────
exports.toggleLikePost = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { postId } = request.data;

  if (!postId) {
    throw new HttpsError("invalid-argument", "postId zorunludur.");
  }

  const db = getFirestore();
  const postRef = db.collection("posts").doc(postId);
  const likeRef = db.collection("post_likes").doc(`${postId}_${uid}`);

  try {
    await db.runTransaction(async (transaction) => {
      const likeDoc = await transaction.get(likeRef);

      if (likeDoc.exists) {
        // Beğeniyi kaldır
        transaction.delete(likeRef);
        transaction.update(postRef, { likeCount: FieldValue.increment(-1) });
      } else {
        // Beğen
        transaction.set(likeRef, {
          postId,
          userId: uid,
          createdAt: FieldValue.serverTimestamp(),
        });
        transaction.update(postRef, { likeCount: FieldValue.increment(1) });
      }
    });

    console.log(`[toggleLikePost] User ${uid} toggled like on post ${postId}`);
    return { success: true };
  } catch (err) {
    if (err instanceof HttpsError) throw err;
    console.error("[toggleLikePost] Hata:", err);
    throw new HttpsError("internal", "İşlem tamamlanamadı: " + err.message);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// deletePost
// İstemci Gönderir : { postId }
// Ne Yapar         : Sahiplik kontrolü yapar, Firestore'dan postu siler,
//                    Storage'daki görseli temizler.
// ─────────────────────────────────────────────────────────────────────────────
exports.deletePost = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { postId } = request.data;

  if (!postId) {
    throw new HttpsError("invalid-argument", "postId zorunludur.");
  }

  const db = getFirestore();

  // 1. Postu oku ve sahiplik kontrolü yap
  const postRef = db.collection("posts").doc(postId);
  const postDoc = await postRef.get();

  if (!postDoc.exists) {
    throw new HttpsError("not-found", "Gönderi bulunamadı.");
  }

  const postData = postDoc.data();
  if (postData.publisherId !== uid) {
    throw new HttpsError("permission-denied", "Bu gönderiyi silme yetkiniz yok.");
  }

  const imageUrl = postData.imageUrl || "";

  // 2. Firestore'dan sil
  try {
    await postRef.delete();
    console.log(`[deletePost] Post silindi: ${postId} (User: ${uid})`);
  } catch (err) {
    console.error("[deletePost] Firestore silme hatası:", err);
    throw new HttpsError("internal", "Gönderi silinemedi: " + err.message);
  }

  // 3. Storage'daki görseli sil (Blaze planı gerektirdiğinden graceful)
  if (imageUrl && imageUrl.includes("firebasestorage.googleapis.com")) {
    try {
      const storage = getStorage();
      // URL'den dosya yolunu çıkar
      const urlPath = decodeURIComponent(imageUrl.split("/o/")[1].split("?")[0]);
      await storage.bucket().file(urlPath).delete();
      console.log(`[deletePost] Storage görseli silindi: ${urlPath}`);
    } catch (storageErr) {
      // Storage silme başarısız olursa sadece logla — post zaten silindi
      console.warn(`[deletePost] Storage silme başarısız (göz ardı edildi): ${storageErr.message}`);
    }
  }

  return { success: true };
});

// ─────────────────────────────────────────────────────────────────────────────
// updatePost
// İstemci Gönderir : { postId, title, description }
// Ne Yapar         : Sahiplik kontrolü yapar; başlık ve açıklamayı günceller.
// ─────────────────────────────────────────────────────────────────────────────
exports.updatePost = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { postId, title, description } = request.data;

  if (!postId || !title || !description) {
    throw new HttpsError("invalid-argument", "postId, başlık ve açıklama zorunludur.");
  }

  if (title.length > 200) {
    throw new HttpsError("invalid-argument", "Başlık en fazla 200 karakter olabilir.");
  }

  if (description.length > 5000) {
    throw new HttpsError("invalid-argument", "Açıklama en fazla 5000 karakter olabilir.");
  }

  const db = getFirestore();
  const postRef = db.collection("posts").doc(postId);
  const postDoc = await postRef.get();

  if (!postDoc.exists) {
    throw new HttpsError("not-found", "Gönderi bulunamadı.");
  }

  // Sahiplik kontrolü
  if (postDoc.data().publisherId !== uid) {
    throw new HttpsError("permission-denied", "Bu gönderiyi düzenleme yetkiniz yok.");
  }

  try {
    await postRef.update({ title, description });
    console.log(`[updatePost] Post güncellendi: ${postId} (User: ${uid})`);
    return { success: true };
  } catch (err) {
    console.error("[updatePost] Hata:", err);
    throw new HttpsError("internal", "Gönderi güncellenemedi: " + err.message);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// addComment
// İstemci Gönderir : { postId, content }
// Ne Yapar         : İçerik uzunluğu ve rate limiting kontrolü yapar;
//                    yorumu Firestore'a yazar ve commentCount'u artırır.
// ─────────────────────────────────────────────────────────────────────────────
const COMMENT_MAX_LENGTH = 1000;
const COMMENT_RATE_LIMIT_PER_MINUTE = 5;

exports.addComment = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { postId, content } = request.data;

  if (!postId || !content) {
    throw new HttpsError("invalid-argument", "postId ve yorum içeriği zorunludur.");
  }

  const trimmed = content.trim();

  if (trimmed.length === 0) {
    throw new HttpsError("invalid-argument", "Yorum boş olamaz.");
  }

  if (trimmed.length > COMMENT_MAX_LENGTH) {
    throw new HttpsError(
      "invalid-argument",
      `Yorum en fazla ${COMMENT_MAX_LENGTH} karakter olabilir.`
    );
  }

  const db = getFirestore();

  // Post varlık kontrolü
  const postRef = db.collection("posts").doc(postId);
  const postDoc = await postRef.get();
  if (!postDoc.exists) {
    throw new HttpsError("not-found", "Gönderi bulunamadı.");
  }

  // Rate limiting: son 1 dakikada kaç yorum yapıldı?
  const oneMinuteAgo = new Date(Date.now() - 60 * 1000);
  const recentComments = await db
    .collection("posts")
    .doc(postId)
    .collection("comments")
    .where("userId", "==", uid)
    .where("createdAt", ">=", oneMinuteAgo)
    .limit(COMMENT_RATE_LIMIT_PER_MINUTE)
    .get();

  if (recentComments.size >= COMMENT_RATE_LIMIT_PER_MINUTE) {
    throw new HttpsError(
      "resource-exhausted",
      "Çok fazla yorum yaptınız. Lütfen bir dakika bekleyin."
    );
  }

  // Yorum ekle + sayacı artır (batch)
  const commentRef = db.collection("posts").doc(postId).collection("comments").doc();
  const batch = db.batch();

  batch.set(commentRef, {
    postId,
    userId: uid,
    content: trimmed,
    createdAt: FieldValue.serverTimestamp(),
  });

  batch.update(postRef, { commentCount: FieldValue.increment(1) });

  try {
    await batch.commit();
    console.log(`[addComment] Yorum eklendi: ${commentRef.id} (Post: ${postId}, User: ${uid})`);
    return { commentId: commentRef.id };
  } catch (err) {
    console.error("[addComment] Hata:", err);
    throw new HttpsError("internal", "Yorum eklenemedi: " + err.message);
  }
});

// =============================================================================
// ── EVENT CHAT FUNCTION ───────────────────────────────────────────────────────
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// sendEventChatMessage
// İstemci Gönderir : { eventId, content }
// Ne Yapar         : Kullanıcının onaylı gönüllü olup olmadığını kontrol eder;
//                    mesajı events/{eventId}/chat koleksiyonuna yazar.
// ─────────────────────────────────────────────────────────────────────────────
exports.sendEventChatMessage = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { eventId, content } = request.data;

  if (!eventId || !content || content.trim().length === 0) {
    throw new HttpsError("invalid-argument", "eventId ve mesaj içeriği zorunludur.");
  }

  if (content.length > 2000) {
    throw new HttpsError("invalid-argument", "Mesaj en fazla 2000 karakter olabilir.");
  }

  const db = getFirestore();

  // 1. Etkinlik var mı ve kullanıcı onaylı mı kontrol et
  const eventDoc = await db.collection("events").doc(eventId).get();
  if (!eventDoc.exists) {
    throw new HttpsError("not-found", "Etkinlik bulunamadı.");
  }

  const approvedVolunteers = eventDoc.data().approved_volunteers || [];
  if (!approvedVolunteers.includes(uid)) {
    throw new HttpsError("permission-denied", "Bu sohbete katılma yetkiniz yok.");
  }

  // 2. Kullanıcı bilgilerini al
  const userDoc = await db.collection("users").doc(uid).get();
  const userData = userDoc.exists ? userDoc.data() : {};
  const senderName =
    userData.stkName ||
    `${userData.name || ""} ${userData.surname || ""}`.trim() ||
    "Anonim";

  // 3. Mesajı yaz
  const chatRef = db.collection("events").doc(eventId).collection("chat").doc();
  await chatRef.set({
    eventId,
    senderId: uid,
    senderName,
    senderAvatarUrl: userData.imageUrl || "",
    content: content.trim(),
    createdAt: FieldValue.serverTimestamp(),
  });

  console.log(`[sendEventChatMessage] Mesaj gönderildi: ${chatRef.id} (Event: ${eventId}, User: ${uid})`);
  return { messageId: chatRef.id };
});

// =============================================================================
// ── COMMENT FUNCTIONS ─────────────────────────────────────────────────────────
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// deleteComment
// İstemci Gönderir : { postId, commentId }
// Ne Yapar         : Sahiplik kontrolü yapar (yorum sahibi veya post sahibi);
//                    yorumu siler ve commentCount'u azaltır.
// ─────────────────────────────────────────────────────────────────────────────
exports.deleteComment = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { postId, commentId } = request.data;

  if (!postId || !commentId) {
    throw new HttpsError("invalid-argument", "postId ve commentId zorunludur.");
  }

  const db = getFirestore();
  const commentRef = db.collection("posts").doc(postId).collection("comments").doc(commentId);
  const commentDoc = await commentRef.get();

  if (!commentDoc.exists) {
    throw new HttpsError("not-found", "Yorum bulunamadı.");
  }

  // Sahiplik kontrolü: yorum sahibi veya post sahibi silebilir
  const commentData = commentDoc.data();
  const postDoc = await db.collection("posts").doc(postId).get();

  if (!postDoc.exists) {
    throw new HttpsError("not-found", "Gönderi bulunamadı.");
  }

  if (commentData.userId !== uid && postDoc.data().publisherId !== uid) {
    throw new HttpsError("permission-denied", "Bu yorumu silme yetkiniz yok.");
  }

  const batch = db.batch();
  batch.delete(commentRef);
  batch.update(db.collection("posts").doc(postId), {
    commentCount: FieldValue.increment(-1),
  });

  try {
    await batch.commit();
    console.log(`[deleteComment] Yorum silindi: ${commentId} (Post: ${postId}, User: ${uid})`);
    return { success: true };
  } catch (err) {
    console.error("[deleteComment] Hata:", err);
    throw new HttpsError("internal", "Yorum silinemedi: " + err.message);
  }
});

// =============================================================================
// ── EVENT MANAGEMENT FUNCTIONS ────────────────────────────────────────────────
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// updateEvent
// İstemci Gönderir : { eventId, title?, description?, location?, geoPoint?,
//                      startDate?, endDate?, category?, type?, imageUrl?, quota? }
// Ne Yapar         : Organizatör kontrolü yapar; etkinliği günceller.
// ─────────────────────────────────────────────────────────────────────────────
exports.updateEvent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { eventId, title, description, location, geoPoint, startDate, endDate, category, type, imageUrl, quota, lastApplyDate } = request.data;

  if (!eventId) {
    throw new HttpsError("invalid-argument", "eventId zorunludur.");
  }

  const db = getFirestore();
  const eventRef = db.collection("events").doc(eventId);
  const eventDoc = await eventRef.get();

  if (!eventDoc.exists) {
    throw new HttpsError("not-found", "Etkinlik bulunamadı.");
  }

  if (eventDoc.data().organizerId !== uid) {
    throw new HttpsError("permission-denied", "Bu etkinliği düzenleme yetkiniz yok.");
  }

  const { GeoPoint, Timestamp } = require("firebase-admin/firestore");
  const updateData = {};

  if (title !== undefined) updateData.title = title;
  if (description !== undefined) updateData.description = description;
  if (location !== undefined) updateData.location = location;
  if (geoPoint !== undefined) updateData.geoPoint = new GeoPoint(geoPoint.lat, geoPoint.lng);
  if (startDate !== undefined) updateData.startDate = Timestamp.fromDate(new Date(startDate));
  if (endDate !== undefined) updateData.endDate = Timestamp.fromDate(new Date(endDate));
  if (category !== undefined) updateData.category = category;
  if (type !== undefined) {
    updateData.type = type;
    updateData.isProject = type === "Proje";
  }
  if (imageUrl !== undefined) updateData.imageUrl = imageUrl;
  if (quota !== undefined) updateData.quota = quota;
  if (lastApplyDate !== undefined) {
    updateData.lastApplyDate = lastApplyDate ? Timestamp.fromDate(new Date(lastApplyDate)) : null;
  }

  if (Object.keys(updateData).length === 0) {
    throw new HttpsError("invalid-argument", "Güncellenecek alan bulunamadı.");
  }

  try {
    await eventRef.update(updateData);
    console.log(`[updateEvent] Etkinlik güncellendi: ${eventId} (NGO: ${uid})`);
    return { success: true };
  } catch (err) {
    console.error("[updateEvent] Hata:", err);
    throw new HttpsError("internal", "Etkinlik güncellenemedi: " + err.message);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// deleteEvent
// İstemci Gönderir : { eventId }
// Ne Yapar         : Organizatör kontrolü yapar; etkinliği ve tüm
//                    alt koleksiyonlarını (applications, chat) siler.
//                    Storage'daki görseli de temizler.
// ─────────────────────────────────────────────────────────────────────────────
exports.deleteEvent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const uid = request.auth.uid;
  const { eventId } = request.data;

  if (!eventId) {
    throw new HttpsError("invalid-argument", "eventId zorunludur.");
  }

  const db = getFirestore();
  const eventRef = db.collection("events").doc(eventId);
  const eventDoc = await eventRef.get();

  if (!eventDoc.exists) {
    throw new HttpsError("not-found", "Etkinlik bulunamadı.");
  }

  if (eventDoc.data().organizerId !== uid) {
    throw new HttpsError("permission-denied", "Bu etkinliği silme yetkiniz yok.");
  }

  try {
    // 1. Alt koleksiyonları sil (applications)
    const appsSnap = await eventRef.collection("applications").get();
    if (appsSnap.size > 0) {
      const appBatch = db.batch();
      appsSnap.docs.forEach((doc) => appBatch.delete(doc.ref));
      await appBatch.commit();
    }

    // 2. Alt koleksiyonları sil (chat)
    const chatSnap = await eventRef.collection("chat").get();
    if (chatSnap.size > 0) {
      const chatBatch = db.batch();
      chatSnap.docs.forEach((doc) => chatBatch.delete(doc.ref));
      await chatBatch.commit();
    }

    // 3. Storage görselini sil
    const imageUrl = eventDoc.data().imageUrl;
    if (imageUrl && imageUrl.includes("firebasestorage.googleapis.com")) {
      try {
        const storage = getStorage();
        const urlPath = decodeURIComponent(imageUrl.split("/o/")[1].split("?")[0]);
        await storage.bucket().file(urlPath).delete();
        console.log(`[deleteEvent] Storage görseli silindi.`);
      } catch (storageErr) {
        console.warn(`[deleteEvent] Storage silme hatası (göz ardı edildi): ${storageErr.message}`);
      }
    }

    // 4. Etkinliği sil
    await eventRef.delete();
    console.log(`[deleteEvent] Etkinlik silindi: ${eventId} (NGO: ${uid})`);
    return { success: true };
  } catch (err) {
    if (err instanceof HttpsError) throw err;
    console.error("[deleteEvent] Hata:", err);
    throw new HttpsError("internal", "Etkinlik silinemedi: " + err.message);
  }
});

// =============================================================================
// ── FCM TOKEN FUNCTION ────────────────────────────────────────────────────────
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// saveFcmToken
// İstemci Gönderir : { token }
// Ne Yapar         : FCM token'ını güvenli şekilde kullanıcı profiline kaydeder.
//                    İstemciden doğrudan Firestore yazmak yerine CF tercih edilir.
// ─────────────────────────────────────────────────────────────────────────────
exports.saveFcmToken = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const { token } = request.data;

  if (!token || typeof token !== "string" || token.trim().length === 0) {
    throw new HttpsError("invalid-argument", "Geçerli bir FCM token gereklidir.");
  }

  const db = getFirestore();
  const uid = request.auth.uid;

  try {
    await db.collection("users").doc(uid).update({
      fcmToken: token.trim(),
    });
    console.log(`[saveFcmToken] FCM token kaydedildi: ${uid}`);
    return { success: true };
  } catch (err) {
    console.error("[saveFcmToken] Hata:", err);
    throw new HttpsError("internal", "FCM token kaydedilemedi: " + err.message);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// clearFcmToken
// İstemci Gönderir : {}
// Ne Yapar         : Çıkış yapan kullanıcının FCM token'ını temizler.
// ─────────────────────────────────────────────────────────────────────────────
exports.clearFcmToken = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bu işlem için giriş yapmalısınız.");
  }

  const db = getFirestore();
  const uid = request.auth.uid;

  try {
    await db.collection("users").doc(uid).update({
      fcmToken: FieldValue.delete(),
    });
    console.log(`[clearFcmToken] FCM token temizlendi: ${uid}`);
    return { success: true };
  } catch (err) {
    console.error("[clearFcmToken] Hata:", err);
    throw new HttpsError("internal", "FCM token temizlenemedi: " + err.message);
  }
});
