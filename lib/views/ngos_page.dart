import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/ngo_model.dart';
import '../widgets/ngos/ngos_card.dart';

const Color kBackgroundColor = Color(0xFFF9F9F9);
const Color kFollowButtonColor = Color(0xFFF5EBE0);
const Color kFollowButtonTextColor = Color(0xFF6D4C41);
const Color kPrimaryColor = Color(0xFFFF5722);

class NgosPage extends StatelessWidget {
  NgosPage({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Kurumlar',
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
            stream: _firestore
                .collection('users')
                .where('userType', isEqualTo: 'ngo')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('Gösterilecek kurum (STK) bulunamadı.'));
              }
              final ngoDocs = snapshot.data!.docs;

              return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemBuilder: (context, index) {
                    final ngo = Ngo.fromFirestore(ngoDocs[index]);
                    return NgoCard(ngo: ngo);
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 24,
                      ),
                  itemCount: ngoDocs.length);
            }));
  }
}
