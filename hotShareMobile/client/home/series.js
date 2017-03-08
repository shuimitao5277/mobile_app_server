var updateOrInsertSeries = function(isNewSeries,publish){
  if($('#seriesTitle').val() === ''){
    return PUB.toast('请输入标题');
  }
  if($(".series-post-item").length === 0){
    return PUB.toast('请至少添加一个故事')
  }
  var title = $('#seriesTitle').val();
  var posts = []
  var mainImage = $('.series-title').data('image');
  var owner = Meteor.user();
  var ownerName = owner.profile.fullname ? owner.profile.fullname: owner.username;
  var ownerIcon = owner.profile.icon
  var num = 0;
  $('.series-post-item').each(function(index){
    posts.push({
        postId:$(this).attr('id'),
        postTitle: $(this).data('title'),
        postAddonTitle: $(this).data('addontitle'),
        postMainImage: $(this).data('image'),
        postIndex: num,
        postOwner: owner._id,
        postOwnerName: ownerName,
        postOwnerIcon: ownerIcon
    });
    num++;
  });
  if(isNewSeries){
    Series.insert({
        title: title,
        mainImage: mainImage,
        owner: owner._id,
        ownerName: ownerName,
        ownerIcon: ownerIcon,
        createdAt: new Date(),
        postLists: posts,
        publish: publish
    },function(err,_id){
      if(err){
        console.log('insert series ERR=',err)
      } else {
        console.log('insert series successed ,ID=',_id)
      }
    });
  } else {
    console.log('update series')
    Series.update({
      _id: Session.get('seriesId')
    },{
      $set:{
        title: title,
        mainImage: mainImage,
        postLists: posts,
        updateAt: new Date(),
        publish: true
      }
    },function(err,num){
      if(err){
        console.log('update series ERR=',err)
      } else {
        console.log('update series successed ,num=',num)
      }
    });
  }
  Session.set('seriesId','');
  Session.set('seriesContent','');
  Session.set('isSeriesEdit',false);
  Router.go('/seriesList');
}
Template.series.helpers({
  postsLists: function(){
    if(Session.get('seriesContent')){
      return Session.get('seriesContent').postLists
    }
  },
  isSeriesEdit: function(){
    return Session.equals('isSeriesEdit',true);
  },
  postCounts: function(){
    var seriesContent = Session.get('seriesContent')
    return (seriesContent && seriesContent.postLists)?seriesContent.postLists.length : 0
  },
  seriesTitle: function(){
    if(Session.get('seriesContent') && Session.get('seriesContent').title){
      return Session.get('seriesContent').title;
    } else {
      return "";
    }
  },
  mainImage: function() {
    if(Session.get('seriesContent') && Session.get('seriesContent').mainImage){
      return Session.get('seriesContent').mainImage;
    } else {
      return 'http://data.tiegushi.com/ocmainimages/mainimage5.jpg';
    }
  },
  showPublishBtn: function(){
    if(Session.get('seriesContent')){
      return !Session.get('seriesContent').publish && Template.series.__helpers.get('postCounts')()
    } else {
      return true;
    }
  }
});

Template.series.events({
  'click .share-btn': function(e){
    console.log('will share')
  },
  'click .back': function(e,t){
    if(!Session.get('seriesIsSaved') && Session.get('isSeriesEdit')){
       if(Session.get('seriesId') && Session.get('seriesId') !== ''){
        navigator.notification.confirm('这个操作无法撤销', function(r){
          if(r !== 1){
            updateOrInsertSeries(false,true);
          }
          Router.go('/seriesList');
        },'您确定要放弃未保存的修改吗？', ['放弃修改','保存修改']);
       } else {
        navigator.notification.confirm('这个操作无法撤销', function(r){
          if(r !== 1){
            updateOrInsertSeries(true,false);
          }
          Router.go('/seriesList');
        },'您确定要放弃未保存的修改吗？', ['放弃修改','存为草稿']);
       }
    } 
    Router.go('/seriesList');
  },
  'click #edit': function(e,t){
    return Session.set('isSeriesEdit',true);
  },
  'click #save':function(){
    Session.set('seriesIsSaved',true);
  },
  'click .editAndAddNew': function(e,t){
    Session.set('isSeriesEdit',true);
    Session.set('seriesIsSaved',false);
    $('.author-self-posts').toggle();
  },
  'click #seriesTitle':function(e,t){
    e.preventDefault();
    e.stopPropagation();
    $(this).focus();
    Session.set('seriesIsSaved',false);
  },
  'click .series-title':function(){
    $('.mainImageTools').toggle();
  },
  'click .imageToolBtn': function(e,t){
    $('.mainImageTools').hide();
    if(e.currentTarget.id === 'useOfficalImage'){
      $('#seriesTitle').hide();
      $('.mainImagesList').show();
    } else {
      Meteor.defer(function() {
        selectMediaFromAblum(1, function(cancel, result) {
          var data;
          if (cancel) {
            PUB.back();
            return;
          }
          if (result) {
            data = [
              {
                type: 'image',
                isImage: true,
                owner: Meteor.userId(),
                imgUrl: result.smallImage,
                filename: result.filename,
                URI: result.URI,
                layout: ''
              }
            ];
            return multiThreadUploadFileWhenPublishInCordova(data, null, function(err, result) {
              var i, item, len;
              if (!result) {
                window.plugins.toast.showShortBottom('上传失败，请稍后重试');
                return;
              }
              if (result.length < 1) {
                window.plugins.toast.showShortBottom('上传失败，请稍后重试');
                return;
              }
              for (i = 0, len = result.length; i < len; i++) {
                item = result[i];
                if (item.uploaded) {
                  if (item.type === 'image' && item.imgUrl) {
                    var seriesContent = Session.get('seriesContent');
                    seriesContent.mainImage = item.imgUrl
                    Session.set('seriesContent',seriesContent);
                  }
                }
              }
              if (err) {
                window.plugins.toast.showShortBottom('上传失败，请稍后重试');
                return;
              }
              return removeImagesFromCache(data);
            });
          }
        });
      });
    }
  },
  'click .series-post-item': function(e,t){
    $(e.currentTarget).toggleClass('series-post-item-not-select');
    return $(e.currentTarget).toggleClass('series-post-item-select');
  },
  'click .addNewPost': function(){
    Session.set('seriesIsSaved',false);
    $('.author-self-posts').toggle();
  },
  'click .has-dropdown, click .series-dropdown': function(){
    $('.series-dropdown').toggle();
  },
  'click #removeSelected': function(e,t){
    if($(".series-post-item-select").length === 0){
      return PUB.toast('请至少选择一个要删除故事')
    }
    Session.set('seriesIsSaved',false);
    var seriesContent = Session.get('seriesContent')
    var postLists = [];
    
    $('.series-post-item-not-select').each(function(index){
      postLists.push({
        postId:$(this).attr('id'),
        postMainImage: $(this).data('image'),
        postTitle:$(this).data('title'),
        postIndex: $(this).data('index')
      });
    });
    $('.series-post-item').removeClass('series-post-item-select');
    console.table(postLists)
    seriesContent.postLists = postLists;
    Session.set('seriesContent',seriesContent);
  },
  'click .viewModal':function(e,t){
    return Router.go('/posts/'+e.currentTarget.id);
  },
  'click #del':function(e,t){
    Series.remove({_id: Session.get('seriesId')});
    Router.go ('/seriesList');
  },  
  'click .publish':function(e,t){
    if(Session.get('seriesId') && Session.get('seriesId') !== ''){
      updateOrInsertSeries(false,true);   
    } else {
      updateOrInsertSeries(true,true);  
    }
  }
});