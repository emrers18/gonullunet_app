/**
 * GönüllüNet - Firebase Cloud Functions
 *
 * onEventCreated: Yeni etkinlik Firestore'a eklendiğinde çalışır.
 * Kurumun tüm takipçilerine in-app + FCM push bildirim gönderir.
 *
 * onApplicationStatusUpdated: Başvuru durumu (status) değiştiğinde çalışır.
 * Gönüllüye başvurusunun onaylandığını veya reddedildiğini bildirir.
 */

const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

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
