# Vybe Cabs

A premium, modern ride-hailing application built with Flutter, focusing on exceptional UI/UX, smooth animations, and real-time mapping functionality. 

## 🏗️ Architecture Choices

The application is structured using a clean, scalable architecture separating the UI from business logic:
- **State Management**: Uses the **Provider** package (`provider: ^6.1.2`) to manage global state across four primary domains: `AuthProvider`, `BookingProvider`, `TrackingProvider`, and `HistoryProvider`.
- **Folder Structure**: 
  - `lib/core`: Reusable constants, styling (themes, colors, typography), and utility classes (Custom Map Markers).
  - `lib/data`: Data models (Driver, RideOption, Location) and services (Places API, Directions API).
  - `lib/presentation`: The UI layer organized by feature (`auth`, `home`, `live_tracking`, `ride_history`).
  - `lib/providers`: The business logic and state management controllers.
- **UI Design**: Implemented a highly modular UI relying on custom extracted widgets (e.g., `GlassContainer`, `DriverBottomCard`, `SafeMapView`) to keep screens readable and declarative, styled with modern glassmorphism and vibrant branding.

## 🔐 Authentication Method

The app relies on **Firebase Authentication**.
- **Strategy**: Utilizes standard **Email & Password** authentication.
- **User Profiles**: Leverages the native Firebase User `displayName` to store and retrieve the user's name without requiring a separate Firestore database for basic user management.
- **UX**: The auth flow features robust validation, loading states, and non-blocking toast notifications (`fluttertoast`) for seamless error handling (e.g., invalid credentials, weak passwords).

## 🗃️ Dummy Data Structure

Since there is no live backend for ride matching, the app uses a structured mock data approach:
- **`MockData` Class**: Located in `lib/data/mock/mock_data.dart`, it provides static, well-typed dummy data.
- **Drivers & Vehicles**: A list of `DriverModel` objects contains dummy driver names, avatars, ratings, OTPs, and vehicle details (e.g., Hyundai Verna).
- **Ride Options**: `RideOptionModel` defines available cab types (Mini, Sedan, SUV) with base rates, multipliers, and capacity.
- **Routing & Simulation**: 
  - Instead of hardcoded straight lines, the app fetches actual road paths using the **Google Maps Directions API** and `flutter_polyline_points`.
  - The `TrackingProvider` simulates a driver driving along this real-world polyline route, calculating bearing (rotation) and ETA dynamically to provide a realistic tracking experience.
- **History**: Ride history is maintained locally in the `HistoryProvider` memory during the session lifecycle.

## 🚀 Getting Started

1. Ensure you have the `google-services.json` file placed in `android/app/`.
2. Ensure you have API Keys for Google Maps (Places API & Directions API) configured in `AndroidManifest.xml` and the `DirectionsService`.
3. Run the app: `flutter run`
