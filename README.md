# Vybe Cabs - Assignment

Flutter application for ride booking with live map tracking.

## Architecture
- State Management: `provider` package to manage global state (`AuthProvider`, `BookingProvider`, `TrackingProvider`).
- Folder Structure: Grouped by layer (`core`, `data`, `presentation`, `providers`).
- UI: Extracted reusable widgets to keep the screen files manageable and declarative.

## Authentication
- Used Firebase Authentication (Email/Password).
- Handled basic validation, loading states, and error toasts natively.
- User data (name/email) is saved directly in the Firebase auth profile instead of setting up a separate Firestore users collection to keep the assignment focused.

## Dummy Data
- Static data is housed in `lib/data/mock/mock_data.dart`.
- Includes basic models for `DriverModel` and `RideOptionModel`.
- For map tracking, instead of hardcoding a straight line from pickup to dropoff, it fetches a real polyline route via Google Maps Directions API. The mock driver then steps through these real coordinates to simulate an actual car moving along the road.

## Run Instructions
1. Make sure `android/app/google-services.json` is present.
2. Ensure you have added the Google Maps API key.
3. Run `flutter run`.
