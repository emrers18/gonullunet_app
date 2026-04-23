import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(initSettings);

    // FCM token'ı al ve Firestore'a kaydet
    await _saveFcmToken();

    // Token yenilendiğinde otomatik güncelle
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _updateFcmToken(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Uygulama ön plandayken FCM gelince sistem bildirimi göster.
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // message.data['type'] ile sayfaya yönlendirme eklenebilir
    });
  }

  /// Mevcut FCM token'ı alır ve Firestore'a kaydeder.
  Future<void> _saveFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _updateFcmToken(token);
      }
    } catch (e) {
      debugPrint('FCM token kaydedilemedi: $e');
    }
  }

  /// FCM token'ı Firestore'daki kullanıcı belgesine yazar.
  Future<void> _updateFcmToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});
    } catch (e) {
      debugPrint('FCM token güncellenemedi: $e');
    }
  }

  /// Kullanıcı çıkış yaptığında FCM token'ı temizler.
  Future<void> clearFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': FieldValue.delete()});
      await _firebaseMessaging.deleteToken();
    } catch (e) {
      debugPrint('FCM token temizlenemedi: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Önemli Bildirimler',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@drawable/ic_notification',
            color: Color(0xFFFF5722),
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}
