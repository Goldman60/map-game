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

//Keeps your most visited place up to date
exports.updateMostVisited = functions.database.ref('/metaplaces/{placeID}/{userID}/checkInCount')
   .onWrite((snapshot, context) => {
      const newCandidate = snapshot.after.val();

      return admin.database().ref('/publicusers/' + context.params.userID + '/mostCheckedInCount').once("value")
         .then((dataSnapshot) => {
            if (dataSnapshot.val() === null || dataSnapshot.val() < newCandidate) {
               dataSnapshot.ref.set(newCandidate);
               return dataSnapshot.ref.parent.child('mostCheckedInPlace').set(context.params.placeID);
            }
            else {
               return 0;
            }
         });
   });

//Adjudicates the owner of a place
exports.updatePlaceOwner = functions.database.ref('/metaplaces/{placeID}/{userID}/checkInCount')
   .onWrite((snapshot, context) => {
      const newCandidate = snapshot.after.val();
   
      return admin.database().ref('/metaplaces-owners/' + context.params.placeID).once("value")
         .then((dataSnapshot) => {
            //console.log('Found a checkin count of ', dataSnapshot.child('checkInCount').val());

            if (dataSnapshot.val() === null || dataSnapshot.child('checkInCount').val() < newCandidate) {
               dataSnapshot.ref.child('checkInCount').set(newCandidate);
               return dataSnapshot.ref.child('ownerID').set(context.params.userID);
            }

            return 0;
         });
   });
