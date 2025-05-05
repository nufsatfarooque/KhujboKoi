# KhujboKoi
KhujboKoi is a hyper-local mobile platform designed to connect residents, renters, homeowners, and restaurant owners within a specific community. It streamlines access to rental listings, local restaurant information, and a community bulletin board for real-time neighborhood updates. Built with Flutter and Firebase, the app supports Android, iOS, and web platforms, offering a seamless user experience with English and Bengali localization.

## Overview

**KhujboKoi** addresses the challenges of finding reliable housing, discovering local restaurants, and sharing community updates in urban neighborhoods. It offers a structured, all-in-one solution — replacing fragmented platforms like Craigslist or unmoderated social media groups.

### Key Functionalities

- **Rental Marketplace**  
  Browse, filter, and apply for verified flat listings. Homeowners can easily manage and edit their own posts.

- **Restaurant Directory**  
  Discover nearby eateries with details such as menus, business hours, categories, and reviews — all managed by restaurant owners.

- **Community Board**  
  Share real-time notices, emergency alerts, event announcements, lost & found items, or neighborhood Q&A.

- **In-App Messaging**  
  Enables direct, real-time communication between renters, landlords, and restaurant owners — powered by Firebase.

---
## User Roles and Functionality

KhujboKoi supports four primary user roles, each with distinct features:

### 1. Residents (General Users)
- **Sign Up/Login**  
  Register using email/password or social login (Google/Facebook, if configured). Email verification required.

- **Profile Management**  
  Edit name, contact information, and avatar.

- **Rental Marketplace**  
  - Browse and filter available flat listings.  
  - View listing details including images, rent, and address.  
  - Submit rental inquiries directly to landlords via in-app messaging.

- **Restaurant Directory**  
  - Search and filter restaurants.  
  - View menus, operating hours, and user reviews.  
  - Submit 1–5 star ratings and write text reviews.

- **Community Board**  
  - Post updates, alerts, or questions.  
  - Comment on and react to posts.

- **Messaging**  
  - Chat in real time with landlords and restaurant owners.

---

### 2. Homeowners (Landlords)
Includes all features available to **Residents**, plus:

- **Owner Dashboard**  
  - Create, edit, or delete property listings.  
  - Upload up to 10 photos per listing.  
  - Set rental details such as price, bedrooms, availability, and amenities.  
  - Receive and respond to rental inquiries via the in-app chat feature.

---

### 3. Restaurant Owners
Includes all features available to **Residents**, plus:

- **Restaurant Portal**  
  - Register and verify as a restaurant owner.  
  - Upload menus, business hours, photos, and cuisine type.  
  - Respond to customer reviews in real time.  
  - Update restaurant details like name, pricing, and category.

- **Messaging**  
  - Engage with potential and existing customers through in-app messaging.

---

### 4. Admins (Moderators)
- **Moderation Tools**  
  - Flag or remove inappropriate listings, reviews, or community posts.  
  - Temporarily or permanently suspend repeat offenders.

- **Analytics Dashboard**  
  - Track statistics such as active listings, user sign-ups, and top-rated restaurants.

---

## How to Create Users

### In-App Registration
1. **Launch the App**  
   Available on Android, iOS, or web.

2. **Sign Up**  
   Navigate to the "Sign Up" screen and enter:
   - Name  
   - Email  
   - Password  
   - (Optional) Sign up with Google/Facebook if available.

3. **Email Verification**  
   Check your email inbox and click the verification link to activate the account.

4. **Set Up Profile**  
   Log in, update contact information, and upload an avatar.

5. **Role-Specific Access**  
   - **Homeowners**: Navigate to "Owner Dashboard" to create property listings.  
   - **Restaurant Owners**: Use the "Restaurant Portal" to register and manage a restaurant.  
   - **Admins**: Must be manually assigned via Firebase.

---

### Manual Creation (For Testing)

#### Using Firebase Console
1. Log in to [Firebase Console](https://console.firebase.google.com).
2. Go to **Authentication > Users**.
3. Click **"Add User"**, then enter:
   - Email  
   - Password  
4. Send a password reset email to simulate email verification.

#### Assign Roles
1. Go to **Firestore > users/{userId}**.
2. Create or update the user document with fields such as:
   - `role`: `"resident"`, `"homeowner"`, `"restaurant_owner"`, or `"admin"`  
   - `name`, `
---

## Setup Instructions

### Prerequisites

Ensure the following are installed and configured:

- Flutter SDK (v3.x.x or latest stable)
- Dart (compatible with your Flutter version)
- Android Studio / Xcode (for mobile development)
- Firebase account and configured project
- Node.js (for Firebase CLI, optional but recommended)
- Git

---

### Steps

#### 1. Clone the Repository

```bash
git clone https://github.com/nufsatfarooque/KhujboKoi.git
cd KhujboKoi
```

#### 2. Install Dependencies:

```bash
flutter pub get
```
### Running the App
#### 1. Start an Emulator/Simulator or connect a physical device.
#### 2. Run the App:
````bash
flutter run
````

