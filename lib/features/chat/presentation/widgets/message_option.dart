import 'package:ChatVani/features/chat/presentation/widgets/message_option_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future<void> showMessageOptions({
  required BuildContext context,
  required bool isMe,
  required VoidCallback onDeleteForMe,
  required VoidCallback onDeleteForEveryone,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (_) {
      return MessageOptionsBottomSheet(
        isMe: isMe,
        onDeleteForMe: onDeleteForMe,
        onDeleteForEveryone: onDeleteForEveryone,
      );
    },
  );
}
