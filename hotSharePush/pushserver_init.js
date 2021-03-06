// Generated by CoffeeScript 1.12.2
(function() {
  var root;
  var fs          = require('fs');

  root = typeof exports !== "undefined" && exports !== null ? exports : this;
  var CordovaPush = require('./push.server.js').CordovaPush;
  var pushServer;

  var Assets = {};
  Assets.getText = function(str) {
    return require('path').dirname(process.mainModule.filename)+'/private/'+str;
  }
  update_workai_pushNotifacation_status = function(userId){
    var workaiUserRelations = db.collection('workaiUserRelations');
    workaiUserRelations.findOne({app_user_id:userId},function(err,relationObj){
      if (err) {
        console.log('Error:' + err);
        return;
      }
      if (!relationObj) {
        console.log('workaiUserRelations not found');
        return;
      }
      workaiUserRelations.update({_id:relation._id},{$set:{app_notifaction_status:'off'}});
      var workStatus = db.collection('workStatus');
      workStatus.update({app_user_id:userId},{$set:{app_notifaction_status:'off'}},{multi: true});
    });
  };
  initPushServer = function() {
    var errCallback = function(errorNum, notification){
        console.log('Error is: %s', errorNum);
        console.log("Note " + JSON.stringify(notification));
        if (notification && notification.messageFrom) {
          update_workai_pushNotifacation_status(notification.messageFrom);
        }
    }

    var apnsDevCert, apnsDevKey, apnsProductionCert, apnsProductionKey, optionsDevelopment, optionsProduction;
    apnsDevCert = fs.readFileSync(Assets.getText('ios/apn-development/WorkAI_PN_DEV_Cert.pem'));
    apnsDevKey = fs.readFileSync(Assets.getText('ios/apn-development/WorkAI_PN_DEV_Key.pem'));
    optionsDevelopment = {
      errorCallback: errCallback,
      passphrase: '1234',
      certData: apnsDevCert,
      keyData: apnsDevKey,
      gateway: 'gateway.sandbox.push.apple.com'
    };
    apnsProductionCert = fs.readFileSync(Assets.getText('ios/apn-production/WorkAI_PN_Production_Cert.pem'));
    apnsProductionKey = fs.readFileSync(Assets.getText('ios/apn-production/WorkAI_PN_Production_Key.pem'));
    //console.log("apnsProductionCert="+apnsProductionCert);
    //console.log("apnsProductionKey="+apnsProductionKey);
    optionsProduction = {
      errorCallback: errCallback,
      passphrase: '123456',
      certData: apnsProductionCert,
      keyData: apnsProductionKey,
      gateway: 'gateway.push.apple.com',
    };
    pushServer = new CordovaPush('AIzaSyAeo0xEPBfrUJ5MztClvICNo-ZLIHcM8Zo', optionsProduction);
    pushServer.initFeedback();
    console.log("Push server initialized successfully!");
    return root.pushServer = pushServer;
  };

}).call(this);
