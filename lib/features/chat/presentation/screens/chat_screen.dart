import 'dart:convert';

import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverImage;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
  });

  static const String name = "/chats";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String get myId => FirebaseAuth.instance.currentUser!.uid;

  String getChatId() {
    List ids = [myId, widget.receiverId];
    ids.sort();
    return ids.join("_");
  }

  String getDateLabel(DateTime messageTime) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      messageTime.year,
      messageTime.month,
      messageTime.day,
    );

    final diff = today.difference(messageDate).inDays;

    if (diff == 0) {
      return "Today";
    } else if (diff == 1) {
      return "Yesterday";
    } else {
      return DateFormat('dd MMM yyyy').format(messageTime);
    }
  }

  /// ================= SEND MESSAGE =================
  Future<void> sendMessage({
    String? fileUrl,
    String? fileName,
    String? fileType,
  }) async {
    final text = messageController.text.trim();

    if (text.isEmpty && fileUrl == null) return;

    final chatId = getChatId();

    messageController.clear();

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    await chatRef.set({
      "participants": [myId, widget.receiverId],
      "lastMessage": fileUrl != null ? "📎 $fileName" : text,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await chatRef.collection('messages').add({
      "text": text,
      "fileUrl": fileUrl,
      "fileName": fileName,
      "fileType": fileType,
      "senderId": myId,
      "receiverId": widget.receiverId,
      "senderName": FirebaseAuth.instance.currentUser!.displayName,
      "timestamp": FieldValue.serverTimestamp(),
      "isDeleted": false,
      "deletedFor": [],
    });

    scrollToBottom();
  }

  /// ================= PICK & SEND FILE =================
  Future<void> pickFile() async {
    final result = await FilePicker.pickFiles(type: FileType.any);

    if (result == null) return;

    final pickedFile = result.files.first;

    if (pickedFile.path == null) return;

    final file = File(pickedFile.path!);

    final fileName = pickedFile.name;

    final ext = fileName.split('.').last.toLowerCase();

    String fileType = "file";

    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      fileType = "image";
    } else if (ext == "pdf") {
      fileType = "pdf";
    }

    /// STORAGE
    final String cloudName = "deuky2rb8";
    final String uploadPreset = "chat_app_unsigned";

    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/auto/upload",
    );

    final request = http.MultipartRequest("POST", uri);

    /// UPLOAD PRESET
    request.fields['upload_preset'] = uploadPreset;

    /// FILE
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    /// SEND REQUEST
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();

      final data = jsonDecode(responseData);

      /// FILE URL
      final downloadUrl = data['secure_url'];

      /// SEND MESSAGE
      await sendMessage(
        fileUrl: downloadUrl,
        fileName: fileName,
        fileType: fileType,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cloudinary upload failed")));
    }
  }

  // download file to temp directory and open it
  Future<void> downloadAndOpen(String url, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      // ✅ force safe file name
      final safeName = fileName.contains('.') ? fileName : '$fileName.pdf';

      final path = '${dir.path}/$safeName';

      // download
      await Dio().download(url, path);

      // open
      final result = await OpenFilex.open(path);

      print("OPEN RESULT: ${result.type}");
    } catch (e) {
      print("PDF OPEN ERROR: $e");
    }
  }

  /// ================= DELETE FOR EVERYONE =================
  Future<void> deleteForEveryone(String messageId) async {
    final chatId = getChatId();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'text': 'This message was deleted',
          'isDeleted': true,
          'imageUrl': null, // optional if you support images
          'deletedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> deleteForMe(String messageId) async {
    final chatId = getChatId();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'deletedFor': FieldValue.arrayUnion([myId]),
        });
  }

  /// ================= MESSAGES STREAM =================
  Stream<QuerySnapshot> getMessages() {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(getChatId())
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkTheme.primaryColorLight
          : AppTheme.lightTheme.scaffoldBackgroundColor,

      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: isDark
            ? AppTheme.darkTheme.appBarTheme.backgroundColor
            : AppTheme.lightTheme.appBarTheme.backgroundColor,

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6,
              ), // Border thickness
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Border color
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: widget.receiverImage.isNotEmpty
                    ? NetworkImage(widget.receiverImage)
                    : null,
                child: widget.receiverImage.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(widget.receiverName, style: AppTextStyles.displayLarge),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final List<dynamic> deletedFor = data['deletedFor'] ?? [];

                  return !deletedFor.contains(myId);
                }).toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollToBottom();
                });

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;

                    final messageId = messages[index].id;
                    final isMe = msg['senderId'] == myId;
                    final isDeleted = msg['isDeleted'] == true;

                    final Timestamp? timestamp = msg['timestamp'];
                    final DateTime messageTime =
                        timestamp?.toDate() ?? DateTime.now();

                    final time = DateFormat('hh:mm a').format(messageTime);

                    /// previous message time
                    if (index > 0) {}

                    final bool showDateHeader;

                    if (index == 0) {
                      // First message always shows date
                      showDateHeader = true;
                    } else {
                      final prevMsg =
                          messages[index - 1].data() as Map<String, dynamic>;

                      final prevTimestamp = prevMsg['timestamp'] as Timestamp?;
                      final prevTime = prevTimestamp?.toDate();

                      showDateHeader =
                          prevTime == null ||
                          messageTime.day != prevTime.day ||
                          messageTime.month != prevTime.month ||
                          messageTime.year != prevTime.year;
                    }
                    return Column(
                      children: [
                        /// ✅ DATE HEADER (NOW WORKS)
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  getDateLabel(messageTime),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        /// ✅ MESSAGE BUBBLE
                        GestureDetector(
                          onLongPress: () {
                            _showMessageOptions(
                              messageId: messageId,
                              isMe: isMe,
                            );
                          },
                          child: _chatBubble(
                            isDeleted
                                ? "This message was deleted"
                                : msg['text'] ?? '',
                            isMe,
                            time,
                            isDeleted,
                            msg['fileUrl'],
                            msg['fileName'],
                            msg['fileType'],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          _buildInputBox(),
        ],
      ),
    );
  }

  /// ================= MESSAGE OPTIONS =================
  void _showMessageOptions({required String messageId, required bool isMe}) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Delete for me"),
                onTap: () {
                  Navigator.pop(context);
                  deleteForMe(messageId);
                },
              ),

              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text("Delete for everyone"),
                  onTap: () {
                    Navigator.pop(context);
                    deleteForEveryone(messageId);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _chatBubble(
    String message,
    bool isMe,
    String time,
    bool isDeleted,
    String? fileUrl,
    String? fileName,
    String? fileType,
  ) {
    final bool isFileMessage = fileUrl != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,

      child: Column(
        spacing: 10,
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,

        children: [
          /// ================= IMAGE FILE =================
          if (fileUrl != null && fileType == "image")
            GestureDetector(
              onTap: () {
                downloadAndOpen(fileUrl, fileName ?? "file.image");
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: Image.network(
                    fileUrl,
                    height: 220,
                    width: 210,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          /// ================= PDF FILE =================
          if (fileUrl != null && fileType == "pdf")
            GestureDetector(
              onTap: () {
                downloadAndOpen(
                  fileUrl,
                  fileName ??
                      "file_${DateTime.now().millisecondsSinceEpoch}.pdf",
                );
              },

              child: Container(
                width: 240,

                margin: const EdgeInsets.symmetric(vertical: 4),

                padding: const EdgeInsets.all(6),

                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 34,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            fileName ?? "PDF File",

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            "Tap to open",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          /// ================= OTHER FILE =================
          if (fileUrl != null && fileType != "image" && fileType != "pdf")
            GestureDetector(
              onTap: () {
                downloadAndOpen(fileUrl, fileName ?? "file.pdf");
              },

              child: Container(
                width: 240,

                margin: const EdgeInsets.symmetric(vertical: 4),

                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file,
                      color: Colors.blue,
                      size: 34,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            fileName ?? "File",

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            "Tap to open",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          /// ================= TEXT MESSAGE =================
          if (!isFileMessage || message.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),

              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

              constraints: const BoxConstraints(maxWidth: 280),

              decoration: BoxDecoration(
                color: isDeleted
                    ? (isDark
                          ? AppTheme.darkTheme.primaryColorDark
                          : Colors.white)
                    : isMe
                    ? (isDark
                          ? Color(0xFF375FFF) // WhatsApp Dark Sent Bubble
                          : AppTheme.lightTheme.primaryColorLight)
                    : (isDark
                          ? AppTheme
                                .darkTheme
                                .primaryColorDark // WhatsApp Dark Received Bubble
                          : Colors.white),

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

                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isDeleted
                          ? isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500
                          : isMe
                          ? isDark
                                ? Colors.white
                                : Colors.grey.shade700
                          : isDark
                          ? Colors.white
                          : Colors.grey.shade700,

                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    time,
                    style: TextStyle(
                      color: isDeleted
                          ? Colors.grey
                          : isMe
                          ? isDark
                                ? Colors.grey.shade300
                                : Colors.grey
                          : Colors.grey,

                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

          /// ================= FILE TIME =================
          if (isFileMessage)
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 6, right: 6),

              child: Text(
                time,

                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  /// ================= INPUT =================

  Widget _buildInputBox() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),

      color: isDark ? AppTheme.darkTheme.primaryColorDark : Colors.white,

      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            onPressed: () {},
          ),

          /// TEXT FIELD
          Expanded(
            child: TextField(
              controller: messageController,

              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
              ),
            ),
          ),

          IconButton(icon: const Icon(Icons.attach_file), onPressed: pickFile),

          /// SEND BUTTON
          GestureDetector(
            onTap: sendMessage,

            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor,
                shape: BoxShape.circle,
              ),

              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
