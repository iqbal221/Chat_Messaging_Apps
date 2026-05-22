import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  static const String name = "/chat";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();

    print("🔥 MY UID: $myId");
    print("🔥 RECEIVER UID: ${widget.receiverId}");
    print("🔥 CHAT ID: ${getChatId()}");
  }

  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  String get myId => FirebaseAuth.instance.currentUser!.uid;

  /// CREATE UNIQUE CHAT ID
  String getChatId() {
    List ids = [myId, widget.receiverId];
    ids.sort();
    return ids.join("_");
  }

  /// SEND MESSAGE
  Future<void> sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    final chatId = getChatId();

    messageController.clear();

    /// SAVE MESSAGE
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          "text": text,
          "senderId": myId,
          "timestamp": FieldValue.serverTimestamp(),
        });

    /// SAVE LAST MESSAGE INFO
    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      "participants": [myId, widget.receiverId],
      "lastMessage": text,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    scrollToBottom();
  }

  /// GET REALTIME MESSAGES
  Stream<QuerySnapshot> getMessages() {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(getChatId())
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// AUTO SCROLL
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
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      /// APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.receiverImage.isNotEmpty
                  ? NetworkImage(widget.receiverImage)
                  : null,
              child: widget.receiverImage.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Text(
                  "online",
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),

      /// BODY
      body: Column(
        children: [
          /// MESSAGES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                /// AUTO SCROLL WHEN NEW MESSAGE ARRIVES
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollToBottom();
                });

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;

                    final isMe = msg['senderId'] == myId;

                    /// FORMAT TIME
                    Timestamp? timestamp = msg['timestamp'];

                    String formattedTime = '';

                    if (timestamp != null) {
                      DateTime dateTime = timestamp.toDate();

                      formattedTime = DateFormat('hh:mm a').format(dateTime);
                    }

                    return _chatBubble(msg['text'] ?? '', isMe, formattedTime);
                  },
                );
              },
            ),
          ),

          /// INPUT BOX
          _buildInputBox(),
        ],
      ),
    );
  }

  /// CHAT BUBBLE
  Widget _chatBubble(String message, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

        constraints: const BoxConstraints(maxWidth: 280),

        decoration: BoxDecoration(
          color: isMe ? Colors.green : Colors.white,

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

          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            /// MESSAGE
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 5),

            /// TIME
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// INPUT BOX
  Widget _buildInputBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

      color: Colors.white,

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

          IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),

          /// SEND BUTTON
          GestureDetector(
            onTap: sendMessage,

            child: Container(
              padding: const EdgeInsets.all(10),

              decoration: const BoxDecoration(
                color: Colors.green,
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
