import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart'
    hide ChatSession;
import 'package:gonullunet_app/models/chat_message_model.dart';
import 'package:gonullunet_app/models/chat_session_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final GenerativeModel _model;

  static const String _systemPrompt =
      'Sen GönüllüNet dijital gençlik çalışanı asistanısın. '
      'Sadece Avrupa Birliği projeleri, gönüllülük, sivil toplum kuruluşları (STK), '
      'sosyal sorumluluk projeleri ve Erasmus+ hakkında bilgi verirsin. '
      'Bu konular dışındaki sorulara nazikçe cevap veremeyeceğini belirtirsin '
      've kullanıcıyı Türkiye Ulusal Ajansı\'nın resmi web sitesine (www.ua.gov.tr) yönlendirirsin. '
      'Kullanıcılardan TC Kimlik No, pasaport numarası gibi kişisel veriler talep etme. '
      'Eğer kullanıcı kendiliğinden bu bilgileri verirse, bunları koru ve işlemeyeceğini belirt. '
      'Her zaman nazik, profesyonel ve teşvik edici ol. '
      'Gençlerin motivasyonunu kırmaktan kaçın. '
      'Karmaşık teknik terimleri, bir gencin anlayabileceği şekilde basitleştirerek açıkla. '
      'Küfürlü, hakaret içerikli, ayrımcı veya siyasi ifadeler kullanma. '
      'Kullanıcı bu yönde bir dil kullansa dahi sen nezaketini bozma ve profesyonel kal. '
      'Cevaplarını kısa ve öz tut. En fazla 3-4 paragraf ile yanıt ver.';

  ChatRepository() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_systemPrompt),
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
    // Delete all messages in the session first
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
    final now = Timestamp.now();

    // Save user message
    await _messagesRef(sessionId).add({
      'content': content,
      'role': 'user',
      'createdAt': now,
    });

    // Update session lastMessageAt
    await _sessionsRef().doc(sessionId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    // Check if this is the first message to update session title
    final messagesSnapshot = await _messagesRef(sessionId).get();
    if (messagesSnapshot.docs.length <= 1) {
      await _updateSessionTitle(sessionId, content);
    }

    // Build chat history for context
    final history = await getMessages(sessionId);
    final chatHistory = history.map((msg) {
      return Content(
        msg.isUser ? 'user' : 'model',
        [TextPart(msg.content)],
      );
    }).toList();

    // Remove the last user message from history since we pass it as the new content
    if (chatHistory.isNotEmpty) {
      chatHistory.removeLast();
    }

    // Get AI response
    final chat = _model.startChat(history: chatHistory);
    final response = await chat.sendMessage(Content.text(content));
    final aiText = response.text ?? 'Üzgünüm, bir yanıt oluşturamadım.';

    // Save AI response
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
