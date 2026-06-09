# UniPath - NASC College Counselling and Wellness App

## Project Overview

**UniPath** is a Flutter mobile application designed for NASC College students to access counselling and wellness services. The app features student authentication, learning style assessments, appointment booking, a chatbot support system, and comprehensive admin dashboard for monitoring analytics and feedback.

## Core Purpose

UniPath bridges students and counsellors through a modern mobile-first platform that:
- Enables secure student authentication via phone/email OTP
- Assesses student learning styles through interactive quizzes
- Facilitates appointment booking with counsellors
- Provides real-time feedback and thought-tracking systems
- Offers AI-powered chatbot support
- Supplies admin analytics and examination workflows
- Generates CSV reports for institutional insights

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.12+ with Material Design 3 |
| Backend | Firebase (Auth, Firestore, Messaging) |
| Local Storage | SharedPreferences |
| Email | Mailer package (configured but not production-ready) |
| State | Stateful widgets (no Provider/GetX/Riverpod) |

## Architecture & Structure

### Directory Layout

```
lib/
├── main.dart                    # App entry point, Firebase initialization
├── firebase_options.dart        # Firebase config (auto-generated)
├── theme.dart                   # AppColors, AppTheme definitions
│
├── screens/                     # All UI screens
│   ├── splash_screen.dart       # Auto-navigation based on auth status
│   ├── welcome_screen.dart      # Entry point for new users
│   ├── login_screen.dart        # Phone-based login with OTP
│   ├── email_login_screen.dart  # Email-based login
│   ├── email_otp_screen.dart    # Email OTP verification
│   ├── otp_screen.dart          # Phone OTP verification
│   ├── register_screen.dart     # Student registration form
│   ├── dashboard_screen.dart    # Main student dashboard (post-login)
│   ├── quiz_screen.dart         # Learning style quiz (mandatory before dashboard)
│   ├── result_screen.dart       # Quiz results
│   ├── profile_screen.dart      # Student profile view/edit
│   ├── book_counselling_screen.dart    # Schedule appointments
│   ├── appointments_screen.dart        # View booked appointments
│   ├── feedback_thoughts_screen.dart   # Feedback/thoughts hub
│   ├── feedback_screen.dart     # Feedback submission form
│   ├── thoughts_screen.dart     # Thoughts/journal submission
│   ├── chatbot_screen.dart      # AI chatbot conversation
│   ├── admin_login_screen.dart  # Admin authentication
│   ├── admin_dashboard_screen.dart     # Admin home
│   ├── admin_analytics_screen.dart     # Real-time analytics
│   ├── admin_examination_screen.dart   # Examination management
│   ├── admin_appointments_screen.dart  # Admin view of all appointments
│   ├── admin_feedback_screen.dart      # Admin view of all feedback
│   └── admin_csv_screen.dart    # CSV report generation
│
├── services/                    # Business logic & Firebase integration
│   ├── auth_service.dart        # Phone/email auth, profile CRUD, OTP logic
│   ├── email_otp_service.dart   # Email OTP generation/verification
│   ├── csv_service.dart         # CSV export functionality
│   ├── chatbot_service.dart     # AI chatbot API integration
│   └── quotes_service.dart      # Daily quotes for motivation
│
└── assets/
    └── icon/
        └── app_icon.png         # App launcher icon (used by flutter_launcher_icons)
```

### Firestore Collections

```
students/
  doc_id: "+91{mobile}" or "{email}"
  ├── mobile: String
  ├── name: String
  ├── email: String
  ├── gender: String
  ├── dob: String (YYYY-MM-DD)
  ├── department: String
  ├── year: String (1st, 2nd, 3rd, 4th)
  ├── major12th: String
  ├── yearOfPassing: String
  ├── parentContact: String
  ├── learningStyle: String (Visual/Auditory/Kinesthetic - optional)
  ├── createdAt: ISO8601 timestamp
  └── isProfileComplete: Boolean

learning_style_results/
  doc_id: "{email}" or "{mobile}"
  ├── learningStyle: String (Visual/Auditory/Kinesthetic)
  ├── scores: { visual: Number, auditory: Number, kinesthetic: Number }
  ├── completedAt: ISO8601 timestamp
  └── quizVersion: Number

appointments/
  doc_id: auto-generated
  ├── studentMobile: String
  ├── studentName: String
  ├── date: String (YYYY-MM-DD)
  ├── slot: String (Slot 1/2/3/etc)
  ├── status: String (booked/completed/cancelled)
  ├── bookedAt: ISO8601 timestamp
  └── notes: String (optional)

feedback/
  doc_id: auto-generated
  ├── studentMobile: String
  ├── studentName: String
  ├── feedbackText: String
  ├── submittedAt: ISO8601 timestamp
  ├── type: String (feedback/thought)
  └── tags: Array<String> (optional categorization)

email_otps/
  doc_id: "{email}"
  ├── otp: String (6-digit)
  ├── expiresAt: ISO8601 timestamp (10 minutes from creation)
  └── createdAt: ISO8601 timestamp

admin_users/
  doc_id: auto-generated or email
  ├── email: String
  ├── password: String (hashed - implementation needed)
  ├── role: String (admin/counselor)
  └── createdAt: ISO8601 timestamp
```

