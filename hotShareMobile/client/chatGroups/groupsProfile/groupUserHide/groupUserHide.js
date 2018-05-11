Template.groupUserHide.onRendered(function(){
  var group_id = Router.current().params._id;
  Session.set('groupUserHideLimit',20);
  Session.set('groupUserHideLoaded','loading');
  Session.set('groupUserHideLoadedCount',0);
  Meteor.subscribe('group-user-relations',group_id,Session.get('groupUserHideLimit'),function(){
    Session.set('groupUserHideLoaded','loaded');
  });
  Session.set('noshowPerson',true);
  $('html,body').scrollTop(0);
  // 页面滚动监听
  $(document).on('scroll', function(){
    var diff = $('.userHideLists').height() - $('html,body').scrollTop() - $('body').height() + 40;
    if(diff < 0){
      console.log('loading', diff)
      var limit = Session.get('groupUserHideLimit');
      limit = limit + 20;
      Session.set('groupUserHideLoaded','loading');
      Meteor.subscribe('group-user-relations',group_id,limit,function(){
        Session.set('groupUserHideLoaded','loaded');
        var count = WorkAIUserRelations.find({'group_id':group_id}).count();
        if(Session.get('groupUserHideLoadedCount') < count){
          Session.set('groupUserHideLoadedCount',count);
          Session.set('groupUserHideLimit',limit);
        }
      });
    }
  });

});

Template.groupUserHide.helpers({
  lists: function () {
    var group_id = Router.current().params._id;
    return  WorkAIUserRelations.find({'group_id':group_id}).fetch();
  },
  icon: function (){
    if(this.ai_in_image){
      return this.ai_in_image;
    }
    if(this.checkin_image){
      return this.checkin_image;
    }
    if(this.ai_out_image){
      return this.ai_out_image;
    }
    if(this.checkout_image){
      return this.checkout_image;
    }
    // if(this.app_user_icon){
    //   return this.app_user_icon;
    // }
    return '/userPicture.png';
  },
  isShow:function(){
    return !this.hide_it;
  },
  isHide: function(){
    return this.hide_it;
  },
  isLoading: function(){
    return Session.equals('groupUserHideLoaded','loading');
  },
  getConfig:function(type){
    var isShow = false, result = null;
    var group_id = Router.current().params._id;
    var group = SimpleChat.Groups.findOne({_id:group_id});
    if (group && group.settings) {
      switch(type){
        case 'push':
          result = group.settings.push_notification;
          break;
        case 'stranger':
          result = group.settings.notify_stranger;
          break;
        case 'email':
          result = group.settings.real_time_email;
          break;
        case 'report':
          result = group.settings.report;
          break;
        case 'stranger':
          result = group.settings.notify_stranger;
          break;
        case 'other':
          result = group.settings.other;
          break;
        case 'gif':
          result = group.settings.receive_gif;
          break;
      }
    }
    if (result || result == null || result == undefined) {
        isShow = true;
    }
    return {'hide_it': !isShow, 'isShow': isShow}
  },
  getIsShow: function(isShow) {
    console.log("Frank: isShow="+JSON.stringify(isShow));
  },
  noshowPerson:function(){
    return Session.get('noshowPerson');
  }
});

Template.groupUserHide.events({
  'click #goPerson':function(e){
    Session.set('noshowPerson',false);
  },
  'click .back': function(e){
    var noshowPerson = Session.get('noshowPerson');
    if(!noshowPerson){
      Session.set('noshowPerson',true);
      return;
    }
    var group_id = Router.current().params._id;
    Meteor.setTimeout(function(){
      $('html,body').scrollTop(Session.get('scrollTop'));
    },50);
    return Router.go('/groupsProfile/group/'+ group_id);
  },
  'click .switch':function(e){
    var _id = e.currentTarget.id;
    if(_id == 'report_id'){
        var group_id = Router.current().params._id;
        Meteor.call('update_group_settings', group_id, {'settings.report':!this.isShow});
        this.hide_it = !this.hide_it;
        this.isShow = !this.isShow;
        return;
    }
    if (_id == "stranger_id") {
        //localStorage.setItem('show_stranger_report', !this.hide_it);
        var group_id = Router.current().params._id;
        Meteor.call('update_group_settings', group_id, {'settings.notify_stranger':!this.isShow});
        this.hide_it = !this.hide_it;
        this.isShow = !this.isShow;
        console.log("Frank: this.hide_it="+JSON.stringify(this))
        return;
    }
    if(_id == "push"){
      var group_id = Router.current().params._id;
      Meteor.call('update_group_settings', group_id, {'settings.push_notification':!this.isShow});
      this.hide_it = !this.hide_it;
      this.isShow = !this.isShow;
      return;
    }
    if(_id == "email"){
      var group_id = Router.current().params._id;
      Meteor.call('update_group_settings', group_id, {'settings.real_time_email':!this.isShow});
      this.hide_it = !this.hide_it;
      this.isShow = !this.isShow;
      return;
    }
    if(_id == "other"){
      var group_id = Router.current().params._id;
      Meteor.call('update_group_settings', group_id, {'settings.other':!this.isShow});
      this.hide_it = !this.hide_it;
      this.isShow = !this.isShow;
      return;
    }
    if(_id == "gif_id"){
      var group_id = Router.current().params._id;
      Meteor.call('update_group_settings', group_id, {'settings.receive_gif':!this.isShow});
      this.hide_it = !this.hide_it;
      this.isShow = !this.isShow;
      return;
    }
    var isHide = this.hide_it;
    var group_id = this.group_id;
    var person_name = this.person_name;
    WorkAIUserRelations.update({_id: _id},{
        $set: {hide_it: !isHide}
      }, function(err, result){
        // PUB.hideWaitLoading();
        if(err){
          return console.log(err);
        }
        Meteor.call('update_workai_hide_it', group_id, person_name, !isHide);
      });
  },
  'click .btnShow': function(e){
    var _id = e.currentTarget.id;
    var group_id = this.group_id;
    var person_name = this.person_name;
    // PUB.showWaitLoading('正在处理');
    WorkAIUserRelations.update({_id: _id},{
      $set: {hide_it: false}
    }, function(err, result){
      // PUB.hideWaitLoading();
      if(err){
        return console.log(err);
      }
      Meteor.call('update_workai_hide_it', group_id, person_name, false);
    });
  },
  'click .btnHide': function(e){
    var _id = e.currentTarget.id;
    var group_id = this.group_id;
    var person_name = this.person_name;
    // PUB.showWaitLoading('正在处理')
    WorkAIUserRelations.update({_id: _id},{
      $set: {hide_it: true}
    }, function(err, result){
      // PUB.hideWaitLoading();
      if(err){
       return console.log(err);
      }
      Meteor.call('update_workai_hide_it', group_id, person_name, true);
    });
  }
})