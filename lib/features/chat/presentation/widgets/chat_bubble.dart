import 'package:flutter/material.dart';
import 'text_message_bubble.dart';
import 'image_message_bubble.dart';
import 'pdf_message_bubble.dart';
import 'file_message_bubble.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  final bool isDeleted;
  final String? fileUrl;
  final String? fileName;
  final String? fileType;
  final VoidCallback? onFileTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
    required this.isDeleted,
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.onFileTap,
  });

  @override
  Widget build(BuildContext context) {
    if (fileType == "image") {
      return ImageMessageBubble(
        isMe: isMe,
        time: time,
        fileUrl: fileUrl!,
        onTap: onFileTap,
        isDeleted: false,
      );
    }

    if (fileType == "pdf") {
      return PdfMessageBubble(
        isMe: isMe,
        time: time,
        fileName: fileName ?? "PDF File",
        onTap: onFileTap,
        isDeleted: false,
      );
    }

    if (fileType != null && fileType != "image" && fileType != "pdf") {
      return FileMessageBubble(
        isMe: isMe,
        time: time,
        fileName: fileName ?? "File",
        onTap: onFileTap,
        isDeleted: false,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextMessageBubble(
        message: message,
        isMe: isMe,
        time: time,
        isDeleted: isDeleted,
      ),
    );
  }
}
