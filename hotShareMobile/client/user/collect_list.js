var limit = 10;
var pageSize = 10;

Template.collectList.helpers({
  collectList: function () {
    var list = SimpleChat.CollectMessages.find({}, {sort: {collectDate: -1}, limit: limit}).fetch();
    return list;
  },
  
});

Template.collectItem.helpers({
  isImage: function(type) {
    return type === 'image';
  },
  isMotion: function() {
    return this.event_type === 'motion';
  },
  name: function() {
    if (this.form.id !== Meteor.userId) {
      return this.form.name;
    } else {
      return this.to.name;
    }
  },
  collectDate: function() {
    var date = new Date(this.collectDate);
    var year = date.getFullYear();
    var month = date.getMonth() + 1;
    var day = date.getDate();
    var dateStr = year + '/' + month + '/' + day;
    return dateStr;
  }
});

Template.collectList.events({
  'click .back': function(e) {
    return Router.go('/user');
  },
});

Template.collectItem.events({
  'click .delBtn': function(e) {
    SimpleChat.CollectMessages.remove({_id: this._id});
  },
  'click img.swipebox': function(e) {
    var initialIndex;
    var parentItemData = Blaze.getData(Template.collectItem.view);
    var images = parentItemData.images.map(function(item, index) {
      if (item.url === e.target.src) {
        initialIndex = index;
      }
      return {
        href: item.url,
        title: ''
      };
    });
    $.swipebox(images, {
      initialIndexOnArray: initialIndex,
      hideCloseButtonOnMobile : true,
      loopAtEnd: false
    });
  }
});

var loadMore = function() {
  if ($(window).scrollTop() + $(window).height() >= $(document).height()) {
    var loadedCount = SimpleChat.CollectMessages.find({}, {sort: {collectDate: -1}, limit: limit}).count();
    if (loadedCount !== limit) return;
    limit += pageSize;
    Meteor.subscribe('collectedMessages', {sort: {collectDate: -1}, limit: limit});
    $('body').empty();
    Blaze.render(Template.collectList, document.body);
  }
};

window.addEventListener('scroll', function() {
  loadMore();
}, false);



