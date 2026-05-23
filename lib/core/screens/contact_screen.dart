import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:chat_messaging/core/screens/add_new_contact.dart';
import 'package:chat_messaging/core/screens/chat_screen.dart';
import 'package:chat_messaging/core/services/user_service.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  static const String name = '/contacts';

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  bool isSearchVisible = false;

  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  String? selectedContactId;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  /// ================= DELETE CONTACT =================
  Future<void> deleteContact(String contactId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .doc(contactId)
        .delete();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Contact deleted")));
  }

  void clearSelection() {
    setState(() {
      selectedContactId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return GestureDetector(
      onTap: clearSelection,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,

        /// ================= APP BAR =================
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,

          title: isSearchVisible
              ? TextField(
                  controller: searchController,
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      searchText = value.toLowerCase();
                    });
                  },

                  decoration: InputDecoration(
                    hintText: "Search contact...",

                    isDense: true, // ✅ reduce height

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8, // ✅ decrease vertical padding
                    ),
                  ),
                )
              : Text("Contacts", style: AppTextStyles.appBarTitle),

          actions: [
            IconButton(
              icon: Icon(isSearchVisible ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  isSearchVisible = !isSearchVisible;
                  if (!isSearchVisible) {
                    searchController.clear();
                    searchText = '';
                  }
                });
              },
            ),
          ],
        ),

        /// ================= FLOATING BUTTON =================
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.lightTheme.primaryColor,
          onPressed: () {
            Navigator.pushNamed(context, AddNewContactScreen.name);
          },
          child: const Icon(Icons.person_add_alt_1, color: Colors.white),
        ),

        /// ================= BODY =================
        body: StreamBuilder<QuerySnapshot>(
          stream: contactStream,
          builder: (context, snapshot) {
            final contacts = snapshot.data?.docs ?? [];

            final filteredContacts = contacts.where((contact) {
              final data = contact.data() as Map<String, dynamic>;

              final firstName = (data['firstName'] ?? '')
                  .toString()
                  .toLowerCase();
              final lastName = (data['lastName'] ?? '')
                  .toString()
                  .toLowerCase();
              final phone = (data['phoneNumber'] ?? '')
                  .toString()
                  .toLowerCase();

              return firstName.contains(searchText) ||
                  lastName.contains(searchText) ||
                  phone.contains(searchText);
            }).toList();

            return ListView(
              children: [
                const SizedBox(height: 20),

                /// ================= TOP OPTIONS =================
                buildTopOption(
                  icon: Icons.group,
                  title: "New Group",
                  color: Colors.green,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Create Group Coming Soon")),
                    );
                  },
                ),

                buildTopOption(
                  icon: Icons.person_add,
                  title: "New Contact",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, AddNewContactScreen.name);
                  },
                ),

                buildTopOption(
                  icon: Icons.groups,
                  title: "New Community",
                  color: Colors.orange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Create Community Coming Soon"),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Text(
                    "Contacts on Chat",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator()),

                if (filteredContacts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("No contacts found")),
                  ),

                ...filteredContacts.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final firstName = data['firstName'] ?? '';
                  final lastName = data['lastName'] ?? '';
                  final phone = data['phoneNumber'] ?? '';
                  final contactId = doc.id;

                  final isSelected = selectedContactId == contactId;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        firstName.isNotEmpty ? firstName[0].toUpperCase() : "?",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    title: Text("$firstName $lastName"),
                    subtitle: Text(phone),

                    /// ================= DELETE ICON =================
                    trailing: isSelected
                        ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await deleteContact(contactId);
                              clearSelection();
                            },
                          )
                        : null,

                    /// ================= TAP = CHAT =================
                    onTap: () async {
                      if (isSelected) {
                        clearSelection();
                        return;
                      }

                      final receiverId = await UserService.getUserIdByPhone(
                        phone,
                      );

                      if (receiverId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("User not found in system"),
                          ),
                        );
                        return;
                      }

                      Navigator.pushNamed(
                        context,
                        ChatScreen.name,
                        arguments: {
                          "receiverId": receiverId,
                          "receiverName": "$firstName $lastName".trim(),
                          "receiverImage": "",
                        },
                      );
                    },

                    /// ================= LONG PRESS = SELECT =================
                    onLongPress: () {
                      setState(() {
                        selectedContactId = contactId;
                      });
                    },
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// TOP OPTION TILE
Widget buildTopOption({
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: CircleAvatar(
      radius: 24,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white),
    ),

    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

    onTap: onTap,
  );
}
