
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const sendToDevice = functions.firestore
  .document("report_post/{reportPostID}")
  .onUpdate(async (snapshot) => {
    const report = snapshot.after.data();
    if (!report) {
      console.error("No report data available.");
      return;
    }

    const reporterUsername = report.reported_by;
    const reportedMsgId = report.reported_post_id;
    const responseToAccused = report.response_to_accused;
    const responseToReporter = report.response;

    try {
      // Fetch reporter's UID
      const reporterUidSnapshot = await db
        .collection("users")
        .where("name", "==", reporterUsername)
        .get();

      if (reporterUidSnapshot.empty) {
        console.error("No matching reporter found.");
        return;
      }

      // Fetch accused's username from the reported message
      const accusedUsernameSnap = await db.collection("messages")
        .doc(reportedMsgId)
        .get();

      if (!accusedUsernameSnap.exists) {
        console.error("No matching accused user found.");
        return;
      }

      const messageData = accusedUsernameSnap.data();
      const accusedUsername = messageData?.userName ?? "Unknown";

      // Fetch accused's UID
      const accusedUidSnap = await db
        .collection("users")
        .where("name", "==", accusedUsername)
        .get();

      if (accusedUidSnap.empty) {
        console.error("No matching accused user found.");
        return;
      }

      const reporterFcmToken = reporterUidSnapshot.docs[0].data()?.token;
      const accusedFcmToken = accusedUidSnap.docs[0].data()?.token;

      // Prepare notification payloads
      const reporterPayload: admin.messaging.MessagingPayload = {
        notification: {
          title: "Report Update",
          body: `Your report regarding ${accusedUsername}'s has been reviewed.
Our Response: ${responseToReporter}
This is our final verdict.`,
          icon: "your-icon-url",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      };

      const accusedPayload: admin.messaging.MessagingPayload = {
        notification: {
          title: "One of your posts has been reported",
          body: responseToAccused ?? "",
          icon: "your-icon-url",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      };

      const notifications: Promise<any>[] = [];

      // Send to reporter in all cases
      if (reporterFcmToken) {
        notifications.push(fcm.sendToDevice(reporterFcmToken, reporterPayload));
      }

      // Send to accused only if responseToAccused exists
      if (responseToAccused && accusedFcmToken) {
        notifications.push(fcm.sendToDevice(accusedFcmToken, accusedPayload));
      }

      // Wait for all notifications to be sent
      return Promise.all(notifications);
    } catch (error) {
      console.error("Error sending notifications:", error);
      throw error;
    }
  });
