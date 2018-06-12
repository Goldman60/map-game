const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

//Keeps the check in counts in sync 
exports.countCheckIns = functions.database.ref('/checkIn/{uid}/{checkin}')
   .onCreate((snapshot, context) => {
      console.log('Updating checkin count ', context.params.uid);
      
      return admin.database().ref('/publicusers/' + context.params.uid + '/checkInCount')
         .once("value").then((dataSnapshot) => {
            
            const original = dataSnapshot.val();

            if (dataSnapshot.val() === null) {
               return dataSnapshot.ref.set(1);
            }
            else {
               return dataSnapshot.ref.set(original + 1);
            }
      });
   });

//Keeps the leaderboard up to date
exports.updateLeaderboard = functions.database.ref('/publicusers/{uid}/checkInCount')
   .onWrite((snapshot, context) => {
      const newCheckInCount = snapshot.after.val();

      return admin.database().ref('/leaderboard/' + context.params.uid).once("value")
         .then((dataSnapshot) => {
            return dataSnapshot.ref.set(newCheckInCount);
         });
   });
