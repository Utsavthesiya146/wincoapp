# WINCO CONNECT – Premium Android & iOS Mobile Application

> **World Infra Networking Community**  
> *"Build Connections. Create Opportunities. Grow Together."*  
> **Brand Tagline:** *Bridging the Gap*  
> **Official Web Portal:** [https://wincoconnect.com/](https://wincoconnect.com/)  

---

## 1. Project Overview

**WINCO Connect** is a production-grade, premium enterprise mobile application developed for **Android** and **iOS** using the **Flutter** framework. It provides an exclusive, high-performance networking environment tailored for infrastructure professionals—civil contractors, structural engineering consultants, architects, equipment fleet owners, precast manufacturers, and renewable energy EPC leaders.

The application brings the existing web-based WINCO platform into a mobile-first experience, enabling seamless member discovery, high-ticket business referral exchanges, joint venture consortium building on mega infrastructure projects, and attendance management for fortnightly regional conclaves.

---

## 2. Brand Identity & Design System

The application adheres to the official WINCO brand guidelines:

| Brand Color | Hex Code | Purpose in UI |
|---|---|---|
| **Primary Burgundy** | `#702321` | App bars, primary action buttons, brand crests, selected navigation items. |
| **Secondary Burgundy** | `#8A302D` | Gradients, elevated card backgrounds, secondary accents. |
| **Accent Orange** | `#F28C00` | Notifications, highlight tags, call-to-action badges, metrics. |
| **Gold Accent** | `#D4AF37` | WINCO Prime Club exclusive tier badges and syndicates. |
| **Light Background** | `#F7F7F8` | Clean, modern corporate scaffold background. |
| **Surface White** | `#FFFFFF` | Cards, input fields, modals, and sheets. |
| **Text Primary** | `#252525` | High-contrast readable headings and body text. |
| **Text Secondary** | `#777777` | Captions, subtitles, and secondary descriptions. |
| **Border** | `#EAEAEA` | Subtle card borders and list dividers. |

---

## 3. Technology Stack & Architecture

- **Framework:** Flutter (Channel stable, Dart 3.x)
- **Design System:** Material 3 with Plus Jakarta Sans typography
- **State Management:** Riverpod (`flutter_riverpod: ^2.5.1`)
- **Routing Engine:** GoRouter (`go_router: ^14.8.1`) with `StatefulShellRoute` for 5 persistent bottom tabs
- **Network Engine:** Dio (`dio: ^5.11.1`) with custom authorization interceptors and error normalization
- **Encrypted Storage:** `flutter_secure_storage` (Android KeyStore + iOS Keychain)
- **Local Preferences:** `shared_preferences`
- **Native Interop:** `url_launcher` (direct phone dialer, email composer, external browser)
- **WebView Fallback:** `webview_flutter` with strict domain whitelist restrictions

---

## 4. Key Application Modules & Screens

```
WINCO CONNECT Mobile Application
│
├── Splash Screen                # Animated WINCO shield emblem & tagline
├── Onboarding Flow              # 4-stage corporate introduction & value propositions
├── Authentication               # Member sign-in, remember me, forgot password
│
├── Main Navigation (5 Tabs)
│   ├── 1. Dashboard (Home)     # Live statistics (77+ members, 6+ chapters, ₹7.77 Cr), quick actions, recent feeds
│   ├── 2. Member Directory     # Searchable member catalog, category filter chips, direct dial & profile view
│   ├── 3. Business Referrals   # Given/Received tabs, status tracker, TYFCB closed business slips
│   ├── 4. Projects Hub         # Mega infra projects, JV opportunities, expression of collaboration interest
│   └── 5. Member Profile       # Member credentials, networking statistics, environment switcher, logout
│
├── Extended Feature Screens
│   ├── Member Profile Detail   # Deep dive into company credentials, bio, and direct referral passing
│   ├── Pass Referral Form      # Create referral slips with client details and estimated contract value
│   ├── Project Detail Screen   # Comprehensive project scope, lead contractor credentials, and partner bids
│   ├── Regional Chapters       # Bengaluru Titans, Hubli Pioneers, Coastal Vanguard, Deccan Champions
│   ├── Meetings & Conclaves    # Fortnightly breakfast schedules, agendas, venues, and RSVP tracking
│   ├── Prime Club Syndicate    # Exclusive forum for 20-30 elite contractors executing ₹20+ Cr packages
│   ├── Blogs & Knowledge Hub   # Technical whitepapers and articles from industry leaders
│   ├── Membership Application  # Form matching exact wincoconnect.com fields (First/Last name, Business, Category, Since, Location, GST)
│   ├── Membership Status       # Real-time tier benefits review & induction review tracking
│   ├── Contact Secretariat     # Official phone (+91 9886115993), email (info@wincoconnect.com), and message form
│   ├── Notification Center     # Push alerts for referrals received, meetings, and announcements
│   └── Secure WebView Fallback # Domain-whitelisted fallback for web pages without native APIs
```

---

## 5. Verified Website Statistics (Baseline Reference)

Extracted directly from `https://wincoconnect.com/`:
- **Active Members:** `77+`
- **Regional Chapters:** `6+`
- **Total Closed Business Generated:** `₹7,77,29,407` (~₹20+ Crore pipeline)
- **Average Referral Value:** `₹10,09,473`

> [!NOTE]
> In accordance with project instructions, these values serve as verified baseline defaults. In production mode, the application dynamically requests real-time statistics from the backend database via `/api/v1/dashboard/stats`.

---

## 6. Dual-Mode Backend Synchronization Architecture

To protect production stability while accommodating the fact that only the public website is accessible initially:
1. **Mock Mode (Default for Preview & App Store Review):**
   - Implements realistic, strongly-typed data matching actual WINCO schemas.
   - Operates 100% offline without requiring server credentials.
2. **Production Mode:**
   - Targets `https://wincoconnect.com/api/v1`.
   - Sends Bearer token headers via `ApiClient`.
   - Ready for the website backend developer to deploy the API controller documented in `BACKEND_INTEGRATION.md`.
   - Can be toggled instantaneously in `lib/main.dart` with `AppConfig.setConfig(AppConfig.production)`.

---

## 7. Project Documentation Index

For comprehensive engineering specifications, consult the following dedicated documents:

1. [WEBSITE_ANALYSIS.md](file:///d:/HB/Winco%20Connect/WEBSITE_ANALYSIS.md) — Technical discovery of `wincoconnect.com`, page catalog, form inputs, and brand elements.
2. [APP_ARCHITECTURE.md](file:///d:/HB/Winco%20Connect/APP_ARCHITECTURE.md) — Clean architecture layers, Riverpod state management, and directory layout.
3. [BACKEND_INTEGRATION.md](file:///d:/HB/Winco%20Connect/BACKEND_INTEGRATION.md) — Blueprint for connecting the existing CodeIgniter/MySQL database to the mobile client.
4. [API_REQUIREMENTS.md](file:///d:/HB/Winco%20Connect/API_REQUIREMENTS.md) — Complete RESTful JSON contract, request/response schemas, status codes, and FCM push integration.
5. [BUILD_INSTRUCTIONS.md](file:///d:/HB/Winco%20Connect/BUILD_INSTRUCTIONS.md) — Prerequisites and compilation steps for Android APK/AAB and iOS IPA.
6. [TESTING_CHECKLIST.md](file:///d:/HB/Winco%20Connect/TESTING_CHECKLIST.md) — QA test suite verification, test cases, and validation checklist.

---

## 8. Quick Start

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run test suite
flutter test

# 3. Analyze codebase
flutter analyze

# 4. Run application
flutter run
```
