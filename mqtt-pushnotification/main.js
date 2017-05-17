var mqtt = require('mqtt')
var MongoClient = require('mongodb').MongoClient;
var redisClient = require('./lib/redis.js')
var f = require('./lib/foreach.js')
var workQueue = require('./lib/work_queue.js')

var serverUrl = process.env.SERVER_URL || 'http://host1.tiegushi.com/';
var MQTT_URL = process.env.MQTT_URL;
var DB_CONN = process.env.MONGO_URL;
var db = null;
var debug_on = process.env.DEBUG_MESSAGE || false;
var allowGroupNotification = process.env.ALLOW_GROUP_NOTIFICATION || false;
var projectName = process.env.PROJECT_NAME || null; // '故事贴：t , 点圈： d'

var client;

function mqttPushNotificationInit() {
    workQueue.workQueueInit(checkTTLAndSendNotification);

    MongoClient.connect(DB_CONN, {poolSize:20 , reconnectTries: Infinity}, function(err, mongodb){
      if (err) {
        console.log('Mongo connect Error:' + err);
      }
      console.log('Mongo connect');
      db = mongodb;
      db.on('timeout',     function(){console.log('MongoClient.connect timeout')});
      db.on('error',       function(){console.log('MongoClient.connect error')});
      db.on('close',       function(){console.log('MongoClient.connect close')});
      db.on('reconnect',   function(){
          console.log('MongoClient.connect reconnect')
      });
    });

    if (workQueue.isMaster()) {
        client  = mqtt.connect(MQTT_URL);
        client.on('connect', function () {
          console.log('mqtt connected')
          var subscribeTopic = '/msg/#';
          if(projectName){
            subscribeTopic = '/'+projectName+'/msg/#';
          }
          client.unsubscribe(subscribeTopic);
          client.subscribe(subscribeTopic,{qos:1},function(err,granted){
            console.log('Granted is '+JSON.stringify(granted))
          });
        });

        client.on('message', function (topic, message) {
          if(!db)
              return;

          // message is Buffer
          debug_on && console.log(topic)
          var msgObj = JSON.parse(message.toString());
          if(msgObj && msgObj.to && msgObj.to.id && msgObj.to.id != 'd2bc4601dfc593888618e98f')
              console.log(msgObj)

          if(allowGroupNotification && topic.match('/msg/g/')){
              if(msgObj && msgObj.to && msgObj.to.id && msgObj.to.id != 'd2bc4601dfc593888618e98f')
                  sendGroupNotification(db,msgObj,'groupmessage');
          }
          if(topic.match('/msg/u/')){
              sendNotification(msgObj, msgObj.to.id,'usermessage');
          }
        });

        client.on('disconnect', function (topic, message) {
            console.log('disconnected')
        });
    }
    else {
        if(process.env.REDIS_HOST && process.env.REDIS_PASSWORD) {
            redisClient.redisClientInit();
        }
    }
}

function checkTTLAndSendNotification(id, item, callback) {
    if (workQueue.isMaster()) {
        console.log(">>> master checkTTLAndSendNotification id= " + id + " item=" + JSON.stringify(item))
        return callback && callback();
    }

    if(item && item.key && item.msg && item.userid && item.type) {
        redisClient.redisUpdateKey(item.key, function(ttl) {
            if(ttl <= 1) {
                sendNotification(item.msg, item.userid, item.type, function(err) {
                    if(err)
                        debug_on && console.log('sendGroupNotification: err=' + err);
                    else
                        console.log('------- sendGroupNotification: send to ' + item.userid);
                    return callback && callback();
                })
                return callback && callback();
            }
            else {
                debug_on && console.log('ingore notification ' + item.key + ' ttl=' + ttl)
                return callback && callback();
            }
        });
    }
    else {
        console.log('invalid data')
        return callback && callback();
    }
}

