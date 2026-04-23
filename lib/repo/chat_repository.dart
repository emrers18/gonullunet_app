import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart' hide ChatSession;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:gonullunet_app/models/chat_message_model.dart';
import 'package:gonullunet_app/models/chat_session_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Remote Config varsayılan değerleri (ilk fetch başarısız olursa kullanılır)
  static const String _defaultModelName = 'gemini-2.5-flash';
  static const String _defaultSystemInstruction =
      'Sen GönüllüNet dijital gençlik çalışanı asistanısın. '
      'Sadece Avrupa Birliği projeleri, gönüllülük, sivil toplum kuruluşları (STK), '
      'sosyal sorumluluk projeleri ve Erasmus+ hakkında bilgi verirsin. '
      'Bu konular dışındaki sorulara nazikçe cevap veremeyeceğini belirtirsin '
      've kullanıcıyı Türkiye Ulusal Ajansı\'nın resmi web sitesine (www.ua.gov.tr) yönlendirirsin. '
      'Kullanıcılardan TC Kimlik No, pasaport numarası gibi kişisel veriler talep etme. '
      'Her zaman nazik, profesyonel ve teşvik edici ol. '
      'Cevaplarını kısa ve öz tut. En fazla 3-4 paragraf ile yanıt ver.';

  GenerativeModel? _model;

  /// Remote Config'i fetch edip modeli başlatır.
  /// Uygulama başlatılırken veya chat ekranı açılırken çağrılmalıdır.
  Future<void> initialize() async {
    try {
      // Remote Config varsayılanlarını ayarla (ilk çalışmada cache yoksa bunlar kullanılır)
      await _remoteConfig.setDefaults({
        'ai_model_name': _defaultModelName,
        'ai_system_instruction': _defaultSystemInstruction,
      });

      // Minimum fetch aralığı: 1 saat (üretimde). Geliştirme için 0 yapılabilir.
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Fetch başarısız olsa da varsayılan değerlerle devam edilir
      // ignore: avoid_print
      print('Remote Config fetch hatası (varsayılanlar kullanılacak): $e');
    }

    final modelName = _remoteConfig.getString('ai_model_name');
    final systemInstruction = _remoteConfig.getString('ai_system_instruction');

    _model = FirebaseAI.vertexAI().generativeModel(
      model: modelName.isEmpty ? _defaultModelName : modelName,
      systemInstruction: Content.system(systemInstruction),
      generationConfig: GenerationConfig(maxOutputTokens: 2500),
    );
  }

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

  Future<ChatMessage> sendMessage(String sessionId, String content) async {
    // Model henüz initialize edilmediyse başlat
    if (_model == null) await initialize();

    final now = Timestamp.now();

    await _messagesRef(sessionId).add({
      'content': content,
      'role': 'user',
      'createdAt': now,
    });

    await _sessionsRef().doc(sessionId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    final messagesSnapshot = await _messagesRef(sessionId).get();
    if (messagesSnapshot.docs.length <= 1) {
      await _updateSessionTitle(sessionId, content);
    }

    // Sohbet geçmişini Firebase AI'a uygun formata çevir
    final history = await getMessages(sessionId);
    final chatHistory = history.map((msg) {
      return Content(
        msg.isUser ? 'user' : 'model',
        [TextPart(msg.content)],
      );
    }).toList();

    if (chatHistory.isNotEmpty) {
      chatHistory.removeLast();
    }

    final chat = _model!.startChat(history: chatHistory);
    final response = await chat.sendMessage(Content.text(content));
    final aiText = response.text ?? 'Üzgünüm, bir yanıt oluşturamadım.';

    final aiTimestamp = Timestamp.now();
    final aiDocRef = await _messagesRef(sessionId).add({
      'content': aiText,
      'role': 'ai',
      'createdAt': aiTimestamp,
    });

    return ChatMessage(
      id: aiDocRef.id,
      content: aiText,
      role: 'ai',
      createdAt: aiTimestamp,
    );
  }
}
