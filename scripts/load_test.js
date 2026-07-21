const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// 1. Initialize Firebase Admin SDK
// You must provide the path to your service account key JSON file via an environment variable
// or replace the string below with the absolute path to the file.
// Example: set GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\serviceAccountKey.json"

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error("ERROR: GOOGLE_APPLICATION_CREDENTIALS environment variable not set.");
  console.log("Please download your service account key from the Firebase Console:");
  console.log("Project Settings -> Service Accounts -> Generate new private key");
  console.log("Then run the script like this (on Windows):");
  console.log("> set GOOGLE_APPLICATION_CREDENTIALS=C:\\path\\to\\key.json");
  console.log("> node load_test.js");
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.applicationDefault()
});

const db = admin.firestore();

// 2. Configuration
const EVENT_ID = 'test-event-123'; // Replace with a real event ID from your Firestore
const NUM_CHECK_INS = 50; // The number of concurrent scans to simulate

async function runLoadTest() {
  console.log(`Starting load test for event: ${EVENT_ID}`);
  console.log(`Simulating ${NUM_CHECK_INS} concurrent check-ins...`);

  const startTime = Date.now();
  
  // Create an array of mock scan documents to insert simultaneously
  const promises = [];

  for (let i = 0; i < NUM_CHECK_INS; i++) {
    const ticketId = `ticket-loadtest-${i}`;
    
    // We write to the pendingCheckIns collection to simulate an offline scan syncing
    const docRef = db.collection('events')
                     .doc(EVENT_ID)
                     .collection('pendingCheckIns')
                     .doc(ticketId);

    const checkInData = {
      ticketId: ticketId,
      scannedAt: admin.firestore.FieldValue.serverTimestamp(),
      scannerId: 'load-test-script',
      syncedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Push the write promise to the array
    promises.push(docRef.set(checkInData));
  }

  try {
    // Execute all writes concurrently
    await Promise.all(promises);
    const endTime = Date.now();
    
    console.log(`\n✅ Successfully dispatched ${NUM_CHECK_INS} check-ins to the queue!`);
    console.log(`Time taken to write to queue: ${endTime - startTime}ms`);
    console.log(`\nNow go to your Firebase Console -> Functions -> Logs`);
    console.log(`Observe if 'processCheckIn' scales up and processes them atomically without transaction failures.`);
  } catch (error) {
    console.error("Error writing to Firestore:", error);
  }
}

runLoadTest();
