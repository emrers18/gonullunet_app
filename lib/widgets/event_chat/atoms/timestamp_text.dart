import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimestampText extends StatelessWidget {
  final Timestamp timestamp;
  final TextStyle? style;

  const TimestampText({
    super.key,
    required this.timestamp,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final date = timestamp.toDate();
    final formatter = DateFormat('HH:mm');
    final formattedTime = formatter.format(date);

    return Text(
      formattedTime,
      style: style ??
          const TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
    );
  }
}