function sendNotification(message, toUserId ,type, cb) {
  var toUserId = toUserId;
  var userId = message.form.id;

  var users = db.collection('users');
  var pushTokens = db.collection('pushTokens');
  var PushMessages = db.collection('pushmessages');

  users.findOne({ _id: toUserId }, function (err, toUser) {
    if (err) {
      console.log('Error:'+err)
      return cb && cb(err);
    }
    if (toUser && toUser.type && toUser.token) {
      pushTokens.findOne({ type: toUser.type, token: toUser.token }, function (err, pushTokenObj) {
        if (err) {
          console.log('Error:' + err);
          return cb && cb(err);
        }
        if (!pushTokenObj || pushTokenObj.userId !== toUser._id) {
          return cb && cb('pushToken not found');
        }
        var content = '';
        var msgText = '';
        var pushToken = {
          type: toUser.type,
          token: toUser.token
        };
        if(message.type === 'image'){
          msgText = '[图片]';
        } else {
          msgText = message.text;
        }
        if(type == 'usermessage'){
            content = message.form.name+ ': ' + msgText;
        }
        if(type === 'groupmessage'){
          if(message.is_people)
            content = message.to.name+ ': ' + ' 有新消息';
          else
            content = message.to.name+ ': ' +  msgText;
        }
        var commentText = '';
        var extras = {
          type: type,
          messageId: message._id
        }
        var waitReadCount = (toUser.profile && toUser.profile.waitReadCount) ? toUser.profile.waitReadCount : 1;
        var tidyDoc = {
          _id: message._id,
          form: message.form.id,
          to: message.to.id,
          to_type: message.to_type,
          type: message.type,
          text: message.text,
          create_time: message.create_time
        };

        var dataObj = {
          fromserver: encodeURIComponent(serverUrl),
          eventType: type,
          doc: tidyDoc,
          userId: userId,
          content: content,
          extras: extras,
          toUserId: toUserId,
          pushToken: pushToken,
          waitReadCount: waitReadCount
        }
        var dataArray = [];
        dataArray.push(dataObj);
        debug_on && console.log(JSON.stringify(dataArray))
        PushMessages.insert({pushMessage: dataArray, createAt: new Date()},function(err,result){
          if(err){
            console.log('Error:'+err);
            return cb && cb(err);
          } else {
            debug_on && console.log(result)
            return cb && cb(null);
          }
        })
      });
    }
    else {
      return cb && cb('toUser/type/token not found');
    }
  });
}

function sendUserNotification(db, message, type){
  var BlackList = db.collection('blackList');
  var toUserId  = message.to.id;
  var userId    = message.form.id;
  BlackList.findOne({blackBy: toUserId,blacker:{$in:[userId]}},function(err, result){
    if (err){
      debug_on && console.log('mongo blackList Error:',err);
      return
    }

    if (result) {
      debug_on && console.log('在对方黑名单中， userId='+ userId +' ,toUserId='+ toUserId);
      return
    }
    sendNotification(message, toUserId, type, function(err) {
        if(err)
            console.log('sendUserNotification: err=' + err);
    });
  });
};

function sendGroupNotification(db, message, type){
  var groupUsers = db.collection('simple_chat_groups_users');

  var groupId = message.to.id;
  groupUsers.find({group_id:  groupId}).toArray(function(err, docs) {
    if(err){
      return
    }

    forEachAsynSeriesWait(docs, 5, 10, function(doc, index, callback) {
        if(message.form.id != doc.user_id) {
            var keystring = 'Train_' + groupId + '_' + doc.user_id;
            debug_on && console.log('>>> add task to queue, user_id=' + keystring);
            workQueue.createTaskToKueQueue(keystring, {key: keystring, msg: message, userid: doc.user_id, type: type});
            return callback && callback();
        }
        else
            return callback && callback();
    }, function() {
        console.log('send GroupNotification complete, messageForm:',JSON.stringify(message.form));
    })
  });
};

mqttPushNotificationInit();
