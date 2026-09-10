# ⚡ Vybe Cabs — Rider Mobile App (Flutter)

[![Flutter Version](https://img.shields.io/badge/Flutter-3.47.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.13.0-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Layered%20%2B%20Provider-00E676)](#-architecture--design-patterns)
[![Theme](https://img.shields.io/badge/Theme-Cyber%20Midnight%20Dark-0D0F14)](#-uiux--design-system)
[![Tests](https://img.shields.io/badge/Tests-12%2F12%20Passed-00E676)](#-automated-tests)

A high-performance, aesthetically stunning on-demand ride-hailing rider application built with **Flutter**, featuring Google Maps integration with custom dark cyberpunk styling, live animated driver tracking with dynamic bearing rotation, Firebase Authentication with 1-click Demo evaluation mode, full fare calculations, itemized receipts, and past ride history.

---

## 📱 App Highlights & Feature Breakdown

### 1. Splash Screen
* **Logo & Branding:** Custom neon emerald electric bolt emblem with pulsing glow and smooth fade/scale entry animation.
* **Auto-Session Routing:** Checks Firebase Auth state and local `SharedPreferences` session cache to seamlessly transition into `HomeScreen` (if authenticated) or `AuthScreen` (if unauthenticated).
* **Asset Pre-caching:** Pre-renders custom canvas vector map markers (Pickup pin, Drop pin, Directional vehicle marker) during splash for zero map stutter.

### 2. Authentication Screen
* **Multiple Auth Methods:**
  * **Email & Password Authentication:** Input validation (regex email check, 6+ character password strength), error handling, and loading state spinners.
  * **Phone OTP Modal Sheet:** Mobile number input, simulated/Firebase SMS verification code (6 digits), countdown resend timer, and instant verification.
  * **⚡ Quick Demo Mode (1-Click):** Instant bypass button designed for evaluation and reviewers to explore the full app without entering credentials.
* **Session Persistence:** Remembers user token, name, phone, and wallet balance across app restarts.

### 3. Home Screen & Map Experience
* **Google Maps Integration:** Styled with a custom Dark Cyber Midnight theme (`assets/map_styles/dark_map_style.json`).
* **GPS Geolocation:** Uses `geolocator` to center the camera on the user's live coordinates, with one-tap recenter floating action button.
* **"Where to?" Search Sheet:** Bottom sheet with search query filtering across 5 popular destinations:
  1. *DLF Cyber City, Building 10*
  2. *Indira Gandhi International Airport (T3)*
  3. *Select CITYWALK Mall, Saket*
  4. *Cyber Hub Social & Dining*
  5. *Worldmark 1, Aerocity*
* **Vehicle Category Selector (Horizontal Carousel):**
  * **Vybe Mini:** ₹50 base + ₹14/km (Compact, 4 seats)
  * **Vybe Prime:** ₹80 base + ₹18/km (Popular, 4 seats)
  * **Vybe Premier:** ₹120 base + ₹25/km (Executive Luxury, 4 seats)
  * **Vybe XL:** ₹150 base + ₹30/km (Spacious SUV, 6 seats)
  * **Vybe Auto:** ₹30 base + ₹10/km (Quick 3W, 3 seats)
* **Dynamic Calculations:** Haversine distance, travel duration estimates, and itemized fare totals recalculated on pickup/drop changes.
* **Payment Selector:** Select from UPI / GPay, Credit/Debit Card, Vybe Wallet (₹850), or Cash on Arrival.

### 4. Finding Driver Screen
* **Radar Sonar Animation:** Custom animated canvas drawing expanding concentric sonar ripple rings with vehicle beacon.
* **Realistic State Machine:** 3–5 second simulated search lifecycle with status text changes (*"Scanning 14+ drivers..."* $\rightarrow$ *"Found high-rated driver nearby!"* $\rightarrow$ *"Confirming driver reservation..."*).
* **Assigned Driver Card:** Real-time driver profile (*Rajesh Kumar*, 4.93 ★, Hyundai Verna White, plate DL 01 AB 4321), and 4-digit Ride PIN (`8492`).
* **Ride Cancellation:** Option to cancel request with instant state cleanup.

### 5. Live Tracking Screen
* **Live Moving Marker:** Simulated driver car moves smoothly along realistic multi-point waypoint coordinates towards pickup point and subsequently to dropoff destination.
* **Smooth Bearing Rotation:** Mathematical forward azimuth calculation dynamically rotates the vehicle icon according to road orientation.
* **Driver ETA Countdown:** Live countdown updates in real time based on distance remaining.
* **"Driver Arrived" Modal Dialog:** Automatically triggers when driver reaches pickup coordinates, displaying driver information and 4-digit Ride Verification PIN.
* **Active Trip Phase:** Tapping *"Start Journey"* transitions route and begins simulated trip progress to destination.

### 6. Trip Completed & Rating Screen
* **Success Celebration:** Animated checkmark badge and trip completion banner.
* **Itemized Fare Breakdown:** Base Fare, Distance & Time Fare, Taxes & Tolls (GST), Discount, and Total Paid.
* **Interactive 5-Star Rating:** Dynamic star selection widget with instant feedback.
* **Driver Compliments:** Selectable chips (*"Clean Car ✨"*, *"Polite Driver 🤝"*, *"Smooth Driving 🚗"*, *"Great Music 🎵"*, *"On Time ⏱️"*, *"Safe Journey 🛡️"*).
* **Driver Tip Selector:** 1-tap tip options (No Tip, ₹20, ₹50, ₹100).
* **Actions:** *"Submit & Return Home"* or *"View in Ride History"*.

### 7. Ride History Screen
* **Filter Tabs:** Tabbed filtering between **All (6)**, **Completed**, and **Cancelled** rides.
* **Rich Trip Cards:** Vehicle category icon, date & time, fare, status badge, pickup and drop addresses.
* **Detailed Receipt Modal Sheet:** Opens full trip breakdown with itemized fares, payment method used, and simulated PDF Tax Invoice download.

---

## 🏗 Architecture & Design Patterns

The codebase adheres strictly to a clean, decoupled layered architecture:

```
lib/
├── core/
│   ├── constants/        # AppColors (Emerald/Midnight), AppTypography, AppConstants
│   ├── theme/            # ThemeData, dark luxury colorScheme, button & card styling
│   ├── utils/            # GeoUtils (Haversine distance, bearing, formatting), CustomMapMarkers
│   └── widgets/          # CustomButton, CustomTextField, GlassContainer, PulseRing
├── data/
│   ├── mock/             # MockData (Locations, Ride types, Drivers, Waypoints, 6 Past Trips)
│   ├── models/           # LocationModel, RideOptionModel, DriverModel, TripModel, UserModel
│   └── services/         # FirebaseAuthService, LocationService (Geolocator)
├── providers/            # State Management
│   ├── auth_provider.dart      # Auth state, login/register, demo mode, session persistence
│   ├── booking_provider.dart   # Pickup/Drop selection, fare calculation, payment methods
│   ├── tracking_provider.dart  # Driver search timer, waypoint motion, bearing rotation, ETA
│   └── history_provider.dart   # Past trips list, category filter tabs, new trip insertion
└── presentation/         # UI Screens
    ├── splash/           # SplashScreen
    ├── auth/             # AuthScreen, PhoneOtpSheet
    ├── home/             # HomeScreen, WhereToCard, LocationSearchSheet, RideSelectionSheet
    ├── finding_driver/   # FindingDriverScreen, RadarRippleWidget
    ├── live_tracking/    # LiveTrackingScreen, DriverBottomCard, DriverArrivedDialog
    ├── trip_completed/   # TripCompletedScreen, StarRatingWidget, TipSelector
    └── ride_history/     # RideHistoryScreen, RideDetailSheet
```

---

## 📊 Dummy Data Schema

The application uses realistic dummy data structured in JSON (`assets/json/dummy_data.json`) and strongly typed Dart models in `lib/data/mock/mock_data.dart`:

```json
{
  "popular_locations": [
    {
      "id": "loc_cyber_city",
      "name": "DLF Cyber City, Building 10",
      "address": "DLF Phase 2, Sector 24, Gurugram",
      "city": "Gurugram",
      "latitude": 28.4986,
      "longitude": 77.0898,
      "type": "business"
    }
  ],
  "ride_categories": [
    {
      "id": "vybe_prime",
      "title": "Vybe Prime",
      "tagline": "Top-rated drivers, premium sedans",
      "capacity": 4,
      "base_fare": 80.0,
      "per_km_rate": 18.0,
      "eta_minutes": 3,
      "multiplier": 1.25,
      "is_popular": true
    }
  ],
  "dummy_driver": {
    "id": "drv_101",
    "name": "Rajesh Kumar",
    "rating": 4.93,
    "total_trips": 2150,
    "car_model": "Hyundai Verna (White)",
    "plate_number": "DL 01 AB 4321",
    "phone": "+91 98765 43210",
    "otp": "8492"
  }
}
```

---

## 🚀 Setup & Run Instructions

### Prerequisites
* **Flutter SDK**: `3.24.0` or higher (Tested on `3.47.0`, Dart `3.13.0`)
* **Android SDK**: API level 21+ (Android 5.0+)
* **Google Maps Android API Key** (Configured in `AndroidManifest.xml`)

### Installation Steps

1. **Clone or Open Project Directory:**
   ```bash
   cd "F:\flutter projects\vybe_cabs"
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify Code Quality:**
   ```bash
   flutter analyze
   flutter test
   ```

4. **Launch Application:**
   ```bash
   # Run on connected Android device / emulator
   flutter run

   # Or run with Web renderer (for instant desktop preview)
   flutter run -d chrome
   ```

---

## 📦 Building the APK

To generate a standalone APK for testing:

```bash
# Debug APK (Fastest build for device testing)
flutter build apk --debug

# Release APK (Optimized, minified production build)
flutter build apk --release
```

The compiled APK will be located at:
`build/app/outputs/flutter-apk/app-debug.apk` or `app-release.apk`.

---

## 🧪 Automated Tests

The test suite includes 12 comprehensive unit and widget tests covering:
* `GeoUtils`: Haversine distance, bearing calculations, and string formatters.
* `BookingProvider`: Route metrics calculation, dynamic fare estimation, and reset flows.
* `HistoryProvider`: Preloaded past trips and filter state transitions.
* `Data Models`: DriverModel serialization and RideOptionModel fare formulas.
* `Smoke Test`: Top-level app widget initialization.

Run the test suite anytime using:
```bash
flutter test
```

---

## 🎨 UI/UX Design System

* **Primary Accent:** Neon Emerald (`#00E676`)
* **Background:** Deep Cyber Midnight (`#0D0F14`)
* **Card Surface:** Glassmorphic Carbon (`#161922`)
* **Borders:** Subtle Slate Glow (`#282F3E`)
* **Typography:** Modern Google Fonts (`Outfit` for headings/numerics & `Inter` for body)
* **Haptics & Micro-interactions:** Smooth animations on card selection, radar sonar ripple, rotating car marker, and custom modal sheets.
