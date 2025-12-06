import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/models/event_model.dart';

import '../widgets/events/event_card.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final Auth _auth = Auth();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;
  Stream<QuerySnapshot>? _eventsStream;

  @override
  void initState() {
    super.initState();
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _userStream =
          _firestore.collection('users').doc(currentUser.uid).snapshots();
    }
    _eventsStream = _firestore.collection('events').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Etkinlikler',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Gösterilecek etkinlik bulunamadı.'));
          }

          final eventDocs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: eventDocs.length,
            itemBuilder: (context, index) {
              final event = Event.fromFirestore(eventDocs[index]);
              return EventCard(event: event);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 24),
          );
        },
      ),
      floatingActionButton:
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data();
            final String userType = userData?['userType'] ?? 'volunteer';

            if (userType == 'ngo') {
              return FloatingActionButton(
                onPressed: () {},
                heroTag: 'add_event_fab',
                backgroundColor: kPrimaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
