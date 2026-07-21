# Attendly

**Attendly** is a robust, offline-first event check-in and ticket scanning application built with Flutter and Firebase. It was designed to guarantee atomic check-ins across multiple devices (to prevent double-scans) while allowing organizers to continue scanning even in environments with zero internet connectivity.

![Attendly Banner](assets/logo.png)

## 🚀 Key Features

*   **Offline-First Scanning**: Continue scanning QR codes in airplane mode. The app securely queues check-ins in a local SQLite-backed BLoC state.
*   **Atomic Transactions**: A robust TypeScript Firebase Cloud Functions backend ensures that multiple scanners cannot accidentally check in the same ticket simultaneously.
*   **Real-time Analytics Dashboard**: View live, animated pie charts of check-in progress right from the event details screen.
*   **CSV Export**: Instantly export a complete ledger of attendees and their exact check-in timestamps to a local spreadsheet.
*   **Premium UI**: A sleek, custom "Matte Black & Crimson Red" theme built with smooth micro-interactions.

## 🏗️ Architecture

Attendly utilizes the **BLoC (Business Logic Component)** pattern for state management, providing a clear separation of concerns between the UI and the data layer.

### The Check-In Flow (Offline-to-Cloud)

1.  **Scanner**: The `ScannerBloc` processes camera frames rapidly (with a 300-500ms debounce) using `mobile_scanner`.
2.  **Queue**: If the device is offline, the check-in is appended to a `pendingCheckIns` sub-collection via the `SyncBloc`.
3.  **Cloud Function**: The `processCheckIn` TypeScript Cloud Function listens to `pendingCheckIns`. It uses an atomic `runTransaction` to verify the ticket hasn't been used yet. If valid, it marks the global `attendees` document as `checkedIn: true`.
4.  **Real-time UI**: The Flutter UI listens to the `attendees` collection snapshot, automatically reflecting the updated check-in status on the pie charts and lists as soon as the Cloud Function finishes.

## 🛠️ Getting Started

### Prerequisites
*   Flutter SDK (^3.12.2)
*   Node.js (for Cloud Functions)
*   A Firebase Project with Authentication and Cloud Firestore enabled.

### Setup Instructions

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/heyitsshubh/Attendly.git
    cd appendly
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Deploy Cloud Functions:**
    ```bash
    cd functions
    npm install
    npm run build
    firebase deploy --only functions
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

## 🧪 System Load Testing

To verify the atomic nature of the backend under heavy load, you can run the provided Node script:

```bash
cd scripts
set GOOGLE_APPLICATION_CREDENTIALS=C:\path\to\your\serviceAccountKey.json
node load_test.js
```
*This will concurrently dispatch 50 simultaneous check-ins to ensure your Firebase transaction architecture scales without race conditions.*

---
*Built with Flutter & Firebase.*
