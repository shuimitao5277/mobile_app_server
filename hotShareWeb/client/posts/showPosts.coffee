if Meteor.isClient
  @isIOS = (navigator.userAgent.match(/(iPad|iPhone|iPod)/g) ? true : false)
  @isWeiXinFunc = ()->
    ua = window.navigator.userAgent.toLowerCase()
    M = ua.match(/MicroMessenger/i)
    if M and M[0] is 'micromessenger'
      true
    else
      false
  @isAndroidFunc = ()->
    userAgent = navigator.userAgent.toLowerCase()
    return (userAgent.indexOf('android') > -1) or (userAgent.indexOf('linux') > -1)
  window.getDocHeight = ->
    D = document
    Math.max(
      Math.max(D.body.scrollHeight, D.documentElement.scrollHeight)
      Math.max(D.body.offsetHeight, D.documentElement.offsetHeight)
      Math.max(D.body.clientHeight, D.documentElement.clientHeight)
    )
  subscribeCommentAndViewers = ()->
    if Session.get("postContent")
      Meteor.setTimeout ()->
        Meteor.subscribe "comment",Session.get("postContent")._id
        Meteor.subscribe "viewers",Session.get("postContent")._id
      ,500
  onUserProfile = ->
    @PopUpBox = $('.popUpBox').bPopup
      positionStyle: 'fixed'
      position: [0, 0]
      onClose: ->
        Session.set('displayUserProfileBox',false)
      onOpen: ->
        Session.set('displayUserProfileBox',true)
  Template.showPosts.onDestroyed ->
    document.body.scrollTop = 0
    Session.set("postPageScrollTop", 0)
    Session.set("showSuggestPosts",false)
  Template.showPosts.onRendered ->
    #Calc Wechat token after post rendered.
    calcPostSignature(window.location.href.split('#')[0]);
    if Session.get("postPageScrollTop") isnt undefined and Session.get("postPageScrollTop") isnt 0
      Meteor.setTimeout ()->
          document.body.scrollTop = Session.get("postPageScrollTop")
        , 280
  Template.showPosts.onRendered ->
    Session.setDefault "toasted",false
    Session.set('postfriendsitemsLimit', 10)
    Session.set("showSuggestPosts",false)
    $('.mainImage').css('height',$(window).height()*0.55)
    postContent = Session.get("postContent")
    subscribeCommentAndViewers()
    browseTimes = 0
    Session.set("Social.LevelOne.Menu",'discover')
    Session.set("SocialOnButton",'postBtn')
    if not Meteor.isCordova
      favicon = document.createElement('link');
      favicon.id = 'icon';
      favicon.rel = 'icon';
      favicon.href = postContent.mainImage;
      document.head.appendChild(favicon);
    Deps.autorun (h)->
      if Meteor.userId() and Meteor.userId() isnt ''
        h.stop()
        Meteor.call('readPostReport',postContent._id,Meteor.userId())
    $('.textDiv1Link').linkify();
    $("a[target='_blank']").click((e)->
      e.preventDefault();
      if Meteor.isCordova
        Session.set("isReviewMode","undefined")
        prepareToEditorMode()
        PUB.page '/add'
        handleAddedLink($(e.currentTarget).attr('href'))
      else
        window.open($(e.currentTarget).attr('href'), '_blank', 'hidden=no,toolbarposition=top')
    )

    $('.showBgColor').css('min-height',$(window).height())
    showSocialBar = ()->
      displaySocialBar = $(".socialContent #socialContentDivider").isAboveViewPortBottom();
      if displaySocialBar
        unless $('.contactsList .head').is(':visible')
          $('.contactsList .head').fadeIn 300
        unless $('.userProfile .head').is(':visible')
          $('.userProfile .head').fadeIn 300
      unless $('.socialContent .chatFooter').is(':visible')
        $('.socialContent .chatFooter').fadeIn 300
    hideSocialBar = ()->
      if $('.contactsList .head').is(':visible')
        $('.contactsList .head').fadeOut 300
      if $('.socialContent .chatFooter').is(':visible')
        $('.socialContent .chatFooter').fadeOut 300
    scrollEventCallback = ()->
      #Sets the current scroll position
      st = $(window).scrollTop()
      if st is 0
        showSocialBar()
        unless $('.showPosts .head').is(':visible')
          $('.showPosts .head').fadeIn 300
        window.lastScroll = st
        return

      if window.lastScroll - st > 5
        $('.showPosts .head').fadeIn 300
        showSocialBar()
      if window.lastScroll - st < -5
        $('.showPosts .head').fadeOut 300
        displaySocialBar = $(".socialContent #socialContentDivider").isAboveViewPortBottom();
        if displaySocialBar
          Session.set("showSuggestPosts",true)
          showSocialBar()
        else
          hideSocialBar()
      if(st + $(window).height()) is window.getDocHeight()
        showSocialBar()
        window.lastScroll = st
        return
      # Changed is too small
      if Math.abs(window.lastScroll - st) < 5
        return
      #Determines up-or-down scrolling
      displaySocialBar = $(".socialContent #socialContentDivider").isAboveViewPortBottom();
      if displaySocialBar
        #showSocialBar()
        if $(".div_discover").css("display") is "block"
          Session.set("SocialOnButton",'discover')
        if $(".div_contactsList").css("display") is "block"
          Session.set("SocialOnButton",'contactsList')
        if $(".div_me").css("display") is "block"
          Session.set("SocialOnButton",'me')
      else
        if $('.contactsList .head').is(':visible')
          $('.contactsList .head').fadeOut 300
        Session.set("SocialOnButton",'postBtn')
      #Updates scroll position
      window.lastScroll = st
    window.lastScroll = 0;

    if withSocialBar
      $(window).scroll(scrollEventCallback)

  Template.showPosts.helpers
    withSectionMenu: withSectionMenu
    withSectionShare: withSectionShare
    withPostTTS: withPostTTS
    getMainImageHeight:()->
      $(window).height()*0.55
    getAbstractSentence:->
      if Session.get('focusedIndex') isnt undefined
        Session.get('postContent').pub[Session.get('focusedIndex')].text
      else
        null
    getAbstractSentenceIndex:->
      pub = Session.get('postContent').pub
      index = Session.get('focusedIndex')
      count = 0
      for i in [0..index]
        if pub[i].type is 'text'
          count++
      count
    displayForwardBtn:()->
      if history.length>1 and Session.get("historyForwardDisplay") is true
        true
      else
        false
    displayBackBtn:()->
      if history.length>1
        postId=Session.get("postContent")._id
        firstId=Session.get("firstPost")
        if postId isnt firstId
          true
        else
          false
      else
        postId=Session.get("postContent")._id
        Session.set("firstPost",postId)
        false
    myselfClickedUp:->
      i = this.index
      userId = Meteor.userId()
      post = Session.get("postContent").pub
      if post[i] isnt undefined and post[i].dislikeUserId isnt undefined and post[i].likeUserId[userId] is true
        return true
      else
        return false
    myselfClickedDown:->
      i = this.index
      userId = Meteor.userId()
      post = Session.get("postContent").pub
      if post[i] isnt undefined and post[i].dislikeUserId isnt undefined and post[i].dislikeUserId[userId] is true
        return true
      else
        return false
    getPub:->
      self = this
      self.pub = self.pub || []
      _.map self.pub, (doc, index, cursor)->
        _.extend(doc, {index: index})
    displayCommentInputBox:()->
      Session.get('displayCommentInputBox')
    inWeiXin: ()->
      isWeiXinFunc()
    withAfterPostIntroduce: ()->
      withAfterPostIntroduce
    withSocialBar: ()->
      withSocialBar
    isCordova:()->
      Meteor.isCordova
    refcomment:->
      RC = Session.get 'RC'
      #console.log "RC: " + RC
      RefC = Session.get("refComment")
      if RefC
        return RefC[RC].text
    time_diff: (created)->
      GetTime0(new Date() - created)
    isMyPost:->
      if Meteor.user()
        if Posts.find({_id:this._id}).count() > 0
          post = Posts.find({_id:this._id}).fetch()[0]
          if post.owner is Meteor.userId()
            return true
      return false
    isMobile:->
      Meteor.isCordova
    haveUrl:->
      if Session.get("postContent").fromUrl is undefined  or Session.get("postContent").fromUrl is ''
        false
      else
        true
  sectionToolbarClickHandler = (self,event,node)->
    console.log('Index ' + self.index + ' Action ' + $(node).attr('action') )
    action = $(node).attr('action')
    if action is 'section-forward'
      if Meteor.isCordova
        options = {
          'androidTheme': window.plugins.actionsheet.ANDROID_THEMES.THEME_HOLO_LIGHT, # default is THEME_TRADITIONAL
          'title': '分享',
          'buttonLabels': ['分享给微信好友', '分享到微信朋友圈','分享到QQ','分享到更多应用'],
          'androidEnableCancelButton' : true, #default false
          'winphoneEnableCancelButton' : true, #default false
          'addCancelButtonWithLabel': '取消',
          #'position': [20, 40] # for iPad pass in the [x, y] position of the popover
        }
        window.plugins.actionsheet.show(options, (buttonIndex)->
          switch buttonIndex
            when 1 then shareTo('WXSession',Blaze.getData($('.showPosts')[0]),self.index)
            when 2 then shareTo('WXTimeLine',Blaze.getData($('.showPosts')[0]),self.index)
            when 3 then shareTo('QQShare',Blaze.getData($('.showPosts')[0]),self.index)
            when 4 then shareTo('System',Blaze.getData($('.showPosts')[0]),self.index)
        );
      else
        toastr.success('将在微信分享时引用本段内容', '您选定了本段文字')
        console.log('Selected index '+self.index)
        Router.go('/posts/'+Session.get('postContent')._id+'/'+self.index)
  Template.showPosts.events
    'click .postTextItem' :(e)->
      if withSectionMenu
        console.log('clicked on textdiv ' + this._id)
        $self = $('#'+this._id)
        toolbar = $self.data('toolbarObj')
        unless toolbar
          self = this
          $self.toolbar
            content: '.section-toolbar'
            position: 'bottom'
            hideOnClick: true
          $self.on 'toolbarItemClick',(event,buttonClicked)->
            sectionToolbarClickHandler(self,event,buttonClicked)
          $self.data('toolbarObj').show()
    'click #ViewOnWeb' :->
      if Session.get("postContent").fromUrl
        if Meteor.isCordova
          Session.set("isReviewMode","undefined")
          prepareToEditorMode()
          PUB.page '/add'
          handleAddedLink(Session.get("postContent").fromUrl)
        else
          window.location.href=Session.get("postContent").fromUrl
    'click .userDashboard':->
      Session.set("ProfileUserId1", this.owner)
      Session.set("currentPageIndex",-1)
      Meteor.subscribe("userinfo", this.owner)
      Meteor.subscribe("recentPostsViewByUser", this.owner)
      onUserProfile()
    "click .showPostsFollowMe span a":->
      if Meteor.isCordova
        cordova.plugins.clipboard.copy('故事贴')
        PUB.toast('请在微信中搜索关注公众号“故事贴”(已复制到粘贴板)')
        return
      if isIOS
        window.location.href="http://mp.weixin.qq.com/s?__biz=MzAwMjMwODA5Mw==&mid=209526606&idx=1&sn=e8053772c8123501d47da0d136481583#rd"
      if isAndroidFunc()
        window.location.href="weixin://profile/gh_5204adca97a2"
    "click .change":->
      RC = Session.get("RC")+1
      if RC>7
         RC=0
      Session.set("RC", RC)
    'click #finish':->
      if PopUpBox
        PopUpBox.close()
      else
        $('.popUpBox').hide 0
    "click #submit":->
      $("#new-reply").submit()

      # here need to subscribe refcomments again, otherwise cannot get refcomments data
      Meteor.subscribe "refcomments", ()->
        Meteor.setTimeout ()->
          refComment = RefComments.find()
          if refComment.count() > 0
            Session.set("refComment",refComment.fetch())
      if PopUpBox
        PopUpBox.close()
      else
        $('.popUpBox').hide 0
    "submit .new-reply": (event)->
      # This function is called when the new task form is submitted
      content = event.target.comment.value
      console.log content
      if content is ""
        return false

      FollowPostsId = Session.get("FollowPostsId")
      postId = Session.get("postContent")._id
      if Meteor.user()
        if Meteor.user().profile.fullname
          username = Meteor.user().profile.fullname
        else
          username = Meteor.user().username
        userId = Meteor.user()._id
        userIcon = Meteor.user().profile.icon
      else
        username = '匿名'
        userId = 0
        userIcon = ''
      try
        Comment.insert {
          postId:postId
          content:content
          username:username
          userId:userId
          userIcon:userIcon
          createdAt: new Date()
        }
        FollowPosts.update {_id: FollowPostsId},{$inc: {comment: 1}}
      catch error
        console.log error
      event.target.comment.value = ""
      $("#comment").attr("placeholder", "说点什么")
      $("#comment").css('height', 'auto')
      $('.contactsList .head').fadeOut 300
      false
    'focus .commentArea':->
      console.log("#comment get focus");
      if Meteor.isCordova and isIOS
        cordova.plugins.Keyboard.disableScroll(true)
    'blur .commentArea':->
      console.log("#comment lost focus");
      if Meteor.isCordova and isIOS
        cordova.plugins.Keyboard.disableScroll(false)
    'click .showPosts .forward' :->
      Session.set("pcommetsId","")
      Session.set("pcommentsName","")
      $(window).children().off()
      $(window).unbind('scroll')
      history.forward()
    'click .showPosts .back' :->
      Session.set("pcommetsId","")
      Session.set("pcommentsName","")
      Session.set("historyForwardDisplay", true)
      $(window).children().off()
      $(window).unbind('scroll')
      history.back()
    'click #edit': (event)->
      #Clear draft first
      Drafts.remove({})
      #Prepare data from post
      fromUrl = ''
      if this.fromUrl and this.fromUrl isnt ''
        fromUrl = this.fromUrl
      draft0 = {_id:this._id, type:'image', isImage:true, url: fromUrl, owner: Meteor.userId(), imgUrl:this.mainImage, filename:this.mainImage.replace(/^.*[\\\/]/, ''), URI:"", data_row:0,style:this.mainImageStyle}
      Drafts.insert(draft0)
      pub = this.pub;
      if pub.length > 0
        for i in [0..(pub.length-1)]
          Drafts.insert(pub[i])
      Session.set 'isReviewMode','2'
      #Don't push showPost page into history. Because when save posted story, it will use Router.go to access published story directly. But in history, there is a duplicate record pointing to this published story.
      Router.go('/add')
    'click #unpublish': (event)->
      self = this
      navigator.notification.confirm('取消发表的故事将会被转换为草稿。', (r)->
        if r isnt 2
          return
        PUB.page('/user')
        fromUrl = ''
        if self.fromUrl and self.fromUrl isnt ''
          fromUrl = self.fromUrl
        draft0 = {_id:self._id, type:'image', isImage:true, url:fromUrl ,owner: Meteor.userId(), imgUrl:self.mainImage, filename:self.mainImage.replace(/^.*[\\\/]/, ''), URI:"", data_row:0}
        self.pub.splice(0, 0, draft0);

        Posts.remove {
          _id:self._id
        }

        SavedDrafts.insert {
          _id:self._id,
          pub:self.pub,
          title:self.title,
          fromUrl:fromUrl,
          addontitle:self.addontitle,
          mainImage: self.mainImage,
          mainText: self.mainText,
          owner:Meteor.userId(),
          createdAt: new Date(),
        }
        return
      , '取消发表故事', ['取消','取消发表']);


    'click #report': (event)->
      Router.go('reportPost')
    'click .postImageItem': (e)->
      swipedata = []
      i = 0
      selected = 0
      console.log "=============click on image index is: " + this.index
      for image in Session.get('postContent').pub
        if image.imgUrl
          if image.imgUrl is this.imgUrl
            selected = i
          swipedata.push
            href: image.imgUrl
            title: image.text
          i++
      $.swipebox swipedata,{
        initialIndexOnArray: selected
        hideCloseButtonOnMobile : true
        loopAtEnd: false
      }
  Template.postFooter.helpers
    refcomment:->
      RC = Session.get 'RC'
      RefC = Session.get("refComment")
      if RefC
        return RefC[RC].text
    heart:->
      Session.get("postContent").heart.length
    retweet:->
      Session.get("postContent").retweet.length
    comment:->
      Session.get("postContent").commentsCount
      #Comment.find({postId:Session.get("postContent")._id}).count()
    blueHeart:->
      heart = Session.get("postContent").heart
      if Meteor.user()
        if JSON.stringify(heart).indexOf(Meteor.userId()) is -1
          return false
        else
          return true
      else
        return amplify.store( Session.get("postContent")._id)
    blueRetweet:->
      retweet = Session.get("postContent").retweet
      if JSON.stringify(retweet).indexOf(Meteor.userId()) is -1
        return false
      else
        return true
  heartOnePost = ->
    Meteor.subscribe "refcomments", ()->
      Meteor.setTimeout ()->
        refComment = RefComments.find()
        if refComment.count() > 0
          Session.set("refComment",refComment.fetch())
    if Meteor.user()
      postId = Session.get("postContent")._id
      FollowPostsId = Session.get("FollowPostsId")
      heart = Session.get("postContent").heart
      if JSON.stringify(heart).indexOf(Meteor.userId()) is -1
        heart.sort()
        heart.push {userId: Meteor.userId(),createdAt: new Date()}
        Posts.update {_id: postId},{$set: {heart: heart}}
        FollowPosts.update {_id: FollowPostsId},{$inc: {heart: 1}}
        return
    else
      postId = Session.get("postContent")._id
      heart = Session.get("postContent").heart
      heart.sort()
      heart.push {userId: 0,createdAt: new Date()}
      Posts.update {_id: postId},{$set: {heart: heart}}
      amplify.store(postId,true)
  onComment = ->
    window.PopUpBox = $('.popUpBox').bPopup
      positionStyle: 'fixed'
      position: [0, 0]
      onClose: ->
        Session.set('displayCommentInputBox',false)
      onOpen: ->
        Session.set('displayCommentInputBox',true)
        Meteor.setTimeout ->
            $('.commentArea').focus()
          ,300
        console.log 'Modal opened'
  onRefresh = ->
    RC = Session.get("RC")+1
    if RC>7
       RC=0
    Session.set("RC", RC)
  unless Meteor.isCordova
    if isIOS
      Template.postFooter.events
        'touchstart .refresh':onRefresh
        'touchstart .comment':onComment
        'touchstart .heart':heartOnePost
  Template.postFooter.events
    'click .refresh':onRefresh
    'click .comment':onComment
    'click .heart':heartOnePost
    'click .retweet':->
      if Meteor.user()
        postId = Session.get("postContent")._id
        FollowPostsId = Session.get("FollowPostsId")
        retweet = Session.get("postContent").retweet
        if JSON.stringify(retweet).indexOf(Meteor.userId()) is -1
          retweet.sort()
          retweet.push {userId: Meteor.userId(),createdAt: new Date()}
          Posts.update {_id: postId},{$set: {retweet: retweet}}
          FollowPosts.update {_id: FollowPostsId},{$inc: {retweet: 1}}
          return
    'click .blueHeart':->
      Meteor.subscribe "refcomments", ()->
          Meteor.setTimeout ()->
            refComment = RefComments.find()
            if refComment.count() > 0
              Session.set("refComment",refComment.fetch())
      if Meteor.user()
        postId = Session.get("postContent")._id
        FollowPostsId = Session.get("FollowPostsId")
        heart = Session.get("postContent").heart
        if JSON.stringify(heart).indexOf(Meteor.userId()) isnt -1
          arr = []
          for item in heart
            if item.userId isnt Meteor.userId()
              arr.push {userId:item.userId,createdAt:item.createdAt}
          Posts.update {_id: postId},{$set: {heart: arr}}
          FollowPosts.update {_id: FollowPostsId},{$inc: {heart: -1}}
          return
    'click .blueRetweet':->
      if Meteor.user()
        postId = Session.get("postContent")._id
        FollowPostsId = Session.get("FollowPostsId")
        retweet = Session.get("postContent").retweet
        if JSON.stringify(retweet).indexOf(Meteor.userId()) isnt -1
          arr = []
          for item in retweet
            if item.userId isnt Meteor.userId()
              arr.push {userId:item.userId,createdAt:item.createdAt}
          Posts.update {_id: postId},{$set: {retweet: arr}}
          FollowPosts.update {_id: FollowPostsId},{$inc: {retweet: -1}}
          return
  Template.pCommentsList.helpers
      time_diff: (created)->
        GetTime0(new Date() - created)
      hasPcomments: ->
         i = Session.get "pcommentIndexNum"
         post = Session.get("postContent").pub
         if post and post[i] and post[i].pcomments isnt undefined
           return true
         else
           return false
      pcomments:->
         i = Session.get "pcommentIndexNum"
         post = Session.get("postContent").pub
         if post[i] isnt undefined
           return post[i].pcomments
         else
           return ''

  Template.pCommentsList.events
      'click #pcommitReportBtn':(e, t)->
        i = Session.get "pcommentIndexNum"
        content = t.find('#pcommitReport').value
        if content is ""
          return false
        postId = Session.get("postContent")._id
        post = Session.get("postContent").pub
        if Meteor.user()
          if Meteor.user().profile.fullname
            username = Meteor.user().profile.fullname
          else
            username = Meteor.user().username
          userId = Meteor.user()._id
          userIcon = Meteor.user().profile.icon
        else
          username = '匿名'
          userId = 0
          userIcon = ''
        if not post[i].pcomments
          pcomments = []
          post[i].pcomments = pcomments
        pcommentJson = {
          content:content
          username:username
          userId:userId
          userIcon:userIcon
          createdAt: new Date()
        }
        post[i].pcomments.push(pcommentJson)
        Posts.update({_id: postId},{"$set":{"pub":post,"ptype":"pcomments","pindex":i}}, (error, result)->
          if error
            console.log(error.reason);
          else
            console.log("success");
        )
        t.find('#pcommitReport').value = ""
        $("#pcommitReport").attr("placeholder", "说点什么")
        false
