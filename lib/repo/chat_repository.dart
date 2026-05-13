import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gonullunet_app/models/chat_message_model.dart';
import 'package:gonullunet_app/models/chat_session_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference _sessionsRef() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_sessions');
  }

  CollectionReference _messagesRef(String sessionId) {
    return _sessionsRef().doc(sessionId).collection('messages');
  }

  // ── Sessions ──────────────────────────────────────────────

  Future<ChatSession> createSession() async {
    final now = Timestamp.now();
    final docRef = await _sessionsRef().add({
      'title': 'Yeni Sohbet',
      'createdAt': now,
      'lastMessageAt': now,
    });
    return ChatSession(
      id: docRef.id,
      title: 'Yeni Sohbet',
      createdAt: now,
      lastMessageAt: now,
    );
  }

  Future<List<ChatSession>> getSessions() async {
    final snapshot =
        await _sessionsRef().orderBy('lastMessageAt', descending: true).get();
    return snapshot.docs.map((doc) => ChatSession.fromFirestore(doc)).toList();
  }

  Future<void> deleteSession(String sessionId) async {
    final messagesSnapshot = await _messagesRef(sessionId).get();
    final batch = _firestore.batch();
    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_sessionsRef().doc(sessionId));
    await batch.commit();
  }

  Future<void> _updateSessionTitle(
      String sessionId, String firstMessage) async {
    String title = firstMessage.length > 40
        ? '${firstMessage.substring(0, 40)}...'
        : firstMessage;
    await _sessionsRef().doc(sessionId).update({'title': title});
  }

  // ── Messages ──────────────────────────────────────────────

  Stream<List<ChatMessage>> getMessagesStream(String sessionId) {
    return _messagesRef(sessionId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final snapshot = await _messagesRef(sessionId)
        .orderBy('createdAt', descending: false)
        .get();
    return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
  }

  Future<SendMessageResponse> sendMessage(
      String? sessionId, String content) async {
    final now = Timestamp.now();

    // 1. Sohbet geçmişini hazırla
    List<Map<String, dynamic>> chatHistory = [];
    if (sessionId != null && !sessionId.startsWith('_new_')) {
      final history = await getMessages(sessionId);
      chatHistory = history.map((msg) {
        return {
          'role': msg.role == 'user' ? 'user' : 'model',
          'content': msg.content,
        };
      }).toList();
    }

    try {
      // 2. AI Yanıtını Al (Veritabanına dokunmadan önce)
      final aiText = await getAiResponse(content, chatHistory);
      final aiTimestamp = Timestamp.now();

      // 3. Eğer sessionId yoksa veya geçiciyse, gerçek oturumu şimdi oluştur
      if (sessionId == null || sessionId.startsWith('_new_')) {
        final session = await createSession();
        sessionId = session.id;
      }

      // 4. Kullanıcı mesajını kaydet
      await _messagesRef(sessionId).add({
        'content': content,
        'role': 'user',
        'createdAt': now,
      });

      await _sessionsRef().doc(sessionId).update({
        'lastMessageAt': FieldValue.serverTimestamp(),
      });

      // İlk mesaj ise başlığı güncelle
      if (chatHistory.isEmpty) {
        await _updateSessionTitle(sessionId, content);
      }

      // 5. AI yanıtını kaydet
      final aiDocRef = await _messagesRef(sessionId).add({
        'content': aiText,
        'role': 'ai',
        'createdAt': aiTimestamp,
      });

      return SendMessageResponse(
        message: ChatMessage(
          id: aiDocRef.id,
          content: aiText,
          role: 'ai',
          createdAt: aiTimestamp,
        ),
        sessionId: sessionId,
      );
    } catch (e) {
      String errorMessage = 'Mesaj gönderilirken bir hata oluştu.';

      if (e is FirebaseFunctionsException) {
        switch (e.code) {
          case 'resource-exhausted':
            // Günlük limit veya kota aşımı
            if (e.message != null && e.message!.contains('Günlük')) {
              errorMessage =
                  'Bugünlük soru limitine ulaştın. Yarın tekrar görüşmek üzere! 🚀';
            } else {
              errorMessage =
                  'Şu an çok yoğunum, lütfen bir dakika sonra tekrar dener misin? ☕';
            }
            break;
          case 'deadline-exceeded':
            errorMessage =
                'Yanıt vermem biraz uzun sürdü, internetini kontrol edip tekrar dener misin? ⏳';
            break;
          case 'unavailable':
            errorMessage =
                'Sunucuya şu an ulaşılamıyor, lütfen daha sonra tekrar dene. 🛠️';
            break;
          default:
            errorMessage = e.message ?? errorMessage;
        }
      } else if (e.toString().toUpperCase().contains('TIMEOUT')) {
        errorMessage = 'İşlem zaman aşımına uğradı, lütfen tekrar dene. ⏳';
      }

      throw Exception(errorMessage);
    }
  }

  /// Sadece AI yanıtını döndürür, veritabanına kayıt yapmaz.
  Future<String> getAiResponse(
      String content, List<Map<String, dynamic>> chatHistory) async {
    final result = await _functions.httpsCallable('getChatResponse').call({
      'content': content,
      'history': chatHistory,
    }).timeout(const Duration(seconds: 30)); // Düzeltilen kısım

    return result.data['response'] as String;
  }
}

class SendMessageResponse {
  final ChatMessage message;
  final String sessionId;

  SendMessageResponse({required this.message, required this.sessionId});
}
