# 🐱 Fat Cat App

A mobile application to help monitor and manage your cat's food intake. 🍽️🐾

---

## 📖 Description

**Fat Cat** is a Flutter-based mobile app designed to help cat owners track and manage their cats' daily food consumption. It helps prevent overfeeding and maintain a healthy diet for your feline friend. 🐈❤️

---

## ✨ Key Features

- 🥫 Track daily food intake (wet and dry food)
- ⚖️ Monitor feeding limits
- 🚨 Visual warnings for overfeeding
- 🎨 Simple and intuitive user interface
- 📊 Daily food statistics
- 💾 Firebase Integration for data storage
- 🔔 Push Notifications support
- 🔄 Real-time data synchronization

---

## 🛠️ Technical Specifications

- **Framework:** Flutter
- **Version:** 1.0.0+1
- **Minimum Android SDK:** 21
- **Dependencies:**
    - `cupertino_icons: ^1.0.8`
    - `http: ^1.1.0`
    - `fl_chart: ^0.65.0`

---

## 📥 Installation

1. Download the APK from the releases section.
2. Install on Android device (Android 5.0 or higher).

---

## 💻 Development Setup

### Prerequisites

1. Flutter SDK
2. Firebase Project Setup
   - Create a new Firebase project
   - Download `google-services.json`
   - Place it in `android/app/` directory

```
# Get dependencies
flutter pub get

# Run the app
flutter run

# Build release APK
flutter build apk --release
```

---

## 🔐 Required Permissions

- Internet access 🌐
- Notification permissions 🔔
- Post notifications (Android) 📳
- Background services 🔄

---

## ⚙️ Firebase Configuration

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add an Android app to your Firebase project
3. Download the `google-services.json` file
4. Place the file in `android/app/` directory
5. Run the app to verify Firebase integration

---

## 📝 Note

This is a private application and is not published on pub.dev.  
For more information about Flutter development, visit: https://flutter.dev/docs

---
