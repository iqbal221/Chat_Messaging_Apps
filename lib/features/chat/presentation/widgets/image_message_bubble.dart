import 'package:flutter/material.dart';

class ImageMessageBubble extends StatelessWidget {
  final String fileUrl;
  final String time;
  final bool isDeleted;
  final bool isMe;
  final VoidCallback? onTap;

  const ImageMessageBubble({
    super.key,
    required this.fileUrl,
    required this.time,
    required this.isMe,
    this.onTap,
    required this.isDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDeleted
                ? (isDark ? const Color(0xFF1F2937) : Colors.grey.shade200)
                : isMe
                ? (isDark ? const Color(0xFF375FFF) : const Color(0xFFE3F2FD))
                : (isDark ? const Color(0xFF1F2937) : Colors.white),

            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),

                child: Image.network(
                  fileUrl,
                  height: 220,
                  width: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 6),

              Text(time, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
