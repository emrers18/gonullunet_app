import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isJoined = user != null && event.participants.contains(user.uid);
    final String dateString =
        DateFormat('dd MMM', 'tr_TR').format(event.date).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateString,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.secondaryText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => _handleJoin(context, user, isJoined),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isJoined
                          ? Colors.grey.shade200
                          : AppColors.lightPrimaryColor,
                      foregroundColor:
                          isJoined ? Colors.grey : AppColors.primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      isJoined ? 'Katıldın' : 'Katıl',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (event.imageUrl.isNotEmpty)
            Expanded(
              flex: 1,
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleJoin(
      BuildContext context, User? user, bool isJoined) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Katılmak için giriş yapmalısınız.')),
      );
      return;
    }

    try {
      final docRef =
          FirebaseFirestore.instance.collection('events').doc(event.id);

      if (isJoined) {
        await docRef.update({
          'participants': FieldValue.arrayRemove([user.uid])
        });
      } else {
        await docRef.update({
          'participants': FieldValue.arrayUnion([user.uid])
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem başarısız: $e')),
      );
    }
  }
}