## Key Features & Implementation Details

### 1. Authentication Flow

**Phone-based (Primary)**
- User enters mobile → `AuthService.sendOTP()` triggers Firebase Phone Auth
- Firebase sends SMS with code
- User enters OTP → `AuthService.verifyOTP()` validates and signs in
- On success: profile check → registration or dashboard

**Email-based (Alternative)**
- User enters email → `AuthService.sendEmailOTP()` generates 6-digit OTP
- OTP stored in `email_otps` collection with 10-min expiry
- User enters OTP → `AuthService.verifyEmailOTP()` validates
- On success: profile check → registration or dashboard

**Important Notes**
- Email OTP is stored in Firestore (not actually emailed in current code) — production needs email service integration
- Phone auth uses Firebase's built-in SMS verification
- Credentials cached locally via `SharedPreferences` under `profile` key for fast load

### 2. Learning Style Quiz

**Workflow**
1. Mandatory on first dashboard access (unless `quizJustCompleted: true`)
2. Covers 3 learning styles: Visual, Auditory, Kinesthetic
3. 3-section scoring system for balanced assessment
4. Results stored in `learning_style_results` collection
5. Can be checked via both email and mobile identifiers

**Files**
- `quiz_screen.dart` — Quiz UI and questions
- `result_screen.dart` — Score display and navigation

### 3. Dashboard & Navigation

**Student Dashboard Features**
- Greeting with name
- Feature grid: Book Counselling, Appointments, Feedback/Thoughts, Chatbot
- Upcoming session banner (static placeholder)
- Bottom navigation bar (4 tabs)
- Daily motivation quote on first access each day

**Navigation Pattern**
- All screens use `Navigator.push()` (maintains history)
- Logout uses `pushAndRemoveUntil()` to clear stack
- Quiz completion uses `pushReplacement()` to prevent back loops

### 4. Caching Strategy

**Local Profile Cache**
- Stored in `SharedPreferences` under key `profile`
- Stores complete student object for fast offline access
- Cleared on logout or when department field detects outdated schema
- Used to skip Firestore fetches on app restart

**Cache Invalidation**
- Old department values clear cache automatically (schema evolution)
- Manual clear via `AuthService.clearCache()`
- Updated on successful registration/profile update

### 5. Admin System

**Admin Screens**
- `admin_login_screen.dart` — Currently basic (security notes below)
- `admin_dashboard_screen.dart` — Home with navigation
- `admin_analytics_screen.dart` — Real-time student/appointment metrics
- `admin_examination_screen.dart` — Exam/quiz management (Firebase-connected)
- `admin_csv_screen.dart` — Report generation & export
- `admin_appointments_screen.dart` — Full appointment management
- `admin_feedback_screen.dart` — Feedback review interface

**CSV Export** (`csv_service.dart`)
- Generates formatted reports from Firestore data
- Supports filtering by date/department
- Exported via `share_plus` package
- Production: may need cloud functions for large datasets

### 6. Real-time Features

**Firebase Messaging** (configured but minimal usage)
- Set up in `firebase_core` initialization
- Can be extended for push notifications

**Firestore Listeners** (optional/not fully implemented)
- Streams can replace snapshot calls for live updates
- Consider for analytics dashboard refresh

## Common Patterns & Conventions

### Service Methods

All Firebase operations are in `*_service.dart` files. They are **static** and follow this pattern:

```dart
static Future<ReturnType> methodName({required String param}) async {
  try {
    // Firebase operation
    return result;
  } catch (e) {
    // Rethrow or handle
    rethrow;
  }
}
```

### Error Handling

