# 💬 Chat Messaging App

A modern real-time chat application built with **Flutter** and **Firebase**. The app allows users to register, log in, manage contacts, exchange text messages, send images, PDFs, and other files, and manage their profile with a clean UI supporting both Light and Dark themes.

---

## 📱 Features

### 🔐 Authentication

* Email & Password Registration
* Email & Password Login
* Firebase Authentication
* Logout
* Loading Indicators
* Form Validation

---

### 👤 User Profile

* Create Profile
* Update Profile
* Upload Profile Picture
* Firebase Storage / Cloudinary Image Upload
* Light & Dark Mode Avatar

---

### 👥 Contacts

* Add New Contact
* Search Registered Users by Phone Number
* Prevent Duplicate Contacts
* Prevent Adding Yourself
* Contact List

---

### 💬 Chat

* Real-time Messaging
* One-to-One Chat
* Date Headers (Today, Yesterday, Date)
* Auto Scroll to Latest Message
* Message Timestamp
* Delete for Me
* Delete for Everyone
* Long Press Message Options

---

### 📂 File Sharing

* Send Images
* Send PDF Files
* Send Other Documents
* Download Files
* Open Files Inside Device
* Cloudinary File Upload

---

### 🎨 UI

* Responsive Design
* Light Theme
* Dark Theme
* Inter Font
* Material Design 3
* Modern Chat Bubble Design

---

## 🛠️ Technologies Used

* Flutter
* Dart
* Firebase Authentication
* Cloud Firestore
* Cloudinary
* Provider
* Dio
* HTTP
* File Picker
* Open FileX
* Path Provider
* Intl
* Google Fonts
* Intl Phone Field

---

## 📂 Project Structure

```
lib/
│
├── core/
│   ├── constants/
│   ├── screens/
│   ├── theme/
│   └── widgets/
│
├── features/
│   ├── auth/
│   ├── chat/
│   ├── contacts/
│   ├── profile/
│   └── settings/
│
├── providers/
│
├── services/
│
└── main.dart
```

---

## 🚀 Getting Started

### Clone Repository

```bash
git clone https://github.com/yourusername/ChatVani.git
```

### Install Packages

```bash
flutter pub get
```

### Configure Firebase

Create a Firebase project and enable:

* Authentication (Email/Password)
* Cloud Firestore
* Firebase Storage (Optional)

Download:

* `google-services.json` (Android)
* `GoogleService-Info.plist` (iOS)

Place them in the correct project directories.

---

### Configure Cloudinary

Update your Cloudinary credentials:

```dart
const cloudName = "YOUR_CLOUD_NAME";
const uploadPreset = "YOUR_UPLOAD_PRESET";
```

---

### Run Project

```bash
flutter run
```

---

## 📦 Packages

```yaml
firebase_core
firebase_auth
cloud_firestore
provider
dio
http
file_picker
open_filex
path_provider
intl
intl_phone_field
google_fonts
image_picker
cached_network_image
```

---

## 📸 Screens

* Login
* Register
* Home
* Contact List
* Add Contact
* Chat Screen
* Profile
* Settings

---

## 🔥 Firebase Collections

### users

```text
users
   uid
      firstName
      lastName
      email
      phoneNumber
      profileImage
      createdAt
```

---

### chats

```text
chats
   chatId
      participants
      lastMessage
      updatedAt
```

---

### messages

```text
messages
   messageId
      senderId
      receiverId
      text
      fileUrl
      fileName
      fileType
      timestamp
      isDeleted
      deletedFor
```

---

### contacts

```text
users
   uid
      contacts
         contactId
            receiverId
            createdAt
```

---

## 🎯 Future Improvements

* Voice Messages
* Video Calling
* Audio Calling
* Push Notifications
* Emoji Picker
* Message Reactions
* Typing Indicator
* Read Receipts
* Online/Offline Status
* Group Chat
* Message Search
* Reply to Messages
* Forward Messages
* Chat Wallpaper
* Message Encryption

---

## 👨‍💻 Developer

**MD Zahed**

Flutter Developer

GitHub: https://github.com/yourusername

LinkedIn: https://linkedin.com/in/yourusername

---

## 📄 License

This project is licensed under the MIT License.

---

⭐ If you like this project, don't forget to give it a star on GitHub!
