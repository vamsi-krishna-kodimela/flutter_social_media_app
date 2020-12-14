const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

exports.postCountIncrease = functions.firestore.document("posts/{postId}").onCreate((change, context) => {
    // Retrieve the current and previous value
    const data = change.data();
    context.params.user_id;
    let uid = data.postedBy;
    const userData = db.collection("users").doc(uid).get();

    // const payload = {
    //   notification:{
    //     title:"Hello",
    //     body:"hiiii",
    //   }
    // };
    

    return Promise.all([userData]).then(async (result) => {
    //   console.log(userData.messageToken);
    // let  response = await admin.messaging().sendToDevice([result[0].data().messageToken],payload);
      let postCount = result[0].data().postCount;

      if (!postCount) {
        postCount = 0;
      }
      postCount += 1;
      db.collection("users").doc(uid).update({
        postCount: postCount,
      });
    });
  });

exports.postCountDecrement = functions.firestore.document("posts/{postId}").onDelete((change, context) => {
    // Retrieve the current and previous value
    const data = change.data();
    let uid = data.postedBy;
    const userData = db.collection("users").doc(uid).get();
    return Promise.all([userData]).then((result) => {
      let postCount = result[0].data().postCount;
      if (!postCount) {
        postCount = 0;
        return null;
      }
      postCount -= 1;
      db.collection("users").doc(uid).update({
        postCount: postCount,
      });
    });
  });



exports.userUpdated = functions.firestore.document("users/{userId}").onUpdate(async (change, context)=>{
    const oldData = change.before.data();
    const newData = change.after.data();
    const friendsOld = oldData.friends;
    const friendsNew = newData.friends;
    if (!friendsOld) return null;
    if (friendsOld != friendsNew) {
      let friend_1 = context.params.userId;

      for (let key in friendsOld) {
        if (friendsOld[key] == 1) {
          if (friendsNew[key] == 3) {
            let userRef = {};
            userRef[friend_1] = db.collection("users").doc(friend_1);
            userRef[key] = db.collection("users").doc(key);

            let room = await db
              .collection("chatRooms")
              .add({
                users: [friend_1, key],
                lastPostedOn: admin.firestore.FieldValue.serverTimestamp(),
                userRef: userRef,
                status: 1,
              });

              let p1 = db
                  .collection("users")
                  .doc(key)
                  .update({
                    [`chats.${friend_1}`]: room.id,
                  });
                let p2 = db
                  .collection("users")
                  .doc(friend_1)
                  .update({
                    [`chats.${key}`]: room.id,
                  });

                return Promise.all([p1, p2]).then((res) => {
                  console.log(friend_1 + " - " + key + " chats created");
                });
          }
        }



        if(friendsOld[key]==3){
          if(friendsNew[key]==2){
            return db.collection("chatRooms").doc(oldData.chats[key]).update({status : 0}).then((res)=>{
              console.log(friend_1 + " - " + key + " are no more friends");
            });
          }
        }



      }
    }
  });

exports.updateChatTime = functions.firestore.document("chatRooms/{roomId}/chats/{chatId}").onCreate(
  (snapshot,context)=>{
    let lastPostedOn = snapshot.data().postedOn;
    return db.collection("chatRooms").doc(context.params.roomId).update({
      lastPostedOn : lastPostedOn
    }).then((res)=>{
      console.log("Recent chat Time updated");
    });
  }
);

exports.userPresenceToggle = functions.database.ref("/status/{uid}").onWrite(
  async(change,context)=>{
    let userstatus = change.after.val().trim();
    // return db.collection("users").doc(context.params.uid).update({status : userstatus});
    console.log(userstatus+":"+context.params.uid);
    const uid = context.params.uid;
    return db.collection("users").doc(uid).update({status:userstatus});
  }
);