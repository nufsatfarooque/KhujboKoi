/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const sendToDevice = functions.firestore.document('report_post/{reportPostID}')
                            .onUpdate(async snapshot =>{
                                const report = snapshot.after.data();
 // fetch uid of reporter using reporter_username got from report.reported_by
 // use uid of reporter to get fcm_token of reporter
 // get msg_id from report.reported_post_id
 // use msg_id to fetch user name of the msg owner from messages collection
 // use username of accused to fetch uid of accused 
 // use uid of accused to fetch fcm_token of accused device

 // use fcm token of reporter and accused as necessary
                            })
