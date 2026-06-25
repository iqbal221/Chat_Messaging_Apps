import 'package:chat_messaging/common/widget/dark_light_theme_button.dart';
import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:chat_messaging/core/theme/theme_provider.dart';
import 'package:chat_messaging/features/contacts/presentation/screens/add_new_contact.dart';
import 'package:chat_messaging/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:chat_messaging/features/contacts/presentation/screens/contact_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: clearSelection,
          child: Scaffold(
            backgroundColor: isDark
                ? AppTheme.darkTheme.scaffoldBackgroundColor
                : AppTheme.lightTheme.scaffoldBackgroundColor,

            /// ================= APP BAR =================
            appBar: AppBar(
              elevation: 0,
              backgroundColor: isDark
                  ? AppTheme.darkTheme.appBarTheme.backgroundColor
                  : AppTheme.lightTheme.appBarTheme.backgroundColor,

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
                // search button
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

                // dark or light theme button
                DarkLightThemeButton(),
              ],
            ),

            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('contacts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, contactSnapshot) {
                if (contactSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final contacts = contactSnapshot.data?.docs ?? [];

                return ListView(
                  children: [
                    const SizedBox(height: 20),

                    ContactGroup(
                      icon: Icons.group,
                      title: "New Group",
                      color: Colors.green,
                      onTap: () {},
                    ),

                    ContactGroup(
                      icon: Icons.person_add,
                      title: "New Contact",
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(context, AddNewContactScreen.name);
                      },
                    ),

                    ContactGroup(
                      icon: Icons.groups,
                      title: "New Community",
                      color: Colors.orange,
                      onTap: () {},
                    ),

                    const SizedBox(height: 10),

                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Text(
                        "Contacts on Chat",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    if (contacts.isEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: const Center(
                          child: Text(
                            "No contacts found",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ...contacts.map((contactDoc) {
                      final contact = contactDoc.data() as Map<String, dynamic>;

                      final receiverId = contact['receiverId'];

                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(receiverId)
                            .snapshots(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData ||
                              !userSnapshot.data!.exists) {
                            return const SizedBox();
                          }

                          final user =
                              userSnapshot.data!.data() as Map<String, dynamic>;

                          final firstName = user['firstName'] ?? '';

                          final lastName = user['lastName'] ?? '';

                          final phone = user['phoneNumber'] ?? '';

                          final imageUrl = user['profileImage'] ?? '';

                          final fullName = "$firstName $lastName".trim();

                          // Search filter
                          if (searchText.isNotEmpty &&
                              !fullName.toLowerCase().contains(searchText) &&
                              !phone.toLowerCase().contains(searchText)) {
                            return const SizedBox();
                          }

                          final isSelected = selectedContactId == contactDoc.id;

                          return Column(
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
                                      fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      phone,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        color: isDark
                                            ? Color(0xFFADB5BD)
                                            : Colors.grey.shade900,
                                      ),
                                    ),
                                  ],
                                ),

                                trailing: isSelected
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          await deleteContact(contactDoc.id);

                                          clearSelection();
                                        },
                                      )
                                    : null,

                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    ChatScreen.name,
                                    arguments: {
                                      "receiverId": receiverId,
                                      "receiverName": fullName,
                                      "receiverImage": imageUrl,
                                    },
                                  );
                                },

                                onLongPress: () {
                                  setState(() {
                                    selectedContactId = contactDoc.id;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