- Services throw exceptions for caller to handle
- UI shows SnackBar or AlertDialog for user feedback
- Network errors gracefully default to cached data where applicable

### Theme Colors

Defined in `theme.dart`:
- `AppColors.primary` — Main brand color
- `AppColors.primaryDark` — Darker shade
- `AppColors.primaryLight` — Lighter shade
- `AppColors.white`, `AppColors.grey`, `AppColors.background`
- Feature colors: `AppColors.blue`, `AppColors.orange`, `AppColors.green`

Use `AppTheme.theme` for consistent Material Design theming.

### Widgets

- **Stateless**: Reusable, no lifecycle
- **Stateful**: Screens and complex components with `initState`, state updates
- **Private widgets**: Prefixed with `_` (e.g., `_FeatureCard`)

## Important Notes & Known Issues

### Security Concerns (Production Notes)

1. **Admin authentication** — Current `admin_login_screen.dart` is placeholder; implement:
   - Password hashing (bcrypt/Argon2)
   - JWT or session tokens
   - Admin role verification in Firestore rules

2. **Firestore Rules** — No security rules visible; add:
   - Students can only read/write own profile
   - Admin endpoints restricted by role
   - Email OTP collection: TTL-based cleanup

3. **Email OTP** — Currently stored in Firestore, not sent via email
   - Integrate with SendGrid / Firebase Extensions for production
   - Implement rate limiting on OTP requests

4. **Firebase Credentials** — Firebase config in `firebase_options.dart` is public
   - Firestore rules are the primary security layer
   - No API keys or secrets in code ✓

### Code Quirks & TODOs

- **Quote service** — May have placeholder or hardcoded quotes; expand with API
- **Chatbot service** — Structure exists; actual NLP/API integration needed
- **Email send** — Mailer package added but not fully integrated; use Firebase Extensions
- **Offline mode** — Caching works but no explicit sync strategy for changes made offline

## Development Workflow

### Getting Started

1. **Install Flutter** (3.12+)
   ```bash
   flutter --version
   flutter pub get
   ```

2. **Configure Firebase**
   ```bash
   flutterfire configure
   # Selects platforms and regenerates firebase_options.dart
   ```

3. **Run App**
   ```bash
   flutter run
   # Or specify device: flutter run -d <device_id>
   ```

### Testing Locally

- **Phone login test**: Use Firebase Console to generate test numbers
- **Email login test**: Any email works; OTP stored in Firestore under `email_otps`
- **Admin dashboard**: Create test admin in Firestore `admin_users` collection

### Build & Release

```bash
# Android APK (debug)
flutter build apk --debug

# Android App Bundle (release)
flutter build appbundle --release

# iOS (requires Xcode and provisioning)
flutter build ios --release
```

## Git & Deployment

### Branch Strategy

- **main** — Production-ready code
- **fahim** — Current development branch
- Feature branches for new features

### Before Pushing to Main

1. Resolve merge conflicts in `README.md` (currently has merge conflict markers)
2. Test on real device (not just emulator)
3. Verify admin screens don't expose credentials
4. Update version in `pubspec.yaml` if shipping release

### Firebase Rules (Add to Production)

```json
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Students can read/write own profile
    match /students/{document=**} {
      allow read, write: if request.auth.uid != null;
    }
    // Admin-only collections
    match /admin_users/{document=**} {
      allow read, write: if hasRole('admin');
    }
  }
  
  function hasRole(role) {
    return get(/databases/$(database)/documents/admin_users/$(request.auth.uid)).data.role == role;
  }
}
```

## External Services

- **Firebase Project**: `unipath-nasc` (Google Cloud)
- **Firebase Messaging**: Configured, can receive push notifications
- **Cloud Functions**: Python 3.12 runtime available (see `firebase.json`)
- **Mailer**: Set up for email sending (requires configuration in code)

## Next Steps for Contributors

1. Fix merge conflict in `README.md`
2. Implement email service integration (SendGrid or Firebase Extension)
3. Add Firestore security rules
4. Enhance admin authentication (JWT, hashing)
5. Expand chatbot with real NLP/API
6. Add comprehensive unit and widget tests
7. Implement offline-first sync strategy
8. Add analytics tracking (Firebase Analytics)

## Contact & Questions

This is a collaborative project. For architecture questions or feature requests, refer to the latest commits and Firebase console for data schema validation.

---

**Last Updated**: June 2026 | **Status**: Active Development
