const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { FieldValue, Timestamp } = require("@google-cloud/firestore");
const { user } = require("firebase-functions/lib/providers/auth");
admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

exports.postCountIncrease = functions.firestore
  .document("posts/{postId}")
  .onCreate((change, context) => {
    // Retrieve the current and previous value
    const data = change.data();
    context.params.user_id;
    let uid = data.postedBy;
    const userData = db.collection("users").doc(uid).get();

    return Promise.all([userData]).then(async (result) => {
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

exports.postCountDecrement = functions.firestore
  .document("posts/{postId}")
  .onDelete((change, context) => {
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

exports.pagePostCountIncrease = functions.firestore
  .document("page_posts/{postId}")
  .onCreate(async (change, context) => {
    // Retrieve the current and previous value
    const data = change.data();
    let pid = data.page;
    db.collection("pages")
      .doc(pid)
      .get()
      .then((res) => {
        var page = res.data();
        db.collection("notifications").add({
          recievers: page.followers,
          notificationType: "PAGE_POST",
          message: page.name+" Published a new post",
          title:page.name,
          id: context.params.postId,
          pageId: pid,
          photoUrl: data.resources,
          type: data.type,
          createdOn: data.postedOn,
        });
      });

    return db
      .collection("pages")
      .doc(pid)
      .update({
        posts: FieldValue.increment(1),
      });
  });

exports.pagePostCountDecrement = functions.firestore
  .document("page_posts/{postId}")
  .onDelete(async (change, context) => {
    const data = change.data();
    let pid = data.page;
    return db
      .collection("pages")
      .doc(pid)
      .update({
        posts: FieldValue.increment(-1),
      });
  });

exports.groupPostCountIncrease = functions.firestore
  .document("group_posts/{postId}")
  .onCreate(async (change, context) => {
    const data = change.data();
    let pid = data.group;
    db.collection("groups")
      .doc(pid)
      .get()
      .then((res) => {
        var group = res.data();
        db.collection("notifications").add({
          recievers: group.members,
          notificationType: "GROUP_POST",
          message: "Published a new post",
          title:group.name,
          id: context.params.postId,
          pageId: pid,
          photoUrl: data.resources,
          type: data.type,
          createdOn: data.postedOn,
        });
      });

    return db
      .collection("groups")
      .doc(pid)
      .update({
        posts: FieldValue.increment(1),
      });
  });

exports.classPostCreated = functions.firestore
  .document("class_posts/{postId}")
  .onCreate(async (change, context) => {
    const data = change.data();
    let pid = data.class;
    return db
      .collection("class_rooms")
      .doc(pid)
      .get()
      .then((res) => {
        var page = res.data();
        db.collection("notifications").add({
          recievers: page.students,
          notificationType: "CLASS_POST",
          message: data.name+" Plublished a new post",
          title:data.name,
          id: context.params.postId,
          pageId: pid,
          photoUrl: data.resources,
          type: data.type,
          createdOn: data.postedOn,
        });
      });
  });

exports.groupPostCountDecrement = functions.firestore
  .document("group_posts/{postId}")
  .onDelete(async (change, context) => {
    const data = change.data();
    let pid = data.group;
    return db
      .collection("groups")
      .doc(pid)
      .update({
        posts: FieldValue.increment(-1),
      });
  });

exports.userUpdated = functions.firestore
  .document("users/{userId}")
  .onUpdate(async (change, context) => {
    const oldData = change.before.data();
    const newData = change.after.data();
    const friendsOld = oldData.friends;
    const friendsNew = newData.friends;
    let friend_1 = context.params.userId;
    let oFrnds = [];
    for (let i in friendsOld) {
      oFrnds.push(i);
    }
    for (let frnd in friendsNew) {
      if (!oFrnds.includes(frnd)) {
        if (friendsNew[frnd] == 1) {
          var friendInfo = await db.collection("users").doc(frnd).get();
          return db.collection("notifications").add({
            recievers: [friend_1],
            notificationType: "RECEIVED",
            id: frnd,
            message: friendInfo.data().name+" Sent friend request",
            title: friendInfo.data().name,
            photoUrl: friendInfo.data().photoUrl,
            type: 0,
            name: friendInfo.data().name,
            createdOn: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
    }
    if (!friendsOld) return null;
    if (friendsOld != friendsNew) {
      for (let key in friendsNew) {
        if (friendsOld[key] == 1) {
          if (friendsNew[key] == 3) {
            let userRef = {};
            userRef[friend_1] = db.collection("users").doc(friend_1);
            userRef[key] = db.collection("users").doc(key);

            let room = await db.collection("chatRooms").add({
              users: [friend_1, key],
              lastPostedOn: admin.firestore.FieldValue.serverTimestamp(),
              userRef: userRef,
              status: 1,
            });

            db.collection("notifications").add({
              recievers: [key],
              notificationType: "ACCEPTED",
              id: friend_1,
              message: oldData.name+" Accepted your request.",
              title: oldData.name,
              photoUrl: oldData.photoUrl,
              type: 0,
              name: oldData.name,
              createdOn: admin.firestore.FieldValue.serverTimestamp(),
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

        if (friendsOld[key] == 2) {
          if (friendsNew[key] == 1) {
            var friendInfo = await db.collection("users").doc(key).get();

            return db
              .collection("notifications")
              .add({
                recievers: [friend_1],
                notificationType: "RECEIVED",
                id: key,
                message: friendInfo.data().name+" sent friend request.",
                title: friendInfo.data().name,
                type: 0,
                photoUrl: friendInfo.data().photoUrl,
                name: friendInfo.data().name,
                createdOn: admin.firestore.FieldValue.serverTimestamp(),
              })
              .then((res) => {
                console.log(friend_1 + " - " + key + " are no more friends");
              });
          }
        }

        if (friendsOld[key] == 3) {
          if (friendsNew[key] == 2) {
            return db.collection("chatRooms").doc(oldData.chats[key]).delete();
          }
        }
      }
    }
  });

exports.updateChatTime = functions.firestore
  .document("chatRooms/{roomId}/chats/{chatId}")
  .onCreate((snapshot, context) => {
    let lastPostedOn = snapshot.data().postedOn;
    let uid = context.params.userId;

    return db
      .collection("chatRooms")
      .doc(context.params.roomId)
      .update({
        lastPostedOn: lastPostedOn,
        lastMessage: snapshot.data(),
        unreadMessages: FieldValue.increment(1),
      })
      .then((res) => {
        console.log("Recent chat Time updated");
      });
  });

exports.sendChatNotification = functions.firestore
  .document("chatRooms/{roomId}")
  .onUpdate(async (snapshot, context) => {
    const data = snapshot.after.data();
    let messageData = data.lastMessage;
    let senderId = data.lastMessage.postedBy;

    let receiverId;
    let users = data.users;

    for (i = 0; i < users.length; i++) {
      if (users[i] != senderId) {
        receiverId = users[i];
      } else {
        senderId = users[i];
      }
    }
    let senderRef = await db.collection("users").doc(senderId).get();
    let senderInfo = senderRef.data();
    let receiverRef = await db.collection("users").doc(receiverId).get();
    let receiverInfo = receiverRef.data();
    let messageToken = receiverInfo.messageToken;

    const payload = {
      notification: {
        title: senderInfo.name,
        body: messageData.message,
        badge: "1",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      data: {
        type: "USER_CHAT",
        roomId: context.params.roomId,
        friendId: senderId,
        friendData: JSON.stringify(senderInfo),
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    };
    if(! messageToken)return console.log("No Token FOund");
    if (messageToken.length == 0) return console.log("No Token FOund");
    return admin
      .messaging()
      .sendToDevice(messageToken, payload)
      .then((res) => console.log("Notification Sent Successfully."));
  });

exports.userPresenceToggle = functions.database
  .ref("/status/{uid}")
  .onWrite(async (change, context) => {
    let userstatus = change.after.val();
    console.log(userstatus + ":" + context.params.uid);
    const uid = context.params.uid;
    return db.collection("users").doc(uid).update({ status: userstatus });
  });

exports.notificationManager = functions.firestore
  .document("notifications/{nId}")
  .onCreate(async (snapshot, contex) => {
    let data = snapshot.data();

    let receivers = data.recievers;

    let payload = {
      notification: {
        title: data.title,
        body: data.message,
        badge: "1",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      data: {
        type: data.notificationType,
        data: JSON.stringify(data),
      },
    };
if(data.name){
    payload = {
      notification: {
        title: data.title,
        body: data.message,
        badge: "1",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      data: {
        type: data.notificationType,
        data: JSON.stringify(data),
        name: data.title,
      },
    };}

    if (data.photoUrl != null && data.type==0) {
      payload = {
        notification: {
          title: "title",
          body: data.message,
          badge: "1",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          image : data.photoUrl,

        },
        data: {
          type: data.notificationType,
          id: data.id,
          data: JSON.stringify(data),
          name:data.title,
        },
      };
    }

    let userTokens = [];

    for (let user in receivers) {
      let users = await db.collection("users").doc(receivers[user]).get();
      let userInfo = users.data();

      let tokens = userInfo.messageToken;

      if (tokens != undefined)
        if (tokens.length > 0) {
          userTokens = userTokens.concat(tokens);
        }
    }

    
    userTokens = userTokens.filter(function (el) {
      return el != null;
    });
    if (userTokens.length == 0) return console.log(userTokens);
    return admin
      .messaging()
      .sendToDevice(userTokens, payload)
      .then((res) => console.log("Notification Sent Successfully."));
  });
