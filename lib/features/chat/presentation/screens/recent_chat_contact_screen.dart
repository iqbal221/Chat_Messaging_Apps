import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:chat_messaging/features/contacts/presentation/screens/add_new_contact.dart';
import 'package:chat_messaging/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecentChatScreen extends StatefulWidget {
  const RecentChatScreen({super.key});

  static const String name = "/recent-chat";

  @override
  State<RecentChatScreen> createState() => _RecentChatScreenState();
}

class _RecentChatScreenState extends State<RecentChatScreen> {
  String get myId => FirebaseAuth.instance.currentUser!.uid;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  String formatChatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";

    final dateTime = timestamp.toDate();
    final now = DateTime.now();

    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(dateTime);
    }

    if (difference.inDays == 1) {
      return "Yesterday";
    }

    return DateFormat('dd/MM/yy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final chatStream = FirebaseFirestore.instance
        .collection("chats")
        .where("participants", arrayContains: myId)
        .orderBy("updatedAt", descending: true)
        .snapshots();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkTheme.scaffoldBackgroundColor
          : AppTheme.lightTheme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: isDark
            ? AppTheme.darkTheme.appBarTheme.backgroundColor
            : AppTheme.lightTheme.appBarTheme.backgroundColor,
        title: Text("Chats", style: AppTextStyles.titleLarge),
      ),

      /// ================= FLOATING BUTTON =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.lightTheme.primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, AddNewContactScreen.name);
        },
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),

      body: Column(
        children: [
          /// 🔍 SEARCH BOX (TOP OF BODY)
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: "Search here",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              ),
            ),
          ),

          /// 📩 CHAT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No conversations yet"));
                }

                final docs = snapshot.data!.docs;

                // ✅ Remove duplicates (keep only latest per receiverId)
                final Map<String, Map<String, dynamic>> latestChats = {};

                for (var doc in docs) {
                  final chat = doc.data() as Map<String, dynamic>;

                  final participants = List<String>.from(
                    chat["participants"] ?? [],
                  );

                  final receiverId = participants.firstWhere(
                    (id) => id != myId,
                    orElse: () => "",
                  );

                  if (receiverId.isEmpty) continue;

                  final updatedAt =
                      (chat["updatedAt"] as Timestamp?)?.toDate() ??
                      DateTime(0);

                  if (!latestChats.containsKey(receiverId)) {
                    latestChats[receiverId] = {
                      "chat": chat,
                      "receiverId": receiverId,
                      "updatedAt": updatedAt,
                    };
                  } else {
                    final existing =
                        latestChats[receiverId]!["updatedAt"] as DateTime;

                    if (updatedAt.isAfter(existing)) {
                      latestChats[receiverId] = {
                        "chat": chat,
                        "receiverId": receiverId,
                        "updatedAt": updatedAt,
                      };
                    }
                  }
                }

                final uniqueChats = latestChats.values.toList();

                uniqueChats.sort(
                  (a, b) => (b["updatedAt"] as DateTime).compareTo(
                    a["updatedAt"] as DateTime,
                  ),
                );

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10),

                  itemCount: uniqueChats.length,

                  itemBuilder: (context, index) {
                    final chatData =
                        uniqueChats[index]["chat"] as Map<String, dynamic>;

                    final receiverId = uniqueChats[index]["receiverId"];

                    final Timestamp? updatedAt =
                        chatData["updatedAt"] as Timestamp?;

                    final lastMessage =
                        chatData["lastMessage"] ?? "No messages";

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          .doc(receiverId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox();
                        }

                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>?;

                        if (userData == null) {
                          return const SizedBox();
                        }

                        final firstName = userData["firstName"] ?? "";
                        final lastName = userData["lastName"] ?? "";
                        final phoneNumber = userData["phoneNumber"] ?? "";
                        final imageUrl = userData["profileImage"] ?? "";

                        final fullName = "$firstName $lastName".trim();

                        final searchText = "$fullName $phoneNumber"
                            .toLowerCase();

                        /// 🔍 SEARCH FILTER
                        if (searchQuery.isNotEmpty &&
                            !searchText.contains(searchQuery)) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.blue.shade100,
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Center(
                                            child: Text(
                                              firstName.isNotEmpty
                                                  ? firstName[0].toUpperCase()
                                                  : "?",
                                            ),
                                          ),
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fullName.isNotEmpty
                                          ? fullName
                                          : phoneNumber,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                        color: isDark
                                            ? Color(0xFFADB5BD)
                                            : Colors.grey.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  formatChatTime(updatedAt),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        receiverId: receiverId,
                                        receiverName: fullName,
                                        receiverImage: imageUrl,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
