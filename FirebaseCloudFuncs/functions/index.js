const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

//Keeps the 
exports.countCheckIns = functions.database.ref('/checkIn/{uid}/{checkin}')
   .onCreate((snapshot, context) => {
      console.log('Updating checkin count ', context.params.uid);
      
      return admin.database().ref('/checkIn/' + context.params.uid + '/checkInCount').once("value")
         .then((dataSnapshot) => {
            
            const original = dataSnapshot.val();

            if (dataSnapshot.val() === null) {
               return dataSnapshot.ref.set(1);
            }
            else {
               return dataSnapshot.ref.set(original + 1);
            }
      });
   });
