"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.processCheckIn = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
exports.processCheckIn = functions.firestore
    .document("events/{eventId}/pendingCheckIns/{ticketId}")
    .onCreate(async (snap, context) => {
    const { eventId, ticketId } = context.params;
    const pendingData = snap.data();
    if (!pendingData) {
        console.log("No data found for pending check-in", ticketId);
        return null;
    }
    const scannerId = pendingData.scannerId;
    try {
        // 1. Find the attendee in events/{eventId}/attendees
        // We must query the attendees collection by ticketId, or if ticketId is the doc ID we just get it.
        // In the Flutter code, ticketId is a field in the attendees collection and the doc ID is auto-generated.
        const attendeesRef = db.collection("events").doc(eventId).collection("attendees");
        const attendeeQuery = await attendeesRef.where("ticketId", "==", ticketId).limit(1).get();
        if (attendeeQuery.empty) {
            console.error(`Invalid ticketId: ${ticketId} for event: ${eventId}`);
            // Optionally mark as invalid instead of just deleting
            await snap.ref.delete();
            return null;
        }
        const attendeeDoc = attendeeQuery.docs[0];
        const attendeeRef = attendeeDoc.ref;
        // 2. Start a Firestore Transaction
        await db.runTransaction(async (transaction) => {
            const attendeeSnap = await transaction.get(attendeeRef);
            if (!attendeeSnap.exists) {
                throw new Error("Attendee document does not exist!");
            }
            const data = attendeeSnap.data();
            const alreadyCheckedIn = (data === null || data === void 0 ? void 0 : data.checkedIn) === true;
            if (alreadyCheckedIn) {
                console.log(`Attendee ${ticketId} is already checked in. Processing as duplicate.`);
                // If it's a duplicate, we just delete the pending record to acknowledge it was processed.
                // The client scanner bloc already has client-side duplicate protection.
            }
            else {
                console.log(`Checking in attendee ${ticketId}...`);
                transaction.update(attendeeRef, {
                    checkedIn: true,
                    checkedInAt: admin.firestore.FieldValue.serverTimestamp(),
                    checkedInBy: scannerId,
                });
            }
            // 3. Delete the pendingCheckIn document to signify completion
            transaction.delete(snap.ref);
        });
        console.log(`Successfully processed check-in for ticket: ${ticketId}`);
        return null;
    }
    catch (error) {
        console.error(`Transaction failed for ticket ${ticketId}:`, error);
        throw error;
    }
});
//# sourceMappingURL=index.js.map