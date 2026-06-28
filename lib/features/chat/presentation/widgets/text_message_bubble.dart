import 'package:flutter/material.dart';

class TextMessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool isDeleted;
  final String time;

  const TextMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isDeleted,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDeleted
              ? (isDark ? const Color(0xFF1F2937) : Colors.grey.shade200)
              : isMe
              ? (isDark ? const Color(0xFF375FFF) : const Color(0xFFE3F2FD))
              : (isDark ? const Color(0xFF1F2937) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),

            bottomLeft: isMe
                ? const Radius.circular(16)
                : const Radius.circular(0),

            bottomRight: isMe
                ? const Radius.circular(0)
                : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message),

            const SizedBox(height: 6),

            Text(time, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
