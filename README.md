# Attendly

Attendly is a high-performance, offline-capable event check-in and management application built with Flutter and Firebase.

## Features

- **Organizer Dashboard**: Create and manage multiple events.
- **Attendee Management**: Manually add attendees or bulk import via CSV.
- **QR Ticket Generation**: Attendees receive a scannable QR ticket unique to their registration.
- **Offline-First Scanning** (In Progress): Volunteers can continuously scan tickets even when the internet drops. The app queues the check-ins locally and syncs them automatically when back online.
- **Cloud Functions Transaction** (In Progress): Server-side resolution prevents duplicate check-ins, even under heavy concurrent load (300-500 scans/second).
- **Live Dashboard** (In Progress): Real-time analytics and CSV export of attendance data.

## Getting Started

### Prerequisites
- Flutter SDK (`>=3.12.0`)
- Firebase CLI configured
- A Firebase project with Firestore and Authentication enabled

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/heyitsshubh/Attendly.git
   cd Attendly
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   ```bash
   flutterfire configure
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Architecture

Attendly follows a feature-branch workflow and uses the **BLoC** pattern for state management. 

- `lib/blocs/`: State management logic
- `lib/models/`: Data models and Firestore serialization
- `lib/screens/`: UI components and screens
- `lib/services/`: Firestore and external API communication

## Branch Strategy

We follow a strict feature branch strategy. Each feature is developed on an isolated branch and merged into `main`:
- `feature/setup-and-models` ✅
- `feature/auth-and-routing` ✅
- `feature/event-management` ✅
- `feature/attendee-list-csv` ✅
- `feature/qr-ticket-generation` ✅
- `feature/offline-queue-sync` ⏳
- `feature/scanner-ui` ⏳
- `feature/cloud-functions-transaction` ⏳
- `feature/live-dashboard-export` ⏳
- `feature/load-testing` ⏳

## License

This project is licensed under the MIT License.
