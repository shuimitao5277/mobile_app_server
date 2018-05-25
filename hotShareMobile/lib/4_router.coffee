subs = new SubsManager({
  #maximum number of cache subscriptions
  cacheLimit: 999,
  # any subscription will be expire after 30 days, if it's not subscribed again
  expireIn: 60*24*30
});

if Meteor.isClient
  @refreshPostContent=()->
    layoutHelperInit()
    Session.set("displayPostContent",false)
    setTimeout ()->
      Session.set("displayPostContent",true)
      calcPostSignature(window.location.href.split('#')[0])
    ,300
  renderPost = (self,post)->
    if !post
      return self.render 'postNotFound'

    # if post and Session.get('postContent') and post.owner isnt Meteor.userId() and post._id is Session.get('postContent')._id and String(post.createdAt) isnt String(Session.get('postContent').createdAt)
    #   Session.set('postContent',post)
    #   refreshPostContent()
    #   toastr.info('作者修改了帖子内容.')
    # else
    Session.set('postContent',post)
    Session.set('focusedIndex',undefined)
    if post and post.addontitle and (post.addontitle isnt '')
      documentTitle = "『故事贴』" + post.title + "：" + post.addontitle
    else if post
      documentTitle = "『故事贴』" + post.title
    Session.set("DocumentTitle",documentTitle)
    if post
      self.render 'showPosts', {data: post}
    else
      self.render 'unpublish'
    Session.set 'channel','posts/'+self.params._id
  renderPost2 = (self,post)->
    if !post or (post.isReview is false and post.owner isnt Meteor.userId())
      return this.render 'postNotFound'
    if post and Session.get('postContent') and post.owner isnt Meteor.userId() and post._id is Session.get('postContent')._id and String(post.createdAt) isnt String(Session.get('postContent').createdAt)
      Session.set('postContent',post)
      refreshPostContent()
      #toastr.info('作者修改了帖子内容.')
    else
      Session.set('postContent',post)
    Session.set('focusedIndex',undefined)
    if post and post.addontitle and (post.addontitle isnt '')
      documentTitle = "『故事贴』" + post.title + "：" + post.addontitle
    else if post
      documentTitle = "『故事贴』" + post.title
    Session.set("DocumentTitle",documentTitle)
    if post
      self.render 'showPosts', {data: post}
    else
      self.render 'unpublish'
    Session.set 'channel','posts/'+self.params._id
  renderPost3 = (self,post)->
    if !post or (post.isReview is false and post.owner isnt Meteor.userId())
      return this.render 'postNotFound'
    if post and Session.get('postContent') and post.owner isnt Meteor.userId() and post._id is Session.get('postContent')._id and String(post.createdAt) isnt String(Session.get('postContent').createdAt)
      Session.set('postContent',post)
      refreshPostContent()
      #toastr.info('作者修改了帖子内容.')
    else
      Session.set('postContent',post)

    if Session.get("doSectionForward") is true
      Session.set("doSectionForward",false)
      Session.set("postPageScrollTop",0)
      document.body.scrollTop = 0
    Session.set("refComment",[''])
    Session.set('focusedIndex',self.params._index)
    if post.addontitle and (post.addontitle isnt '')
      documentTitle = post.title + "：" + post.addontitle
    else
      documentTitle = post.title
    Session.set("DocumentTitle",documentTitle)
    favicon = document.createElement('link')
    favicon.id = 'icon'
    favicon.rel = 'icon'
    favicon.href = post.mainImage
    document.head.appendChild(favicon)
    unless Session.equals('channel','posts/'+self.params._id+'/'+self.params._index)
      refreshPostContent()
    self.render 'showPosts', {data: post}
    Session.set('channel','posts/'+self.params._id+'/'+self.params._index)
  Meteor.startup ()->
    Tracker.autorun ()->
      channel = Session.get 'channel'
      $(window).off('scroll')
      console.log('channel changed to '+channel+' Off Scroll')
      setTimeout ->
          Session.set 'focusOn',channel
        ,300
    Tracker.autorun ()->
      if Session.get('channel') isnt 'addPost' and (Session.get('focusOn') is 'addPost')
        console.log('Leaving addPost mode')
        Session.set('showContentInAddPost',false)
        if window.iabHandle
          window.iabHandle.close()
          window.iabHandle = null
    Router.route '/',()->
      this.render 'home'
      Session.set 'channel','home'
      return
    Router.route '/notice',()->
      this.render 'notice'
      return 
    Router.route '/message',()->
      this.render 'chatGroups'
      Session.set 'channel','message'
      return
    Router.route '/group/add',()->
      if Meteor.isCordova is true
        this.render 'groupAdd'
      return
    Router.route '/seriesList',()->
      this.render 'seriesList'
      Session.set 'channel','seriesList'
    Router.route '/mySeries',()->
      this.render 'mySeries'
      Session.set 'channel','mySeries'
    Router.route '/series',()->
      Session.set('seriesId','')
      this.render 'series'
      return
    Router.route '/series/:_id',()->
      Meteor.subscribe("oneSeries",this.params._id)
      Meteor.subscribe("seriesFollow", this.params._id)
      console.log(this.params._id)
      seriesContent = Series.findOne({_id: this.params._id})
      Session.set('seriesId',this.params._id)
      Session.set('seriesContent',seriesContent)
      this.render 'series'
      return
    Router.route '/splashScreen',()->
      this.render 'splashScreen'
      Session.set 'channel', 'splashScreen'
      return
    Router.route '/search',()->
      if Meteor.isCordova is true
        this.render 'search'
        Session.set 'channel','search'
      return
    Router.route '/searchFollow',()->
      if Meteor.isCordova is true
        this.render 'searchFollow'
        Session.set 'channel','searchFollow'
      return
    Router.route '/searchPeopleAndTopic',()->
      if Meteor.isCordova is true
        this.render 'searchPeopleAndTopic'
        Session.set 'channel','searchPeopleAndTopic'
      return
    Router.route '/cropImage',()->
      this.render 'cropImage'
      return
    Router.route '/addressBook',()->
      if Meteor.isCordova is true
        this.render 'addressBook'
        Session.set 'channel','addressBook'
      return
    Router.route '/groupsList',()->
      if Meteor.isCordova is true
        Meteor.subscribe("get-my-group",Meteor.userId())
        this.render 'groupsList'
        Session.set 'channel','groupsList'
      return
    Router.route '/groupsProfile/:_type/:_id',()->
      console.log 'this.params._type'+this.params._type
      if this.params._type is 'group'
        limit = withShowGroupsUserMaxCount || 29;
        Meteor.subscribe("get-group-user-with-limit",this.params._id,limit)
      else
        Meteor.subscribe('usersById',this.params._id)
      console.log(this.params._id)
      Session.set('groupsId',this.params._id)
      Session.set('groupsType',this.params._type)
      this.render 'groupsProfile'
      return
    Router.route '/simpleUserProfile/:_id',()->
      Session.set('simpleUserProfileUserId',this.params._id)
      this.render 'simpleUserProfile'
      return
    Router.route '/timeline',()->
      if Meteor.isCordova is true
        this.render 'timeline'
        Session.set 'channel','timeline'
      return
    Router.route '/clusteringFix/:_id',()->
      this.render 'clusteringFix'
      return
    Router.route '/clusteringFixPerson/:gid/:fid',()->
      this.render 'clusteringFixPerson'
      return
    # Router.route '/homePage',()->
    #   if Meteor.isCordova is true
    #     this.render 'homePage'
    #     Session.set 'channel','homePage'
    #   return
    Router.route '/timelineAlbum/:_uuid',()->
      console.log "TimeLine album: run into this page"
      this.render 'timelineAlbum'
      return
    Router.route '/device/dashboard/:group_id',()->
      this.render 'deviceDashboard'
      return
    Router.route '/recognitionCounts/:group_id',()->
      this.render 'recognitionCounts'
      return
    Router.route '/explore',()->
      if Meteor.isCordova is true
        this.render 'explore'
        Session.set 'channel','explore'
      return
    Router.route '/bell',()->
      if Meteor.isCordova is true
        this.render 'bell'
        Session.set 'channel','bell'
      return
    Router.route '/user',()->
      if Meteor.isCordova is true
        this.render 'user'
        Session.set 'channel','user'
        return
    Router.route '/dashboard',()->
      if Meteor.isCordova is true
        this.render 'dashboard'
        return
    Router.route '/perfShow/:_id',()->
      if Meteor.isCordova is true
        this.render 'perfShow'
        return
    Router.route '/followers',()->
      if Meteor.isCordova is true
        this.render 'followers'
        return
    Router.route '/add',()->
      if Meteor.isCordova is true
        this.render 'addPost'
        Session.set 'channel','addPost'
        return
    Router.route '/registerFollow',()->
      if Meteor.isCordova is true
        this.render 'registerFollow'
        Session.set 'channel','registerFollow'
        return
    Router.route '/authOverlay',()->
      if Meteor.isCordova is true
        this.render 'authOverlay'
        Session.set 'channel','authOverlay'
        return
      else
        this.render 'webHome'
        return
    Router.route '/loginForm', ()->
      this.render 'loginForm'
      return
    Router.route '/signupForm', ()->
      this.render 'signupForm'
      return
    Router.route '/recoveryForm', ()->
      this.render 'recoveryForm'
      return
    Router.route '/introductoryPage',()->
      this.render 'introductoryPage'
      Session.set 'channel','introductoryPage'
      return
    Router.route '/introductoryPage1',()->
      this.render 'introductoryPage1'
      Session.set 'channel','introductoryPage1'
      return
    Router.route '/introductoryPage2',()->
      this.render 'introductoryPage2'
      Session.set 'channel','introductoryPage2'
      return

    Router.route '/webHome',()->
      this.render 'webHome'
      return
    Router.route '/help',()->
      this.render 'help'
      return
    Router.route '/progressBar',()->
      if Meteor.isCordova is true
        this.render 'progressBar'
        Session.set 'channel','progressBar'
        return
    Router.route '/redirect/:_id',()->
      Session.set('nextPostID',this.params._id)
      this.render 'redirect'
      return
    Router.route '/groupInstallTest/:_id',()->
      this.render 'groupInstallTest'
      return
    Router.route '/groupPerson/:_id', ()->
      this.render 'groupPerson'
      return
    Router.route '/groupDevices/:_id', ()->
      this.render 'groupDevices'
      return 
    Router.route '/dayTasks/:_id', ()->
      this.render 'dayTasks'
      return
    Router.route '/bindGroupUser', ()->
      this.render 'bindGroupUser'
      return 
    Router.route '/bindUserPopup/:_id',()->
      this.render 'bindUserPopup'
      return
    Router.route '/comReporter/:_id',()->
      this.render 'companyItem'
      return
    Router.route '/collectList',()->
      Meteor.subscribe('collectedMessages', {sort: {collectDate: -1}, limit: 10})
      this.render 'collectList'
      return
    Router.route '/newLabel',()->
      this.render 'newLabel'
      return

    # Router.route '/posts/:_id', {
    #     waitOn: ->
    #       [subs.subscribe("publicPosts",this.params._id),
    #        subs.subscribe("postViewCounter",this.params._id),
    #        subs.subscribe("postsAuthor",this.params._id),
    #        subs.subscribe "pcomments"]
    #     loadingTemplate: 'loadingPost'
    #     action: ->
    #       post = Posts.findOne({_id: this.params._id})
    #       if !post or (post.isReview is false and post.owner isnt Meteor.userId())
    #         return this.render 'postNotFound'

    #       if post and Session.get('postContent') and post.owner isnt Meteor.userId() and post._id is Session.get('postContent')._id and String(post.createdAt) isnt String(Session.get('postContent').createdAt)
    #         Session.set('postContent',post)
    #         refreshPostContent()
    #         toastr.info('作者修改了帖子内容.')
    #       else
    #         Session.set('postContent',post)
    #       Session.set('focusedIndex',undefined)
    #       if post and post.addontitle and (post.addontitle isnt '')
    #         documentTitle = "『故事贴』" + post.title + "：" + post.addontitle
    #       else if post
    #         documentTitle = "『故事贴』" + post.title
    #       Session.set("DocumentTitle",documentTitle)
    #       if post
    #         this.render 'showPosts', {data: post}
    #       else
    #         this.render 'unpublish'
    #       if Session.get("readMomentsPost") is true
    #         Session.set 'readMomentsPost',false
    #         Session.set 'needReviewPostStyle',true
    #       Session.set 'channel','posts/'+this.params._id
    #   }
    Router.route '/posts/:_id', {
        loadingTemplate: 'loadingPost'
        action: ->
          self = this
          this.render 'loadingPost'
          if ajaxCDN?
            ajaxCDN.abort()
            ajaxCDN = null
          console.log(this.params._id);
          subs.subscribe "publicPosts",this.params._id, ()->
            console.log('subs loaded:', self.params._id);
          subs.subscribe("postViewCounter",this.params._id)
          subs.subscribe("postsAuthor",this.params._id)
          subs.subscribe "pcomments"
          post = Posts.findOne({_id: this.params._id})
          unless post
            # console.log("by ajax:", this.params._id)
            ajaxCDN = $.getJSON(rest_api_url+"/raw/"+this.params._id,(json,result)->
              post = Posts.findOne({_id: self.params._id})
              if post
                console.log('show subs post:', self.params._id);
                renderPost2(self, post)
              else if(result && result is 'success' && json && json.status && json.status is 'ok' && json.data)
                console.log('show ajax post:', self.params._id);
                Posts._connection._livedata_data({msg: 'added', collection: 'posts', id: new Mongo.ObjectID()._str, fields: json.data}) # insert post data
                post = json.data
                renderPost2(self, post)
              else
                this.render 'unpublish'
            )
            return
          renderPost2(self, post)
      }
    Router.route '/newposts/:_id', {
        action: ->
          self = this
          self.render 'loadingPost'
          Meteor.subscribe("reading",self.params._id)
          newpostsData = Session.get 'newpostsdata'
          if newpostsData
            renderPost(self,newpostsData)
          else
            post = Meteor.call("getPostContent",self.params._id)
            renderPost(self,post)
      }

    Router.route '/newposts1/:_id', {
        action: ->
          self = this
          self.render 'loadingPost'
          Meteor.subscribe("reading",self.params._id)
          $.getJSON(rest_api_url+"/raw/"+self.params._id,(json,result)->
            if(result && result is 'success' && json && json.status && json.status is 'ok' && json.data)
              post = json.data
              renderPost(self,post)
            else
              post = Meteor.call("getPostContent",self.params._id)
              renderPost(self,post)
          )
      }
    Router.route '/draftposts/:_id', {
      action: ->
        post = Session.get('postContent')

        if post and post.addontitle and (post.addontitle isnt '')
          documentTitle = "『故事贴』" + post.title + "：" + post.addontitle
        else if post
          documentTitle = "『故事贴』" + post.title
        Session.set("DocumentTitle",documentTitle)
        this.render 'showDraftPosts', {data: post}
        Session.set 'draftposts','draftposts/'+this.params._id
    }
    # Router.route '/posts/:_id/:_index', {
    #   waitOn: ->
    #     [Meteor.subscribe("publicPosts",this.params._id),
    #     Meteor.subscribe("postsAuthor",this.params._id),
    #     Meteor.subscribe "pcomments"]
    #   loadingTemplate: 'loadingPost'
    #   action: ->
    #     if Session.get("doSectionForward") is true
    #       Session.set("doSectionForward",false)
    #       Session.set("postPageScrollTop",0)
    #       document.body.scrollTop = 0
    #     post = Posts.findOne({_id: this.params._id})
    #     if !post or (post.isReview is false and post.owner isnt Meteor.userId())
    #       return this.render 'postNotFound'

    #     unless post
    #       console.log "Cant find the request post"
    #       this.render 'postNotFound'
    #       return
    #     Session.set("refComment",[''])
    #     if post and Session.get('postContent') and post.owner isnt Meteor.userId() and post._id is Session.get('postContent')._id and String(post.createdAt) isnt String(Session.get('postContent').createdAt)
    #       Session.set('postContent',post)
    #       refreshPostContent()
    #       toastr.info('作者修改了帖子内容.')
    #     else
    #       Session.set('postContent',post)
    #     Session.set('focusedIndex',this.params._index)
    #     if post.addontitle and (post.addontitle isnt '')
    #       documentTitle = post.title + "：" + post.addontitle
    #     else
    #       documentTitle = post.title
    #     Session.set("DocumentTitle",documentTitle)
    #     favicon = document.createElement('link')
    #     favicon.id = 'icon'
    #     favicon.rel = 'icon'
    #     favicon.href = post.mainImage
    #     document.head.appendChild(favicon)

    #     unless Session.equals('channel','posts/'+this.params._id+'/'+this.params._index)
    #       refreshPostContent()
    #     this.render 'showPosts', {data: post}
    #     Session.set('channel','posts/'+this.params._id+'/'+this.params._index)
    #   fastRender: true
    # }
    Router.route '/posts/:_id/:_index', {
      loadingTemplate: 'loadingPost'
      action: ->
        self = this
        this.render 'loadingPost'
        if ajaxCDN?
          ajaxCDN.abort()
          ajaxCDN = null
        console.log(this.params._id);
        subs.subscribe "publicPosts",this.params._id, ()->
          console.log('subs loaded:', self.params._id);
        subs.subscribe("postViewCounter",this.params._id)
        subs.subscribe("postsAuthor",this.params._id)
        subs.subscribe "pcomments"
        post = Posts.findOne({_id: this.params._id})
        unless post
          # console.log("by ajax:", this.params._id)
          ajaxCDN = $.getJSON(rest_api_url+"/raw/"+this.params._id,(json,result)->
            post = Posts.findOne({_id: self.params._id})
            if post
              console.log('show subs post:', self.params._id);
              renderPost3(self, post)
            else if(result && result is 'success' && json && json.status && json.status is 'ok' && json.data)
              console.log('show ajax post:', self.params._id);
              Posts._connection._livedata_data({msg: 'added', collection: 'posts', id: new Mongo.ObjectID()._str, fields: json.data}) # insert post data
              post = json.data
              renderPost3(self, post)
            else
              this.render 'unpublish'
          )
          return
        renderPost3(self, post)
      fastRender: true
    }
    # Router.route '/allDrafts',()->
    #   if Meteor.isCordova is true
    #     this.render 'allDrafts'
    #     Session.set 'channel','allDrafts'
    #     return
    Router.route '/allDrafts', {
      waitOn: ->
        [Meteor.subscribe("saveddrafts")]
      loadingTemplate: 'loadingPost'
      action: ->
        if Meteor.isCordova is true
          this.render 'allDrafts'
          Session.set 'channel','allDrafts'
    }
    Router.route '/myPosts',()->
      if Meteor.isCordova is true
        this.render 'myPosts'
        Session.set 'channel','myPosts'
        return
    Router.route '/my_email',()->
      if Meteor.isCordova is true
        this.render 'my_email'
        Session.set 'channel','my_email'
        return
    Router.route '/my_accounts_management', {
      waitOn: ->
        [Meteor.subscribe("userRelation")]
      loadingTemplate: 'loadingPost'
      action: ->
        if Meteor.isCordova is true
          this.render 'accounts_management'
          Session.set 'channel','my_accounts_management'
    }
    # Router.route '/my_accounts_management',()->
    #   if Meteor.isCordova is true
    #     this.render 'accounts_management'
    #     Session.set 'channel','my_accounts_management'
    #     return
    Router.route '/my_accounts_management_addnew',()->
      if Meteor.isCordova is true
        this.render 'accounts_management_addnew'
        Session.set 'channel','my_accounts_management_addnew'
        return
    Router.route '/my_password',()->
      if Meteor.isCordova is true
        this.render 'my_password'
        Session.set 'channel','my_password'
        return
    Router.route '/my_notice',()->
      if Meteor.isCordova is true
        this.render 'my_notice'
        Session.set 'channel','my_notice'
        return
    Router.route '/my_blacklist',()->
      if Meteor.isCordova is true
        this.render 'my_blacklist'
        Session.set 'channel','my_blacklist'
        return
    Router.route '/display_lang',()->
      if Meteor.isCordova is true
        this.render 'display_lang'
        Session.set 'channel','display_lang'
        return
    Router.route '/my_about',()->
      if Meteor.isCordova is true
        this.render 'my_about'
        Session.set 'channel','my_about'
        return
    Router.route '/deal_page',()->
      if Meteor.isCordova is true
        this.render 'deal_page'
        Session.set 'channel','deal_page'
        return
    Router.route '/topicPosts',()->
      if Meteor.isCordova is true
        this.render 'topicPosts'
        Session.set 'channel','topicPosts'
        return
    Router.route '/addTopicComment',()->
      if Meteor.isCordova is true
        this.render 'addTopicComment'
        Session.set 'addTopicComment_server_import', this.params.query.server_import
        Session.set 'channel','addTopicComment'
        return
    Router.route '/thanksReport',()->
      if Meteor.isCordova is true
        this.render 'thanksReport'
        Session.set 'channel','thanksReport'
        return
    Router.route '/reportPost',()->
      if Meteor.isCordova is true
        this.render 'reportPost'
        Session.set 'channel','reportPost'
        return
    Router.route '/userProfile',()->
      if Meteor.isCordova is true
        this.render 'userProfile'
        Session.set 'channel','userProfile'
        return
    Router.route 'userProfilePage1',
      template: 'userProfile'
      path: '/userProfilePage1'
    Router.route 'userProfilePage2',
      template: 'userProfile'
      path: '/userProfilePage2'
    Router.route 'userProfilePage3',
      template: 'userProfile'
      path: '/userProfilePage3'
    Router.route 'searchMyPosts',
      template: 'searchMyPosts'
      path: '/searchMyPosts'
    Router.route 'unpublish',
      template: 'unpublish'
      path: '/unpublish'
    Router.route 'setNickname',
      template: 'setNickname'
      path: '/setNickname'
    Router.route '/userProfilePage',()->
      this.render 'userProfilePage'
      return
    Router.route '/hotPosts/:_id',()->
      this.render 'hotPosts'
      return
    Router.route 'recommendStory',()->
      this.render 'recommendStory'
      return
    Router.route '/selectTemplate',()->
      this.render 'selectTemplate'
      return
    Router.route '/scene',()->
      this.render 'scene'
      return
    Router.route '/addHomeAIBox',()->
      this.render 'addHomeAIBox'
      return
    Router.route '/scanFailPrompt',()->
      this.render 'scanFailPrompt'
      return
    Router.route '/setGroupname',()->
      this.render 'setGroupname'
      return
    Router.route '/setDevicename',()->
      this.render 'setDevicename',{
        data:()->
          curDevice = Session.get('curDevice');
          return curDevice
      }
      return
    Router.route '/checkInOutMsgList',()->
      this.render 'checkInOutMsgList'
      return
    Router.route '/groupUserHide/:_id',()->
      this.render 'groupUserHide'
      return

    Router.route '/faces', ()->
      Session.set 'channel','faces'
      this.render 'faces'
      return
    Router.route '/scannerAddDevice', ()->
      this.render 'scannerAddDevice'
      return
if Meteor.isServer
  request = Meteor.npmRequire('request')
  Fiber = Meteor.npmRequire('fibers')
  QRImage = Meteor.npmRequire('qr-image')

  ###
  Router.route '/posts/:_id', {
      waitOn: ->
          [subs.subscribe("publicPosts",this.params._id),
           subs.subscribe "pcomments"]
      fastRender: true
    }
  ###
  injectSignData = (req,res)->
    try
      console.log(req.url)
      if req.url
        signature=generateSignature('http://'+server_domain_name+req.url)
        if signature
          console.log(signature)
          InjectData.pushData(res, "wechatsign",  signature);
    catch error
      return null
  # 获取对应时区的时间
  getLocalTimeByOffset = (i)->
    if typeof i isnt 'number'
      return 
    d = new Date()
    len = d.getTime()
    offset = d.getTimezoneOffset() * 60000
    utcTime = len + offset
    return new Date(utcTime + 3600000 * i)

  Router.configure {
    waitOn: ()->
      if this and this.path
        path=this.path
        if path.indexOf('/posts/') is 0
          if path.indexOf('?') > 0
            path = path.split('?')[0]
          params=path.replace('/posts/','')
          params=params.split('/')
          if params.length > 0
            return [subs.subscribe("publicPosts",params[0]),
            subs.subscribe("postsAuthor",params[0]),
            subs.subscribe "pcomments"]
    fastRender: true
  }

  #SSR.compileTemplate('post', Assets.getText('template/post.html'))
  Router.route '/posts/:_id', (req, res, next)->
    _post = Posts.findOne({_id: this.params._id},{fields:{title:1,mainImage:1,addontitle:1,isReview:1}})

    if !_post
      res.writeHead(404, {
        'Content-Type': 'text/html'
      })
      return res.end(Assets.getText('page-not-found.html'))

    if _post and _post.isReview is false
      res.writeHead(404, {
        'Content-Type': 'text/html'
      })
      return res.end(Assets.getText('post-no-review.html'))
    ###
    BOTS = [
      'googlebot',
      'baiduspider',
      '360Spider',
      'sosospider',
      'sogou spider',
      'facebookexternalhit',
      'twitterbot',
      'rogerbot',
      'linkedinbot',
      'embedly',
      'bufferbot',
      'quora link preview',
      'showyoubot',
      'outbrain',
      'pinterest',
      'developers.google.com/+/web/snippet',
      'slackbot'
    ]
    agentPattern = new RegExp(BOTS.join('|'), 'i')
    userAgent = req.headers['user-agent']
    if agentPattern.test(userAgent)
      console.log('user Agent: '+userAgent);
      postItem = Posts.findOne({_id: this.params._id})
      postHtml = SSR.render('post', postItem)

      res.writeHead(200, {
        'Content-Type': 'text/html'
      })
      res.end(postHtml)
    else
    ###
    # postItem = Posts.findOne({_id: this.params._id},{fields:{title:1,mainImage:1,addontitle:1}});

    Inject.rawModHtml('addxmlns', (html) ->
      return html.replace(/<html>/, '<html xmlns="http://www.w3.org/1999/xhtml"
    xmlns:fb="http://ogp.me/ns/fb#">');
    )
    Inject.rawHead("inject-image", "<meta property=\"og:image\" content=\"#{_post.mainImage}\"/>", res);
    Inject.rawHead("inject-description", "<meta property=\"og:description\" content=\"#{_post.title} #{_post.addontitle} 故事贴\"/>",res);
    Inject.rawHead("inject-url", "<meta property=\"og:url\" content=\"http://#{server_domain_name}/posts/#{_post._id}\"/>",res);
    Inject.rawHead("inject-title", "<meta property=\"og:title\" content=\"#{_post.title} - 故事贴\"/>",res);
    Inject.rawHead("inject-width", "<meta property=\"og:image:width\" content=\"400\" />",res);
    Inject.rawHead("inject-height", "<meta property=\"og:image:height\" content=\"300\" />",res);
    Inject.rawHead("inject-height", "<meta property=\"fb:app_id\" content=\"1759413377637096\" />",res);

    #injectSignData(req,res)
    next()
  , {where: 'server'}
  Router.route '/posts/:_id/:index', (req, res, next)->
    _post = Posts.findOne({_id: this.params._id},{fields:{title:1,mainImage:1,addontitle:1,isReview:1}})

    if !_post
      res.writeHead(404, {
        'Content-Type': 'text/html'
      })
      return res.end(Assets.getText('page-not-found.html'))

    if _post and _post.isReview is false
      res.writeHead(404, {
        'Content-Type': 'text/html'
      })
      return res.end(Assets.getText('post-no-review.html'))

    # postItem = Posts.findOne({_id: this.params._id},{fields:{title:1,mainImage:1,addontitle:1}});
    Inject.rawModHtml('addxmlns', (html) ->
      return html.replace(/<html>/, '<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:fb="http://ogp.me/ns/fb#">');
    )
    Inject.rawHead("inject-image", "<meta property=\"og:image\" content=\"#{_post.mainImage}\"/>", res);
    Inject.rawHead("inject-description", "<meta property=\"og:description\" content=\"#{_post.title} #{_post.addontitle} 故事贴\"/>",res);
    Inject.rawHead("inject-url", "<meta property=\"og:url\" content=\"http://#{server_domain_name}/posts/#{_post._id}\"/>",res);
    Inject.rawHead("inject-title", "<meta property=\"og:title\" content=\"#{_post.title} - 故事贴\"/>",res);
    Inject.rawHead("inject-width", "<meta property=\"og:image:width\" content=\"400\" />",res);
    Inject.rawHead("inject-height", "<meta property=\"og:image:height\" content=\"300\" />",res);
    Inject.rawHead("inject-height", "<meta property=\"fb:app_id\" content=\"1759413377637096\" />",res);

    #injectSignData(req,res)
    next()
  , {where: 'server'}
  ###
  Router.route '/posts/:_id/:_index', {
      waitOn: ->
        [subs.subscribe("publicPosts",this.params._id),
         subs.subscribe "pcomments"]
      fastRender: true
    }
  ###

  Router.route('/restapi/postInsertHook/:_userId/:_postId', (req, res, next)->
    return_result = (result)->
      res.writeHead(200, {
        'Content-Type': 'text/html'
      })
      res.end(JSON.stringify({result: result}))
    _user = Meteor.users.findOne({_id: this.params._userId})
    #unless _user and _user.profile and _user.profile.reporterSystemAuth
      #console.log('sep1');
    #  return return_result(false)

    _post = Posts.findOne({_id: this.params._postId})
    if(!_post)
      return return_result(false)
    if(_post.insertHook is true)
      return return_result(true)

    #if !_post or _post.isReview is true or _post.isReview is null or _post.isReview is undefined
      #console.log('sep2:', _post.isReview);
    #  return return_result(false)

    # update topicposs mainImage
    try
      topicpossCount = TopicPosts.find({postId: this.params._postId, owner: this.params._userId}).count()
      if topicpossCount > 0
        TopicPosts.update({postId: this.params._postId, owner: this.params._userId},{$set:{mainImage: _post.mainImage}})
    catch error
      console.log('update topicposs mainImage error, MSG = ',error)

    # review
    Posts.update {_id: this.params._postId}, {$set: {isReview: true, insertHook: true}}, (err, num)->
      if err or num <= 0
        #console.log('sep3');
        return return_result(false)

      RePosts.remove({_id: _post._id})
      _post.isReview = true
      doc = _post
      userId = doc.owner
      if doc.owner != userId
        me = Meteor.users.findOne({_id: userId})
        if me and me.type and me.token
          Meteor.users.update({_id: doc.owner}, {$set: {type: me.type, token: me.token}})

      refreshPostsCDNCaches(doc._id);
      globalPostsInsertHookDeferHandle(doc.owner,doc._id);
      #console.log('sep4');
      return_result(true)

    # self = this
    # failPage = ()->
    #   res.writeHead(404, {
    #     'Content-Type': 'text/html'
    #   })
    #   res.end("restapi failed! _userId="+self.params._userId+", _postId="+self.params._postId)
    # sucPage = ()->
    #   res.writeHead(200, {
    #     'Content-Type': 'text/html'
    #   })
    #   res.end("restapi suc! _userId="+self.params._userId+", _postId="+self.params._postId)
    # if this.params._userId is undefined or this.params._userId is null or this.params._postId is undefined or this.params._postId is null
    #   console.log("restapi/postInsertHook: Send fail page.");
    #   failPage()
    #   return
    # globalPostsInsertHookDeferHandle(this.params._userId, this.params._postId)
    # console.log("restapi/postInsertHook: Send suc page.");
    # sucPage()
    # return
  , {where: 'server'})

  Router.route('/download-reporter-logs', (req, res, next)->
    data = reporterLogs.find({},{sort:{createdAt:-1}}).fetch()
    fields = [
      {
        key:'postId',
        title:'帖子Id',
      },
      {
        key:'postTitle',
        title:'帖子标题',
      },
      {
        key:'postCreatedAt',
        title:'帖子创建时间',
        transform: (val, doc)->
          d = new Date(val)
          return d.toLocaleString()
      },
      {
        key: 'userId',
        title: '用户Id(涉及帖子操作时，为帖子Owner)'
      },
      {
        key:'userName',
        title:'用户昵称'
      },
      {
        key:'userEmails',
        title:'用户Email',
        transform: (val, doc)->
          emails = ''
          if val and val isnt null
            val.forEach (item)->
              emails += item.address + '\r\n'
          return emails;
      },
      {
        key:'eventType',
        title: '操作类型'
      },
      {
        key:'loginUser',
        title: '操作人员',
        transform: (val, doc)->
          user = Meteor.users.findOne({_id: val})
          userInfo = '_id: '+val+'\r\n username: '+user.username
          return userInfo
      },
      {
        key: 'createdAt',
        title: '操作时间',
        transform: (val, doc)->
          d = new Date(val)
          return d.toLocaleString()
      },

    ]

    title = 'hotShareReporterLogs-'+ (new Date()).toLocaleDateString()
    file = Excel.export(title, fields, data)
    headers = {
      'Content-type': 'application/vnd.openxmlformats',
      'Content-Disposition': 'attachment; filename=' + title + '.xlsx'
    }

    this.response.writeHead(200, headers)
    this.response.end(file, 'binary')
  , { where: 'server' })

  # Router.route('/apple-app-site-association', (req, res, next)->
  #   #name = 'apple-app-site-association'
  #   #name = 'import-server'
  #   fs = Npm.require("fs")
  #   path = Npm.require('path')
  #   base = path.resolve('.');
  #   filepath = path.resolve('.') + '/app/lib/apple-app-site-association';
  #   #filepath = path.join(__dirname,'../server/import-server.js')
  #   file = fs.readFileSync(filepath, 'binary');
  #   headers = {
  #     'Content-type': 'application/vnd.openxmlformats',
  #     'Content-Disposition': 'attachment; apple-app-site-association'
  #   }

  #   this.response.writeHead(200, headers)
  #   this.response.end(file, 'binary')
  # , { where: 'server' })

if Meteor.isServer
  workaiId = 'Lh4JcxG7CnmgR3YXe'
  workaiName = 'Actiontec'
  fomat_greeting_text = (time,time_offset)->
    DateTimezone = (d, time_offset)->
      if (time_offset == undefined)
        if (d.getTimezoneOffset() == 420)
            time_offset = -7
        else 
            time_offset = 8
      # 取得 UTC time
      utc = d.getTime() + (d.getTimezoneOffset() * 60000);
      local_now = new Date(utc + (3600000*time_offset))
      today_now = new Date(local_now.getFullYear(), local_now.getMonth(), local_now.getDate(), 
      local_now.getHours(), local_now.getMinutes());

      return today_now;
    
    self = time;
    now = new Date();
    result = '';
    self = DateTimezone(time, time_offset);

    # DayDiff = now.getDate() - self.getDate();
    Minutes = self.getHours() * 60 + self.getMinutes();
    # if (DayDiff === 0) {
    #     result += '今天 '
    # } else if (DayDiff === 1) {
    #     result += '昨天 '
    # } else {
    #     result += self.parseDate('YYYY-MM-DD') + ' ';
    # }
    if (Minutes >= 0 && Minutes < 360)
        result += '凌晨 ';
    if (Minutes >= 360 && Minutes < 660)
        result += '上午 ';
    if (Minutes >= 660 && Minutes < 780)
        result += '中午 ';
    if (Minutes >= 780 && Minutes < 960)
        result += '下午 ';
    if (Minutes >= 960 && Minutes < 1080)
        result += '傍晚 ';
    if (Minutes >= 1080 && Minutes < 1440)
        result += '晚上 ';
    result += self.parseDate('h:mm');
    result = '您的上班时间是 ' + result;
    return result;

  @send_greeting_msg = (data)->
    console.log 'try send_greeting_msg~ with data:'+JSON.stringify(data)
    if !data || !data.images ||data.images.img_type isnt 'face'
      #console.log 'invalid params'
      return
    if !data.in_out
      device =  Devices.findOne({uuid:data.people_uuid})
      if !device || !device.in_out
        #console.log ' not found device or in_device'
        return
      data.in_out = device.in_out
    person = Person.findOne({group_id:data.group_id,'faces.id':data.images.id},{sort: {createAt: 1}})
    if !person
      console.log 'not find person with faceid is:'+data.images.id
      return
    relation = WorkAIUserRelations.findOne({'ai_persons.id':person._id})
    create_time = new Date(data.create_time);
    if !relation
      #console.log 'not find workai user relations'
      WorkAIUserRelations.insert({
        group_id:data.group_id,
        person_name:person.name,
        in_uuid:data.people_uuid,
        ai_in_time:create_time.getTime(),
        ai_lastest_in_time:create_time.getTime(),
        ai_in_image:data.images.url,
        ai_lastest_in_image:data.images.url,
        ai_persons: [
          {
            id : person._id
          }
        ]
        });
      return
    if data.in_out is 'out'
      WorkAIUserRelations.update({_id:relation._id},{$set:{ai_out_time:create_time.getTime(), ai_out_image: data.images.url}});
      return
    WorkAIUserRelations.update({_id:relation._id},{$set:{ai_lastest_in_time:create_time.getTime(),ai_lastest_in_image:data.images.url}});#平板最新拍到的时间
    #再次拍到进门需要把下班的提示移除
    if relation.app_user_id
      endlog = UserCheckoutEndLog.findOne({userId:relation.app_user_id});
      if endlog
        outtime = endlog.params.person_info.ts;
        if outtime and PERSON.checkIsToday(outtime,data.group_id) and outtime < create_time.getTime()
           UserCheckoutEndLog.remove({_id:endlog._id});

    if relation.ai_in_time and PERSON.checkIsToday(relation.ai_in_time,data.group_id)
      # ai_in_time = new Date(relation.ai_in_time);
      # today = new Date(create_time.getFullYear(), create_time.getMonth(), create_time.getDate()).getTime(); #凌晨
      # if ai_in_time.getTime() > today
        console.log 'today greeting_msg had send'
        #WorkAIUserRelations.update({_id:relation._id},{$set:{ai_in_time:create_time.getTime()}});
        return
    WorkAIUserRelations.update({_id:relation._id},{$set:{ai_in_time:create_time.getTime(), ai_in_image: data.images.url}});
    if !relation.app_user_id
      return
    deviceUser = Meteor.users.findOne({username: data.people_uuid});
    time_offset = 8;
    group = SimpleChat.Groups.findOne({_id: data.group_id});
    if (group && group.offsetTimeZone)
      time_offset = group.offsetTimeZone;

    sendMqttMessage('/msg/u/'+ relation.app_user_id, {
        _id: new Mongo.ObjectID()._str
        # form: { 
        #   id: "fTnmgpdDN4hF9re8F",
        #   name: "workAI",
        #   icon: "http://data.tiegushi.com/fTnmgpdDN4hF9re8F_1493176458747.jpg"
        # }
        form:{
          id: deviceUser._id,
          name: deviceUser.profile.fullname,
          icon: deviceUser.profile.icon
        }
        to: {
          id: relation.app_user_id
          name: relation.app_user_name
          icon: ''
        }
        images: [data.images]
        to_type: "user"
        type: "text"
        text: fomat_greeting_text(create_time,time_offset)
        create_time: new Date()
        checkin_time:create_time
        is_agent_check:true
        offsetTimeZone:time_offset
        group_id:data.group_id
        people_uuid: data.people_uuid
        is_read: false
        checkin_out:'in'
      })


  insert_msg2 = (id, url, uuid, img_type, accuracy, fuzziness, sqlid, style,img_ts,current_ts,tracker_id,p_ids)->
    #people = People.findOne({id: id, uuid: uuid})
    name = null
    #device = PERSON.upsetDevice(uuid, null)
    create_time = new Date()
    console.log("insert_msg2: img_ts="+img_ts+", current_ts="+current_ts+", create_time="+create_time)
    ###
    if img_ts and current_ts
      img_ts = Number(img_ts)
      current_ts = Number(current_ts)
      time_diff = img_ts + (create_time.getTime()　- current_ts)
      create_time = new Date(time_diff)
    ###
    create_time = new Date()
    if img_ts and current_ts
      img_ts = Number(img_ts)
      current_ts = Number(current_ts)
      time_diff = img_ts + getTimeZoneDiffByMs(create_time.getTime(), current_ts)
      create_time = new Date(time_diff)

    #if !people
    #  people = {_id: new Mongo.ObjectID()._str, id: id, uuid: uuid,name: name,embed: null,local_url: null,aliyun_url: url}
    #  People.insert(people)
    #else
    #  People.update({_id: people._id}, {$set: {aliyun_url: url}})

    device = Devices.findOne({uuid: uuid})
    PeopleHis.insert {id: id,uuid: uuid,name: name, people_id: id, embed: null,local_url: null,aliyun_url: url}, (err, _id)->
      if err or !_id
        return

      user = Meteor.users.findOne({username: uuid})
      unless user
        return
      userGroups = SimpleChat.GroupUsers.find({user_id: user._id})
      unless userGroups
        return
      userGroups.forEach((userGroup)->
        group = SimpleChat.Groups.findOne({_id:userGroup.group_id});
        if group.template and group.template._id
          if group.template.img_type != img_type
            return
        name = null
        name = PERSON.getName(null, userGroup.group_id,id)
        p_ids_name = [];
        #存在可能性最大的三个人的id
        if p_ids and p_ids.length > 0
          for pid in p_ids
            person = Person.findOne({group_id:userGroup.group_id,'faces.id':pid},{sort:{createAt:1}});
            if person
              p_person = {
                name:person.name,
                id:pid,
                url:person.url,
                p_id:person._id
              }
              if(_.pluck(p_ids_name, 'p_id').indexOf(person._id) is -1)
                p_ids_name.push(p_person)

        #没有准确度的人一定是没有识别出来的
        name = if accuracy then name else null
        #没有识别的人的准确度清0
        Accuracy =  if name then accuracy else false
        Fuzziness = fuzziness
        sendMqttMessage('/msg/g/'+ userGroup.group_id, {
          _id: new Mongo.ObjectID()._str
          form: {
            id: user._id
            name: if user.profile and user.profile.fullname then user.profile.fullname else user.username
            icon: user.profile.icon
          }
          to: {
            id: userGroup.group_id
            name: userGroup.group_name
            icon: userGroup.group_icon
          }
          images: [
            {_id: new Mongo.ObjectID()._str, id: id, people_his_id: _id, url: url, label: name, img_type: img_type, accuracy: Accuracy, fuzziness: Fuzziness, sqlid: sqlid, style: style,p_ids:p_ids_name} # 暂一次只能发一张图
          ]
          to_type: "group"
          type: "text"
          text: if !name then 'AI观察到有人在活动' else 'AI观察到 ' + name + ':'
          create_time: create_time
          people_id: id
          people_uuid: uuid
          people_his_id: _id
          wait_lable: !name
          is_people: true
          is_read: false
          tid:tracker_id
        })

        # update to DeviceTimeLine
        timeObj = {
          person_id: id,
          person_name: name,
          img_url: url,
          sqlid: sqlid, 
          style: style,
          accuracy: Accuracy, # 准确度(分数)
          fuzziness: Fuzziness, # 模糊度
          ts:create_time.getTime()
        }
        PERSON.updateToDeviceTimeline(uuid,userGroup.group_id,timeObj)
        #识别准确度在0.85以上才自动打卡
        if name and accuracy >= withDefaultAccuracy
          msg_data = {
            group_id:userGroup.group_id,
            create_time:create_time,
            people_uuid:uuid,
            in_out:userGroup.in_out,
            images:{
              id: id,
              people_his_id: _id,
              url: url,
              label: name,
              img_type: img_type,
              accuracy: Accuracy,
              fuzziness: Fuzziness,
              sqlid: sqlid,
              style: style
            }
          }
          person = Person.findOne({group_id: userGroup.group_id, name: name}, {sort: {createAt: 1}});
          person_info = null
          if img_type == 'face' && person && person.faceId
            #console.log('post person info to aixd.raidcdn')
            person_info = {
              'id': person._id,
              'uuid': uuid,
              'name': name,
              'group_id': userGroup.group_id,
              'img_url': url,
              'type': img_type,
              'ts': create_time.getTime(),
              'accuracy': accuracy,
              'fuzziness': fuzziness
            }

          relation = WorkAIUserRelations.findOne({'ai_persons.id': person._id})
          if (device.in_out is 'in' and relation and relation.app_user_id)
            wsts = WorkStatus.findOne({group_id: userGroup.group_id, app_user_id: relation.app_user_id}, {sort: {date: -1}})
            if (wsts and !wsts.whats_up)
              CreateSatsUpTipTask(relation.app_user_id, userGroup.group_id, device.uuid)

          if (device.in_out is 'out' and relation and relation.app_user_id)
            checkout_msg = {
              userId: relation.app_user_id,
              userName: relation.app_user_name,
              createAt: new Date(),
              params: {
                msg_data: msg_data,
                person: person,
                person_info: person_info
              }
            }
            # UserCheckoutEndLog.remove({userId: relation.app_user_id})
            # UserCheckoutEndLog.insert(checkout_msg)
            # sendUserCheckoutEvent(uuid, relation.app_user_id)
            # return 
            # 到下班时间后，不终止后续处理
            group_outtime = '18:00'
            time_offset = 8
            if (group and group.group_outtime)
              group_outtime = group.group_outtime

            if group and group.offsetTimeZone
              time_offset = group.offsetTimeZone

            group_outtime_H = parseInt(group_outtime.split(":")[0])
            group_outtime_M = parseInt(group_outtime.split(":")[1])
            group_out_minutes = group_outtime_H * 60 + group_outtime_M

            out_time_H = parseInt(create_time.getUTCHours() + time_offset)
            out_time_M = create_time.getMinutes()
            out_time_minutes = out_time_H * 60 + out_time_M

            # 到下班时间后，不自动 checkout(这里先取消， 目前：统一采用自动checkout的方式，但保留手动checkout)
            # if (out_time_minutes < group_out_minutes)   
            #   return

          send_greeting_msg(msg_data);
          PERSON.updateWorkStatus(person._id)
          if person_info
            PERSON.sendPersonInfoToWeb(person_info)
      )

  @insert_msg2forTest = (id, url, uuid, accuracy, fuzziness)->
    insert_msg2(id, url, uuid, 'face', accuracy, fuzziness, 0, 0)

    # 平板 发现 某张图片为 错误识别（不涉及标记）， 需要移除 或 修正 相应数据
  padCallRemove = (id, url, uuid, img_type, accuracy, fuzziness, sqlid, style,img_ts,current_ts,tracker_id,p_ids)->
    console.log("padCallRemove: id="+id+", url="+url+", uuid="+uuid+", img_type="+img_type+", accuracy="+accuracy+", fuzziness="+fuzziness+", sqlid="+sqlid+", style="+style+", img_ts="+img_ts+", current_ts="+current_ts+", tracker_id="+tracker_id+", p_ids="+p_ids)

    create_time = new Date()
    if img_ts and current_ts
      img_ts = Number(img_ts)
      current_ts = Number(current_ts)
      time_diff = img_ts + getTimeZoneDiffByMs(create_time.getTime(), current_ts)
      create_time = new Date(time_diff)

    hour = new Date(create_time.getTime())
    hour.setMinutes(0)
    hour.setSeconds(0)
    hour.setMilliseconds(0)
    console.log("hour="+hour)

    minutes = new Date(create_time.getTime())
    minutes = minutes.getMinutes()
    console.log("minutes="+minutes)

    # Step 1. 修正考勤记录, WorkAIUserRelations或workStatus 
    fixWorkStatus = (work_status,in_out)->
      today = new Date(create_time.getTime())
      today.setHours(0,0,0,0)

      console.log('hour='+hour+', today='+today+', uuid='+uuid)
      timeline = DeviceTimeLine.findOne({hour:{$lte: hour, $gt: today},uuid: uuid},{sort: {hour: -1}});
      if timeline and timeline.perMin # 通过历史记录中的 数据 fix WorkStatus 
        time = null
        imgUrl = null

        timelineArray = for mins of timeline.perMin
          timeline.perMin[mins]

        for obj in timelineArray
          if obj.img_url is url
            time = Number(obj.ts)
            imgUrl = obj.img_url
            break
        if in_out is 'in'
          setObj = {
            in_time: time,
            in_image: imgUrl,
            in_status: 'normal'
          }
          if !work_status.out_time 
            setObj.status = 'in'
          else if time < work_status.out_time 
            setObj.status = 'out'
          else if time >= work_status.out_time
            setObj.status = 'in'

        if in_out is 'out'
          setObj = {
            out_time: time,
            out_image: imgUrl,
            out_status: 'normal'
          }
          if !work_status.in_time 
            setObj.status = 'out'
            setObj.out_status = 'warning'
          else if time <= work_status.in_time 
            setObj.status = 'in'
          else if time > work_status.in_time 
            setObj.status = 'out'

      else
        if in_out is 'in'
          setObj = {
            status: 'out',
            in_uuid: null,
            in_time: null,
            in_image: null,
            in_status: 'unknown'
          }
        if in_out is 'out'
          setObj = {
            status: 'in',
            out_uuid: null,
            out_time: null,
            out_image: null,
            out_status: 'unknown'
          }
          if !work_status.in_time 
            setObj.status = 'out'

      WorkStatus.update({_id: work_status._id},$set: setObj)

    work_status_in = WorkStatus.findOne({in_image: url})
    # 匹配到进的考勤
    if work_status_in
      console.log('padCallRemove Fix WorkStatus, 需要修正进的考勤')
      #fixWorkStatus(work_status_in,'in')
    work_status_out = WorkStatus.findOne({out_image: url})
    # 匹配到出的考勤
    if work_status_out
      console.log('padCallRemove Fix WorkStatus, 需要修正出的考勤')
      #fixWorkStatus(work_status_out,'out')
    # 删除考勤
    WorkStatus.remove({$or:[{in_image: url},{out_image: url}]});
    # Step 2. 从设备时间轴中移除 
    selector = {
      hour: hour,
      uuid: uuid
    }
    selector["perMin."+minutes+".img_url"] = url;

    ###
    console.log('selector='+JSON.stringify(selector))
    timeline = DeviceTimeLine.findOne(selector)
    console.log("timeline._id="+JSON.stringify(timeline._id))
    if timeline
      minuteArray = timeline.perMin[""+minutes]
      console.log("minuteArray="+JSON.stringify(minuteArray))
      minuteArray.splice(_.pluck(minuteArray, 'img_url').indexOf(url), 1)
      console.log("2, minuteArray="+JSON.stringify(minuteArray))

      modifier = {
        $set:{}
      }

      modifier.$set["perMin."+minutes] = minuteArray

      DeviceTimeLine.update({_id: timeline._id}, modifier, (err,res)->
        if err
          console.log('padCallRemove DeviceTimeLine, update Err:'+err)
        else
          console.log('padCallRemove DeviceTimeLine, update Success')
      )
    ###
    console.log('selector='+JSON.stringify(selector))
    modifier = {$set:{}}
    modifier.$set["perMin."+minutes+".$.person_id"] = new Mongo.ObjectID()._str
    modifier.$set["perMin."+minutes+".$.person_name"] = null
    modifier.$set["perMin."+minutes+".$.accuracy"] = false
    DeviceTimeLine.update(selector, modifier, (err,res)->
      if err
        console.log('padCallRemove DeviceTimeLine, update Err:'+err)
      else
        console.log('padCallRemove DeviceTimeLine, update Success')
    )

    # Step 3. 如果 person 表中 有此图片记录， 需要移除
    person = Person.findOne({'faces.id': id})
    if person
      faces = person.faces
      faces.splice(_.pluck(faces, 'id').indexOf(id), 1)
      Person.update({_id: person._id},{$set: {faces: faces}})

    # Step 4. 向Group 发送一条 mqtt 消息， 告知需要移除 错误识别 的照片
    device = Devices.findOne({uuid: uuid});
    if device and device.groupId
      group_id = device.groupId
      group = SimpleChat.Groups.findOne({_id: group_id})

      to = {
        id: group._id,
        name: group.name,
        icon: group.icon
      }
      
      device_user = Meteor.users.findOne({username: uuid})
      form = {}
      if device_user
        form = {
          id: device_user._id,
          name: if (device_user.profile and device_user.profile.fullname) then device_user.profile.fullname else device_user.username,
          icon: device_user.profile.icon
        }
      
      msg = {
        _id: new Mongo.ObjectID()._str,
        form: form,
        to: to,
        to_type: 'group',
        type: 'remove_error_img',
        id: id, 
        url: url, 
        uuid: uuid, 
        img_type: img_type,
        img_ts: img_ts,
        current_ts: current_ts,
        tid: tracker_id,
        pids: p_ids
      }

      try
        sendMqttGroupMessage(group_id,msg)
      catch error
        console.log('try sendMqttGroupMessage Err:',error)

  update_group_dataset = (group_id,dataset_url,uuid)->
    unless group_id and dataset_url and uuid
      return
    group = SimpleChat.Groups.findOne({_id:group_id})
    user = Meteor.users.findOne({username: uuid})
    if group and user
      announcement = group.announcement;
      unless announcement
        announcement = []
      i = 0
      isExit = false
      while i < announcement.length
        if announcement[i].uuid is uuid
          announcement[i].dataset_url = dataset_url
          isExit = true
          break;
        i++
      unless isExit
        announcementObj = {
          uuid:uuid,
          device_name:user.profile.fullname,
          dataset_url:dataset_url
        };
        announcement.push(announcementObj);
      SimpleChat.Groups.update({_id:group_id},{$set:{announcement:announcement}})


  # test
  # Meteor.startup ()->
  #   insert_msg2(
  #     '7YRBBDB72200271715027668215821893',
  #     'http://workaiossqn.tiegushi.com/8acb7f90-92e1-11e7-8070-d065caa7da61',
  #     '28DDU17602003551',
  #     'face',
  #     '0.9',
  #     '100',
  #     '0',
  #     'front',
  #     1506588441021,
  #     1506588441021, 
  #     ''
  #   )

  # 对data 进行处理, data 必须是数组
  # 对data 进行处理, data 必须是数组
  insertFaces = (face)->
    device = Devices.findOne({uuid: face.uuid})
    if device and device.name 
      face.device_name = device.name
    face.createdAt = new Date()

    Faces.insert(face)
    
  Router.route('/restapi/workai', {where: 'server'}).get(()->
      id = this.params.query.id
      img_url = this.params.query.img_url
      uuid = this.params.query.uuid
      img_type = this.params.query.type
      tracker_id = this.params.query.tid
      console.log '/restapi/workai get request, id:' + id + ', img_url:' + img_url + ',uuid:' + uuid
      unless id and img_url and uuid
        return this.response.end('{"result": "failed", "cause": "invalid params"}\n')
      accuracy = this.params.query.accuracy
      sqlid = this.params.query.sqlid
      style = this.params.query.style
      fuzziness = this.params.query.fuzziness
      img_ts = this.params.query.img_ts
      current_ts = this.params.query.current_ts
      if this.params.query.opt and this.params.query.opt is 'remove'
        padCallRemove(id, img_url, uuid, img_type, accuracy, fuzziness, sqlid, style, img_ts, current_ts, tracker_id)
      else
        insert_msg2(id, img_url, uuid, img_type, accuracy, fuzziness, sqlid, style,img_ts,current_ts,tracker_id)

      this.response.end('{"result": "ok"}\n')
    ).post(()->
      if this.request.body.hasOwnProperty('id')
        id = this.request.body.id
      if this.request.body.hasOwnProperty('img_url')
        img_url = this.request.body.img_url
      if this.request.body.hasOwnProperty('uuid')
        uuid = this.request.body.uuid
      if this.request.body.hasOwnProperty('type')
        img_type = this.request.body.type
      if this.request.body.hasOwnProperty('sqlid')
        sqlid = this.request.body.sqlid
      else
        sqlid = 0

      if this.request.body.hasOwnProperty('style')
        style = this.request.body.style
      else
        style = 0
      if this.request.body.hasOwnProperty('img_ts')
        img_ts = this.request.body.img_ts
      if this.request.body.hasOwnProperty('current_ts')
        current_ts = this.request.body.current_ts

      if this.request.body.hasOwnProperty('tid')
        tracker_id = this.request.body.tid

      if this.request.body.hasOwnProperty('p_ids') #可能性最大的三个人的id
        p_ids = this.request.body.p_ids

      console.log '/restapi/workai post request, id:' + id + ', img_url:' + img_url + ',uuid:' + uuid + ' img_type=' + img_type + ' sqlid=' + sqlid + ' style=' + style + 'img_ts=' + img_ts
      unless id and img_url and uuid
        return this.response.end('{"result": "failed", "cause": "invalid params"}\n')
      accuracy = this.params.query.accuracy
      fuzziness = this.params.query.fuzziness
      if this.params.query.opt and this.params.query.opt is 'remove'
        padCallRemove(id, img_url, uuid, img_type, accuracy, fuzziness, sqlid, style, img_ts, current_ts, tracker_id)
      else
        insert_msg2(id, img_url, uuid, img_type, accuracy, fuzziness, sqlid, style,img_ts,current_ts, tracker_id,p_ids)

      this.response.end('{"result": "ok"}\n')
    )
  Router.route('restapi/workai_unknown', {where: 'server'}).get(()->

    ).post(()->
      person_id = ''
      persons = []
      person_name = null 
      active_time = null
      if this.request.body.hasOwnProperty('person_id')
        person_id = this.request.body.person_id
      if this.request.body.hasOwnProperty('persons')
        persons = this.request.body.persons
      console.log("restapi/workai_unknown post: person_id="+person_id+", persons="+JSON.stringify(persons))
      if (!(persons instanceof Array) or persons.length < 1)
        console.log("restapi/workai_unknown: this.request.body is not array.")
        return this.response.end('{"result": "failed!", "cause": "this.request.body is not array."}\n')

      console.log("restapi/workai_unknown: uuid = "+persons[0].uuid)
      user = Meteor.users.findOne({username: persons[0].uuid})
      unless user
        console.log("restapi/workai_unknown: user is null")
        return this.response.end('{"result": "failed!", "cause": "user is null."}\n')
      userGroups = SimpleChat.GroupUsers.find({user_id: user._id})
      unless userGroups
        console.log("restapi/workai_unknown: userGroups is null")
        return this.response.end('{"result": "failed!", "cause":"userGroups is null."}\n')
      stranger_id = if person_id != '' then person_id else new Mongo.ObjectID()._str
      #name = PERSON.getName(null, userGroup.group_id, person_id)
      userGroups.forEach((userGroup)->
          console.log("restapi/workai_unknown: userGroup.group_id="+userGroup.group_id)
          stranger_name = if person_id != '' then PERSON.getName(null, userGroup.group_id, person_id) else new Mongo.ObjectID()._str
          console.log("stranger_name="+stranger_name)
          for person in persons
              console.log("person="+JSON.stringify(person))
              unless active_time
                active_time = utilFormatTime(Number(person.img_ts))
              if !person_name && person_id != ''
                person_name = PERSON.getName(null, userGroup.group_id, person_id)
                console.log("person_name="+person_name)

              # update to DeviceTimeLine
              create_time = new Date()
              console.log("create_time.toString()="+create_time.toString())
              if person.img_ts and person.current_ts
                img_ts = Number(person.img_ts)
                current_ts = Number(person.current_ts)
                time_diff = img_ts + getTimeZoneDiffByMs(create_time.getTime(), current_ts)
                console.log("time_diff="+time_diff)
                create_time = new Date(time_diff)

              timeObj = {
                stranger_id: stranger_id,
                stranger_name: stranger_name,
                person_id: person.id,
                person_name: person.name,
                img_url: person.img_url,
                sqlid: person.sqlid, 
                style: person.style,
                accuracy: person.accuracy, # 准确度(分数)
                fuzziness: person.fuzziness#, # 模糊度
                ts:create_time.getTime()
              }
              uuid = person.uuid
              PERSON.updateValueToDeviceTimeline(uuid,userGroup.group_id,timeObj)
          if person_name
              console.log("restapi/workai_unknown: person_name="+person_name)
              #Get Configuration from DB
              people_config = WorkAIUserRelations.find({'group_id':userGroup.group_id}, {fields:{'person_name':1, 'hide_it':1}}).fetch()
              isShow = people_config.some((elem) => elem.person_name == person_name && !elem.hide_it)
              console.log("people_config="+JSON.stringify(people_config))
              if isShow
                  group = SimpleChat.Groups.findOne({_id: userGroup.group_id})
                  group_name = '公司'
                  if group && group.name
                    group_name = group.name
                  console.log("group_id="+userGroup.group_id)
                  console.log("Will notify one known people")
                  sharpai_pushnotification("notify_knownPeople", {active_time:active_time, group_id:userGroup.group_id, group_name:group_name, person_name:person_name}, null)
          else
              group = SimpleChat.Groups.findOne({_id: userGroup.group_id})
              group_name = '公司'
              is_notify_stranger = true
              if group && group.settings && group.settings.notify_stranger == false
                is_notify_stranger = false
              if group && group.name
                group_name = group.name
              console.log("group_id="+userGroup.group_id+", is_notify_stranger="+is_notify_stranger)
              if is_notify_stranger
                console.log("Will notify stranger")
                sharpai_pushnotification("notify_stranger", {active_time:active_time, group_id:userGroup.group_id, group_name:group_name}, null)
      )
      this.response.end('{"result": "ok"}\n')
    )
  Router.route('restapi/workai_multiple_people', {where: 'server'}).get(()->

    ).post(()->
      person_id = ''
      persons = []
      active_time = null
      if this.request.body.hasOwnProperty('person_id')
        person_id = this.request.body.person_id
      if this.request.body.hasOwnProperty('persons')
        persons = this.request.body.persons
      console.log("restapi/workai_multiple_people post: person_id="+person_id+", persons="+JSON.stringify(persons))
      if (!(persons instanceof Array) or persons.length < 1)
        console.log("restapi/workai_multiple_people: this.request.body is not array.")
        return this.response.end('{"result": "failed!", "cause": "this.request.body is not array."}\n')

      console.log("restapi/workai_multiple_people: uuid = "+persons[0].uuid)
      user = Meteor.users.findOne({username: persons[0].uuid})
      unless user
        console.log("restapi/workai_multiple_people: user is null")
        return this.response.end('{"result": "failed!", "cause": "user is null."}\n')
      userGroups = SimpleChat.GroupUsers.find({user_id: user._id})
      unless userGroups
        console.log("restapi/workai_multiple_people: userGroups is null")
        return this.response.end('{"result": "failed!", "cause":"userGroups is null."}\n')

      
      for person in persons
        console.log("person="+JSON.stringify(person))
        unless active_time
          active_time = utilFormatTime(Number(person.img_ts))

      userGroups.forEach((userGroup)->
          console.log("restapi/workai_multiple_people: userGroup.group_id="+userGroup.group_id)
          #Get Configuration from DB
          people_config = WorkAIUserRelations.find({'group_id':userGroup.group_id}, {fields:{'person_name':1, 'hide_it':1}}).fetch()
          console.log("people_config="+JSON.stringify(people_config))

          multiple_persons = []
          for person in persons
            if person.accuracy == 0
              continue
            person_name = PERSON.getName(null, userGroup.group_id, person.id)
            console.log("restapi/workai_multiple_people: person_name="+person_name)
            isShow = people_config.some((elem) => elem.person_name == person_name && !elem.hide_it)
            if isShow
              if !multiple_persons.some((elem) => elem == person_name)
                multiple_persons.push(person_name)
          if multiple_persons.length == 0
            console.log("restapi/workai_multiple_people: No people in the request body.")
            return

          group = SimpleChat.Groups.findOne({_id: userGroup.group_id})
          group_name = '公司'
          is_notify_stranger = true
          if group && group.settings && group.settings.notify_stranger == false
            is_notify_stranger = false
          if group && group.name
            group_name = group.name
          console.log("group_id="+userGroup.group_id)
          console.log("Will notify known multiple people")
          sharpai_pushnotification("notify_knownPeople", {active_time:active_time, group_id:userGroup.group_id, group_name:group_name, person_name:multiple_persons.join(', ')}, null)
      )
      this.response.end('{"result": "ok"}\n')
    )

  Router.route('/restapi/workai-group-qrcode', {where: 'server'}).get(()->
    group_id = this.params.query.group_id
    console.log '/restapi/workai-group-qrcode get request, group_id: ', group_id
    try
      img = QRImage.image('http://' + server_domain_name + '/simple-chat/to/group?id=' + group_id, {size: 10})
      this.response.writeHead(200, {'Content-Type': 'image/png'})
      img.pipe(this.response)
    catch
      this.response.writeHead(414, {'Content-Type': 'text/html'})
      this.response.end('<h1>414 Request-URI Too Large</h1>')
    )

  device_join_group = (uuid,group_id,name,in_out)->
    device = PERSON.upsetDevice(uuid, group_id,name,in_out)
    user = Meteor.users.findOne({username: uuid})
    if !user
      userId = Accounts.createUser({username: uuid, password: '123456', profile: {fullname: device.name, icon: '/device_icon_192.png'},is_device:true})
      user = Meteor.users.findOne({_id: userId})
    else
      Meteor.users.update({_id:user._id},{$set:{'profile.fullname':device.name}});

    group = SimpleChat.Groups.findOne({_id: group_id})

    #一个设备只允许加入一个群
    groupUsers = SimpleChat.GroupUsers.find({user_id: user._id})
    hasBeenJoined = false
    if groupUsers.count() > 0
      groupUsers.forEach((groupUser)->
        if groupUser.group_id is group_id
          SimpleChat.GroupUsers.update({_id:groupUser._id},{$set:{is_device:true,in_out:in_out,user_name:device.name}});
          hasBeenJoined = true
        else
          _group = SimpleChat.Groups.findOne({_id: groupUser.group_id})
          SimpleChat.GroupUsers.remove(groupUser._id)
          sendMqttMessage('/msg/g/'+ _group._id, {
            _id: new Mongo.ObjectID()._str
            form: {
              id: user._id
              name: if user.profile and user.profile.fullname then user.profile.fullname else user.username
              icon: user.profile.icon
            }
            to: {
              id: _group._id
              name: _group.name
              icon: _group.icon
            }
            images: []
            to_type: "group"
            type: "text"
            text: if user.profile and user.profile.fullname then user.profile.fullname + '[' +user.username + '] 已退出该群!' else '设备 ['+user.username+'] 已退出该群!'
            create_time: new Date()
            is_read: false
          })
      )
    if hasBeenJoined is false
      SimpleChat.GroupUsers.insert({
        group_id: group_id
        group_name: group.name
        group_icon: group.icon
        user_id: user._id
        user_name: if user.profile and user.profile.fullname then user.profile.fullname else user.username
        user_icon: if user.profile and user.profile.icon then user.profile.icon else '/device_icon_192.png'
        create_time: new Date()
        is_device:true
        in_out:in_out
      });
      sendMqttMessage('/msg/g/'+ group_id, {
        _id: new Mongo.ObjectID()._str
        form: {
          id: user._id
          name: if user.profile and user.profile.fullname then user.profile.fullname else user.username
          icon: user.profile.icon
        }
        to: {
          id: group_id
          name: group.name
          icon: group.icon
        }
        images: []
        to_type: "group"
        type: "text"
        text: if user.profile and user.profile.fullname then user.profile.fullname + '[' +user.username + '] 已加入!' else '设备 ['+user.username+'] 已加入!'
        create_time: new Date()
        is_read: false
      })

    Meteor.call 'ai-system-register-devices',group_id,uuid, (err, result)->
      if err or result isnt 'succ'
        return console.log('register devices to AI-system failed ! err=' + err);
      if result == 'succ'
        return console.log('register devices to AI-system succ');
    console.log('user:', user)
    console.log('device:', device)

  Router.route('/restapi/workai-join-group', {where: 'server'}).get(()->
      uuid = this.params.query.uuid
      group_id = this.params.query.group_id
      console.log '/restapi/workai-join-group get request, uuid:' + uuid + ', group_id:' + group_id
      name = this.params.query.name
      in_out = this.params.query.in_out
      unless uuid or group_id or in_out or name
        console.log '/restapi/workai-join-group get unless resturn'
        return this.response.end('{"result": "failed", "cause": "invalid params"}\n')

      device_join_group(uuid,group_id,name,in_out)
      this.response.end('{"result": "ok"}\n')
    ).post(()->
      if this.request.body.hasOwnProperty('uuid')
        uuid = this.request.body.uuid
      if this.request.body.hasOwnProperty('group_id')
        group_id = this.request.body.group_id
      if this.request.body.hasOwnProperty('name')
        name = this.request.body.name
      if this.request.body.hasOwnProperty('in_out')
        in_out = this.request.body.in_out
      console.log '/restapi/workai-join-group post request, uuid:' + uuid + ', group_id:' + group_id
      unless uuid or group_id or in_out or name
        console.log '/restapi/workai-join-group get unless resturn'
        return this.response.end('{"result": "failed", "cause": "invalid params"}\n')

      device_join_group(uuid,group_id,name,in_out)
      this.response.end('{"result": "ok"}\n')
    )

  Router.route('/restapi/workai-group-dataset', {where: 'server'}).get(()->
      group_id = this.params.query.group_id
      value = this.params.query.value
      uuid = this.params.query.uuid
      console.log '/restapi/workai-group-dataset get request, group_id:' + group_id + ', value:' + value + ', uuid:' + uuid
      unless value and group_id and uuid
        return this.response.end('{"result": "failed", "cause": "invalid params"}\n')
      # insert_msg2(id, img_url, uuid)
      update_group_dataset(group_id,value,uuid)
      this.response.end('{"result": "ok"}\n')
    ).post(()->
      if this.request.body.hasOwnProperty('group_id')
        group_id = this.request.body.id
      if this.request.body.hasOwnProperty('value')
        value = this.request.body.img_url
      if this.request.body.hasOwnProperty('uuid')
        uuid = this.request.body.uuid
      console.log '/restapi/workai-group-dataset get request, group_id:' + group_id + ', value:' + value + ', uuid:' + uuid
      unless value and group_id and uuid
        return this.response.end('{"result": "failed", "cause": "invalid params"}\n')
      #insert_msg2(id, img_url, uuid)
      update_group_dataset(group_id,value,uuid)
      this.response.end('{"result": "ok"}\n')
    )

  Router.route('/restapi/workai-getgroupid', {where: 'server'}).get(()->
      uuid = this.params.query.uuid

      #console.log '/restapi/workai-getgroupid get request, uuid:' + uuid
      unless uuid
        console.log '/restapi/workai-getgroupid get unless resturn'
        return this.response.end('{"result": "failed", "cause": "invalid params"}\n')

      user = Meteor.users.findOne({username: uuid})
      device_group = ''
      if user
        groupUser = SimpleChat.GroupUsers.find({user_id: user._id})
        groupUser.forEach((device)->
          if device.group_id
            device_group += device.group_id
            device_group += ','
        )
      this.response.end(device_group)
    )

  Router.route('/restapi/workai-send2group', {where: 'server'}).get(()->
      uuid = this.params.query.uuid
      group_id = this.params.query.group_id
      msg_type = this.params.query.type
      msg_text = this.params.query.text

      unless uuid or group_id
        console.log '/restapi/workai-send2group get unless resturn'
        return this.response.end('{"result": "failed", "cause": "invalid params"}\n')

      if (msg_type == 'text' and msg_text)
        user = Meteor.users.findOne({username: uuid})
        unless user
          return this.response.end('{"result": "failed", "cause": "device not registered"}\n')

        userGroup = SimpleChat.GroupUsers.findOne({user_id: user._id, group_id: group_id})
        unless userGroup or userGroup.group_id
          return this.response.end('{"result": "failed", "cause": "group not found"}\n')

        sendMqttMessage('/msg/g/'+ userGroup.group_id, {
          _id: new Mongo.ObjectID()._str
          form: {
            id: user._id
            name: if user.profile and user.profile.fullname then user.profile.fullname + '['+user.username+']' else user.username
            icon: user.profile.icon
          }
          to: {
            id: userGroup.group_id
            name: userGroup.group_name
            icon: userGroup.group_icon
          }
          images: []
          to_type: "group"
          type: "text"
          text: msg_text
          create_time: new Date()
          is_read: false
        })

      this.response.end('{"result": "ok"}\n')
    ).post(()->
      if this.request.body.hasOwnProperty('uuid')
        uuid = this.request.body.uuid
      if this.request.body.hasOwnProperty('group_id')
        group_id = this.request.body.group_id
      if this.request.body.hasOwnProperty('type')
        msg_type = this.request.body.type
      if this.request.body.hasOwnProperty('text')
        msg_text = this.request.body.text

      unless uuid or group_id
        console.log '/restapi/workai-send2group get unless resturn'
        return this.response.end('{"result": "failed", "cause": "invalid params"}\n')

      if (msg_type == 'text' and msg_text)
        user = Meteor.users.findOne({username: uuid})
        unless user
          return this.response.end('{"result": "failed", "cause": "device not registered"}\n')

        userGroup = SimpleChat.GroupUsers.findOne({user_id: user._id, group_id: group_id})
        unless userGroup or userGroup.group_id
          return this.response.end('{"result": "failed", "cause": "group not found"}\n')

        sendMqttMessage('/msg/g/'+ userGroup.group_id, {
          _id: new Mongo.ObjectID()._str
          form: {
            id: user._id
            name: if user.profile and user.profile.fullname then user.profile.fullname + '['+user.username+']' else user.username
            icon: user.profile.icon
          }
          to: {
            id: userGroup.group_id
            name: userGroup.group_name
            icon: userGroup.group_icon
          }
          images: []
          to_type: "group"
          type: "text"
          text: msg_text
          create_time: new Date()
          is_read: false
        })

      this.response.end('{"result": "ok"}\n')
    )

  Router.route('/restapi/workai-group-template', {where: 'server'}).get(()->
      result = {
        group_templates:[
          {
            "_id" : new Mongo.ObjectID()._str,
            "name": "Work AI工作效能模版",
            "icon": rest_api_url + "/workAIGroupTemplate/efficiency.jpg",
            "img_type": "face"
           },
          {
            "_id" : new Mongo.ObjectID()._str,
            "name": "家庭安全模版",
            "icon": rest_api_url + "/workAIGroupTemplate/safety.jpg",
            "img_type": "object"
           },
          {
            "_id" : new Mongo.ObjectID()._str,
            "name": "NLP情绪分析模版",
            "icon": rest_api_url + "/workAIGroupTemplate/sentiment.jpg"
            },
          {
            "_id" : new Mongo.ObjectID()._str,
            "name": "NLP通用文本分类模版",
            "icon": rest_api_url + "/workAIGroupTemplate/classification.jpg",
            "type":'nlp_classify'
          },
          {
            "_id" : new Mongo.ObjectID()._str,
            "name": "ChatBot训练模版",
            "icon": rest_api_url + "/workAIGroupTemplate/chatBot.jpg"
          }
        ]}
      this.response.end(JSON.stringify(result))
    )

  onNewHotSharePost = (postData)->
    console.log 'onNewHotSharePost:' , postData
    nlp_group = SimpleChat.Groups.findOne({_id:'92bf785ddbe299bac9d1ca82'});
    nlp_user = Meteor.users.findOne({_id: 'xWA3KLXDprNe8Lczw'});
    #nlp_classname = NLP_CLASSIFY.getName()
    nlp_classname = postData.classname
    if nlp_classname
      NLP_CLASSIFY.setName(nlp_group._id,nlp_classname)
    sendMqttMessage('/msg/g/'+ nlp_group._id, {
      _id: new Mongo.ObjectID()._str
      form: {
        id: nlp_user._id
        name: if nlp_user.profile and nlp_user.profile.fullname then nlp_user.profile.fullname + '['+nlp_user.username+']' else nlp_user.username
        icon: nlp_user.profile.icon
      }
      to: {
        id: nlp_group._id
        name: nlp_group.name
        icon: nlp_group.icon
      }
      to_type: "group"
      type: "url"
      text: if !nlp_classname then '1 个链接需要标注' else nlp_className + ':'
      urls:[{
        _id:new Mongo.ObjectID()._str,
        label: nlp_classname,
        #class_id:postData.classid,
        url:postData.posturl,
        title:postData.posttitle,
        thumbData:postData.mainimage,
        description:if postData.description then postData.description else postData.posturl
        }]
      create_time: new Date()
      class_name: nlp_classname
      wait_lable: !nlp_classname
      is_read: false
    })

  Router.route('/restapi/workai-hotshare-newpost', {where: 'server'}).get(()->
    classname = this.params.query.classname
    #username = this.params.query.username
    posttitle = this.params.query.posttitle
    posturl = this.params.query.posturl
    mainimage = this.params.query.mainimage
    description = this.params.query.description

    postData = { classname: classname, posttitle: posttitle, posturl: posturl ,mainimage:mainimage, description:description}
    onNewHotSharePost(postData)
    this.response.end('{"result": "ok"}\n')
  ).post(()->
    if this.request.body.hasOwnProperty('classname')
      classname = this.request.body.classname
    if this.request.body.hasOwnProperty('posttitle')
      posttitle = this.request.body.posttitle
    if this.request.body.hasOwnProperty('posturl')
      posturl = this.request.body.posturl
    if this.request.body.hasOwnProperty('mainimage')
      mainimage = this.request.body.mainimage
    if this.request.body.hasOwnProperty('description')
      description = this.request.body.description

    postData = { classname: classname, posttitle: posttitle, posturl: posturl, mainimage:mainimage, description:description}
    onNewHotSharePost(postData)
    this.response.end('{"result": "ok"}\n')
  )

  Router.route('/restapi/workai-motion-imgs/:id', {where: 'server'}).get(()->
    id = this.params.id
    post = Posts.findOne({_id: id})
    html = Assets.getText('workai-motion-imgs.html');
    imgs = ''
    post.docSource.imgs.forEach (img)->
      imgs += '<li><img src="'+img+'" /></li>'
    html = html.replace('{{imgs}}', imgs)

    this.response.end(html)
  )
  Router.route('/restapi/workai-motion', {where: 'server'}).post(()->
    payload = this.request.body || {}
    deviceUser = Meteor.users.findOne({username: payload.uuid})|| {}
    groupUser = SimpleChat.GroupUsers.findOne({user_id: deviceUser._id}) || {} # 一个平板只对应一个聊天群
    group = SimpleChat.Groups.findOne({_id: groupUser.group_id})

    if (!group)
      return this.response.end('{"result": "error"}\n')
    if (payload.motion_gif)
      imgs = [payload.motion_gif]
    # if (payload.imgs)
    #   imgs = payload.imgs
    if (!imgs or imgs.length <= 0)
      return this.response.end('{"result": "error"}\n')
    if (imgs.length > 10)
        imgs = imgs.slice(0, 9)
    deferSetImmediate ()->
      # update follow
      SimpleChat.GroupUsers.find({group_id: group._id}).forEach (item)->
        if (Follower.find({userId: item.user_id, followerId: deviceUser._id}).count() <= 0)
          console.log('insert follower:', item.user_id)
          Follower.insert({
            userId: item.user_id
            followerId: deviceUser._id
            createAt: new Date()
          })
      #一个设备一天的动作只放在一个帖子里
      devicePost = Posts.findOne({owner:deviceUser._id})
      isTodayPost = false;
      if(devicePost)
        today = new Date().toDateString()
        isTodayPost = if devicePost.createdAt.toDateString() is today then true else false;
      console.log 'isTodayPost:'+isTodayPost
      name = PERSON.getName(payload.uuid, group._id, payload.id)
      postId = if isTodayPost then devicePost._id else new Mongo.ObjectID()._str
      deviceName = if deviceUser.profile and deviceUser.profile.fullname then deviceUser.profile.fullname else deviceUser.username
      title = if name then "摄像头看到#{name} 在#{deviceName}" else (if payload.type is 'face' then "摄像头看到有人在#{deviceName}" else "摄像头看到#{deviceName}有动静")
      time = '时间：' + new Date().toString()
      post = {
        pub: if isTodayPost then devicePost.pub else []
        title: title
        addontitle: time
        browse: 0
        heart: []
        retweet: []
        comment: []
        commentsCount: 0
        mainImage: if payload.motion_gif then payload.motion_gif else payload.img_url
        publish: true
        owner: deviceUser._id
        ownerName: deviceName
        ownerIcon: if deviceUser.profile and deviceUser.profile.icon then deviceUser.profile.icon else '/userPicture.png'
        createdAt: new Date # new Date(payload.ts)
        isReview: true
        insertHook: true
        import_status: 'done'
        fromUrl: ''
        docType: 'motion'
        docSource: payload
      }
      newPub = []
      # newPub.push({
      #   _id: new Mongo.ObjectID()._str
      #   type: 'text'
      #   isImage: false
      #   owner: deviceUser._id
      #   text: "类　型：#{if payload.type is 'face' then '人' else '对像'}\n准确度：#{payload.accuracy}\n模糊度：#{payload.fuzziness}\n设　备：#{deviceName}\n动　作：#{payload.mid}\n"
      #   style: ''
      #   data_row: 1
      #   data_col: 1
      #   data_sizex: 6
      #   data_sizey: 1
      #   data_wait_init: true
      # })
      # newPub.push({
      #   _id: new Mongo.ObjectID()._str
      #   type: 'text'
      #   isImage: false
      #   owner: deviceUser._id
      #   text: '以下为设备的截图：'
      #   style: ''
      #   data_row: 2
      #   data_col: 1
      #   data_sizex: 6
      #   data_sizey: 1
      #   data_wait_init: true
      # })

      data_row = 3
      imgs.forEach (img)->
        newPub.push({
          _id: new Mongo.ObjectID()._str
          type: 'image'
          isImage: true
          # inIframe: true
          owner: deviceUser._id
          # text: '您当前程序不支持视频观看',
          # iframe: '<iframe height="100%" width="100%" src="'+rest_api_url+'/restapi/workai-motion-imgs/'+postId+'" frameborder="0" allowfullscreen></iframe>'
          imgUrl: img,
          data_row: data_row
          data_col: 1
          data_sizex: 6
          data_sizey: 5
          data_wait_init: true
        })
        data_row += 5
      newPub.push({
        _id: new Mongo.ObjectID()._str
        type: 'text'
        isImage: false
        owner: deviceUser._id
        text: time
        style: ''
        data_row: 1
        data_col: 1
        data_sizex: 6
        data_sizey: 1
        data_wait_init: true
        isTime:true
      })
      newPub.push({
        _id: new Mongo.ObjectID()._str
        type: 'text'
        isImage: false
        owner: deviceUser._id
        text: title
        style: ''
        data_row: 1
        data_col: 1
        data_sizex: 6
        data_sizey: 1
        data_wait_init: true
      })
      Array.prototype.push.apply(newPub, post.pub)
      post.pub = newPub
      # formatPostPub(post.pub)
      if isTodayPost
        console.log('update motion post:', postId)
        Posts.update({_id:postId},{$set:post})
        globalPostsUpdateHookDeferHandle(post.owner, postId,null,{$set:post})
        return;
      post._id = postId
      globalPostsInsertHookDeferHandle(post.owner, post._id)
      Posts.insert(post)
      console.log('insert motion post:', post._id)
    this.response.end('{"result": "ok"}\n')
  )
  Router.route('/restapi/date', (req, res, next)->
    headers = {
      'Content-type':'text/html;charest=utf-8',
      'Date': Date.now()
    }
    this.response.writeHead(200, headers)
    this.response.end(Date.now().toString())
  , {where: 'server'})
  Router.route('/restapi/allgroupsid/:token/:skip/:limit', {where: 'server'}).get(()->
      token = this.params.token
      limit = this.params.limit
      skip  = this.params.skip

      headers = {
        'Content-type':'text/html;charest=utf-8',
        'Date': Date.now()
      }
      this.response.writeHead(200, headers)
      console.log '/restapi/allgroupsid get request, token:' + token + ' limit:' + limit + ' skip:' + skip

      allgroups = []
      groups = SimpleChat.Groups.find({}, {fields:{"_id": 1, "name": 1}, limit: parseInt(limit), skip: parseInt(skip)})
      unless groups
        return this.response.end('[]\n')
      groups.forEach((group)->
        allgroups.push({'id':group._id, 'name': group.name})
      )

      this.response.end(JSON.stringify(allgroups))
    )
  Router.route('/restapi/groupusers/:token/:groupid/:skip/:limit', {where: 'server'}).get(()->
      token = this.params.token
      limit = this.params.limit
      skip  = this.params.skip
      groupid = this.params.groupid

      headers = {
        'Content-type':'text/html;charest=utf-8',
        'Date': Date.now()
      }
      this.response.writeHead(200, headers)
      console.log '/restapi/groupusers get request, token:' + token + ' limit:' + limit + ' skip:' + skip + ' groupid:' + groupid

      group = SimpleChat.Groups.findOne({'_id': groupid})
      unless group
        console.log 'no group found:' + groupid
        return this.response.end('[]\n')

      #groupDevices = Devices.find({'groupId': groupid}).fetch()
      #console.log 'no group found:' + groupDevices

      allUsers = []
      userGroups = SimpleChat.GroupUsers.find({group_id: groupid}, {fields:{"user_id": 1, "user_name": 1}, limit: parseInt(limit), skip: parseInt(skip)})
      unless userGroups
        return this.response.end('[]\n')
      userGroups.forEach((userGroup)->
        #if _.pluck(groupDevices, 'uuid').indexOf(userGroup.user_id) is -1
        allUsers.push({'user_id':userGroup.user_id, 'user_name': userGroup.user_name})
      )

      this.response.end(JSON.stringify(allUsers))
    )
  Router.route('/restapi/activity/:token/:direction/:groupid/:ts/:skip/:limit', {where: 'server'}).get(()->
      token = this.params.token
      groupid = this.params.groupid
      limit = this.params.limit
      skip  = this.params.skip
      direction = this.params.direction
      starttime = this.params.ts

      headers = {
        'Content-type':'text/html;charest=utf-8',
        'Date': Date.now()
      }
      this.response.writeHead(200, headers)
      console.log '/restapi/user get request, token:' + token + ' limit:' + limit + ' skip:' + skip + ' groupid:' + groupid + ' Direction:' + direction + ' starttime:' + starttime

      group = SimpleChat.Groups.findOne({'_id': groupid})
      unless group
        console.log 'no group found:' + groupid
        return this.response.end('[]\n')

      allActivity = []
      #Activity.id is id of person name
      groupActivity = Activity.find(
       {'group_id': groupid, 'ts': {$gt: parseInt(starttime)}, 'in_out': direction}
       {fields:{'id': 1, 'name': 1, 'ts': 1, 'in_out': 1, 'img_url':1}, limit: parseInt(limit), skip: parseInt(skip)}
      )
      unless groupActivity
        return this.response.end('[]\n')
      groupActivity.forEach((activity)->
        allActivity.push({'user_id': activity.id, 'user_name': activity.name, 'in_out': activity.in_out, 'img_url': activity.img_url})
      )

      this.response.end(JSON.stringify(allActivity))
    )

  Router.route('/restapi/active/:active/:token/:direction/:skip/:limit', {where: 'server'}).get(()->
      token = this.params.token         #
      limit = this.params.limit         #
      skip  = this.params.skip          #
      direction = this.params.direction #'in'/'out'
      active = this.params.active       #'active'/'notactive'

      headers = {
        'Content-type':'text/html;charest=utf-8',
        'Date': Date.now()
      }
      this.response.writeHead(200, headers)
      console.log '/restapi/:active get request, token:' + token + ' limit:' + limit + ' skip:' + skip + ' Direction:' + direction + ' active:' + active

      allnotActivity = []
      daytime = new Date()
      daytime.setSeconds(0)
      daytime.setMinutes(0)
      daytime.setHours(0)
      daytime = new Date(daytime).getTime()

      notActivity = WorkAIUserRelations.find({}, {limit: parseInt(limit), skip: parseInt(skip)})
      unless notActivity
        return this.response.end('[]\n')
      notActivity.forEach((item)->
        #console.log(item)
        if !item.checkin_time
          item.checkin_time = 0
        if !item.ai_in_time
          item.ai_in_time= 0
        if !item.checkout_time
          item.checkout_time = 0
        if !item.ai_out_time
          item.ai_out_time = 0

        if active is 'notactive'
          if direction is 'in' and item.checkin_time < daytime and item.ai_in_time < daytime
            allnotActivity.push({
              'app_user_id': item.app_user_id
              'app_user_name': item.app_user_name
              'uuid': item.in_uuid
              'groupid': item.group_id
              'msgid': new Mongo.ObjectID()._str
            })
          else if direction is 'out' and item.checkout_time < daytime and item.ai_out_time < daytime
            allnotActivity.push({
              'app_user_id': item.app_user_id
              'app_user_name': item.app_user_name
              'uuid': item.out_uuid
              'groupid': item.group_id
              'msgid': new Mongo.ObjectID()._str
            })
        else if active is 'active'
          if direction is 'in' and (item.checkin_time > daytime or item.ai_in_time > daytime)
            allnotActivity.push({
              'app_user_id': item.app_user_id
              'app_user_name': item.app_user_name
              'uuid': item.in_uuid
              'groupid': item.group_id
              'msgid': new Mongo.ObjectID()._str
            })
          else if direction is 'out' and (item.checkout_time > daytime or item.ai_out_time > daytime)
            allnotActivity.push({
              'app_user_id': item.app_user_id
              'app_user_name': item.app_user_name
              'uuid': item.out_uuid
              'groupid': item.group_id
              'msgid': new Mongo.ObjectID()._str
            })
      )

      this.response.end(JSON.stringify(allnotActivity))
    )
  Router.route('/restapi/resetworkstatus/:token', {where: 'server'}).get(()->
      token = this.params.token         #

      headers = {
        'Content-type':'text/html;charest=utf-8',
        'Date': Date.now()
      }
      this.response.writeHead(200, headers)
      console.log '/restapi/resetworkstatus get request'

      date = Date.now();
      mod = 24*60*60*1000;
      date = date - (date % mod)
      nextday = date + mod

      relations = WorkAIUserRelations.find({})
      relations.forEach((fields)->
        if fields && fields.group_id
          # 按 group 所在时区初始化 workStatus 数据
          timeOffset = 8
          shouldInitWorkStatus = false
          group = SimpleChat.Groups.findOne({_id: fields.group_id})
          if (group and group.offsetTimeZone)
            timeOffset = parseInt(group.offsetTimeZone)

          # 根据时区 获取 group 对应时区时间
          group_local_time = getLocalTimeByOffset(timeOffset)
          group_local_time_hour = group_local_time.getHours()
          if group_local_time_hour is 0
            shouldInitWorkStatus = true
            console.log('now should init the offsetTimeZone: ', timeOffset)
          #console.log('>>> ' + JSON.stringify(fields))
          workstatus = WorkStatus.findOne({'group_id': fields.group_id, 'date': nextday, 'person_name': fields.person_name})
          if !workstatus and shouldInitWorkStatus
            newWorkStatus = {
              "app_user_id" : fields.app_user_id
              "group_id"    : fields.group_id
              "date"        : nextday
              "person_id"   : fields.ai_persons
              "person_name" : fields.person_name
              "status"      : "out"
              "in_status"   : "unknown"
              "out_status"  : "unknown"
              "in_uuid"     : fields.in_uuid
              "out_uuid"    : fields.out_uuid
              "whats_up"    : ""
              "in_time"     : 0
              "out_time"    : 0
              "hide_it"     : if fields.hide_it then fields.hide_it else  false
            }
            #console.log('>>> new a WorkStatus ' + JSON.stringify(newWorkStatus))
            
            WorkStatus.insert(newWorkStatus)
      )

      # 计算没有确认下班的数据
      docs = UserCheckoutEndLog.find({}).fetch()
      docs.map (doc)->
        # remove
        UserCheckoutEndLog.remove({_id: doc._id})

        # 状态
        startUTC = Date.UTC(doc.params.msg_data.create_time.getUTCFullYear(), doc.params.msg_data.create_time.getUTCMonth(), doc.params.msg_data.create_time.getUTCDate(), 0, 0, 0, 0)
        endUTC = Date.UTC(doc.params.msg_data.create_time.getUTCFullYear(), doc.params.msg_data.create_time.getUTCMonth(), doc.params.msg_data.create_time.getUTCDate(), 23, 59, 59, 0)
        workstatus = WorkStatus.findOne({'group_id': doc.params.msg_data.group_id, 'date': {$gte: startUTC, $lte: endUTC}})

        # local date
        now = new Date()
        group = SimpleChat.Groups.findOne({_id: doc.params.msg_data.group_id})
        if (group and group.offsetTimeZone)
          now = new Date((now.getTime()+(now.getTimezoneOffset()*60000)) + (3600000*group.offsetTimeZone))
        else
          now = new Date((now.getTime()+(now.getTimezoneOffset()*60000)) + (3600000*8))

        # console.log('===1==', workstatus.status)
        unless (workstatus and workstatus.status is 'out')
          # console.log('===2==', doc.userName, doc.params.msg_data.create_time.getUTCDate(), now.getUTCDate())
          # 当天数据
          if (doc.params.msg_data.create_time.getUTCDate() is now.getUTCDate())
            # console.log('===3==', doc.userName)
            send_greeting_msg(doc.params.msg_data);
            PERSON.updateWorkStatus(doc.params.person._id)
            if (doc.params.person_info)
              PERSON.sendPersonInfoToWeb(doc.params.person_info)
          else
            # TODO:

      this.response.end(JSON.stringify({result: 'ok'}))
    )

 
  # params = {
  #   uuid: 设备UUID,
  #   person_id: id,
  #   video_post: 视频封面图地址,
  #   video_src: 视频播放地址
  #   ts: 时间戳
  #   ts_offset: 时区 (eg : 东八区 是 -8);
  # }
  Router.route('/restapi/timeline/video/', {where: 'server'}).post(()->
    payload = this.request.body || {}
    console.log('/restapi/timeline/video/ request body = ',JSON.stringify(payload))

    if (!payload.uuid or !payload.person_id or !payload.video_post or !payload.video_src or !payload.ts or !payload.ts_offset)
      return this.response.end('{"result": "error", "reson":"参数不全或格式错误！"}\n')

    # step 1. get group_id by uuid
    device = Devices.findOne({uuid: payload.uuid})
    if device and device.groupId
      group_id = device.groupId

    # step 2. get person_name by person_id
    person_name = PERSON.getName(payload.uuid, group_id, payload.person_id)
    if (!person_name)
      person_name = ""

    PERSON.updateToDeviceTimeline(payload.uuid,group_id,{
      is_video: true,
      person_id: payload.person_id,
      person_name: person_name,
      video_post: payload.video_post,
      video_src: payload.video_src,
      ts: Number(payload.ts),
      ts_offset: Number(payload.ts_offset)
    })

    return this.response.end('{"result": "success"}\n')
  )
  Router.route('/restapi/clustering', {where: 'server'}).get(()->
      group_id = this.params.query.group_id
      faceId = this.params.query.faceId
      totalFaces = this.params.query.totalFaces
      url = this.params.query.url
      rawfilepath = this.params.query.rawfilepath
      isOneSelf = this.params.query.isOneSelf
      if isOneSelf == 'true'
        isOneSelf = true
      else
        isOneSelf = false

      console.log '/restapi/clustering get request, group_id:' + group_id + ', faceId:' + faceId + ',totalFaces:' + totalFaces + ',url' + url + ',rawfilepath' + rawfilepath + ',isOneSelf' + isOneSelf
      unless group_id and isOneSelf
        return this.response.end('{"result": "failed", "cause": "invalid params"}\n')

      #取回这个组某个人所有正确/不正确的图片
      if group_id and faceId
        dataset={'group_id': group_id, 'faceId': faceId, 'dataset': []}
        allClustering = Clustering.find({'group_id': group_id, 'faceId': faceId, 'isOneSelf': isOneSelf}).fetch()
        allClustering.forEach((fields)->
          dataset.dataset.push({url:fields.url, rawfilepath: fields.rawfilepath})
        )
      else
        dataset={'group_id': group_id, 'dataset': []}

      #取回这个组某个人所有不正确的图片

      #返回标注过的数据集
      this.response.end(JSON.stringify(dataset))
    ).post(()->
      if this.request.body.hasOwnProperty('group_id')
        group_id = this.request.body.group_id
      if this.request.body.hasOwnProperty('faceId')
        faceId = this.request.body.faceId
      if this.request.body.hasOwnProperty('totalFaces')
        totalFaces = this.request.body.totalFaces
      if this.request.body.hasOwnProperty('url')
        url = this.request.body.url
      if this.request.body.hasOwnProperty('rawfilepath')
        rawfilepath = this.request.body.rawfilepath
      if this.request.body.hasOwnProperty('isOneSelf')
        isOneSelf = this.request.body.isOneSelf

      if isOneSelf == "true"
        isOneSelf = true

      console.log '/restapi/clustering post request, group_id:' + group_id + ', faceId:' + faceId + ',totalFaces:' + totalFaces + ',url' + url + ',rawfilepath' + rawfilepath + ',isOneSelf' + isOneSelf
      unless group_id and faceId and url
        return this.response.end('{"result": "failed", "cause": "invalid params"}\n')

      #插入数据库
      person = Person.findOne({group_id: group_id, 'faceId': faceId},{sort: {createAt: 1}})
      if !person
        person = {
          _id: new Mongo.ObjectID()._str,
          id: 1,
          group_id: group_id,
          faceId: faceId,
          url: url,
          name: faceId,
          faces: [],
          deviceId: 'clustering',
          DeviceName: 'clustering',
          createAt: new Date(),
          updateAt: new Date()
        };
        Person.insert(person)
        console.log('>>> new people' + faceId)

      clusteringObj = {
          group_id: group_id,
          faceId: faceId,
          totalFaces: totalFaces,
          url: url,
          rawfilepath: rawfilepath,
          isOneSelf: isOneSelf
      }
      Clustering.insert(clusteringObj)
      #console.log('>>> ' + JSON.stringify(clusteringObj))
      this.response.end('{"result": "ok"}\n')
    )
  Router.route('/restapi/datasync/:token/:groupid', {where: 'server'}).get(()->
      token = this.params.token
      groupid = this.params.groupid

      headers = {
        'Content-type':'text/html;charest=utf-8',
        'Date': Date.now()
      }
      this.response.writeHead(200, headers)
      console.log '/restapi/datasync get request, token:' + token + ' groupid:' + groupid

      group = SimpleChat.Groups.findOne({'_id': groupid})
      unless group
        console.log 'no group found:' + groupid
        return this.response.end('[]\n')

      syncDateSet=[]

      #取出群相册里面所有已经标注的数据
      persons = Person.find({group_id: groupid},{fields:{name: 1, faceId:1}}).fetch()
      persons.forEach((item)->
        urls=[]
        if item and item.name
          dataset = LableDadaSet.find({group_id: groupid ,name: item.name}, {fields:{url: 1,style:1,sqlid:1}}).fetch()
          dataset.forEach((item2)->
            if item2 and item2.url
              urls.push({
                url:item2.url,
                style: item2.style || 'front',
                sqlid: item2.sqlid || null
              })
          )

        if item and item.faceId
          syncDateSet.push({faceId: item.faceId, urls: urls})
      )

      this.response.end(JSON.stringify(syncDateSet))
    )
  Router.route('/restapi/clusterdatasync/:token/:groupid', {where: 'server'}).get(()->
      token = this.params.token
      groupid = this.params.groupid

      headers = {
        'Content-type':'text/html;charest=utf-8',
        'Date': Date.now()
      }
      this.response.writeHead(200, headers)
      console.log '/restapi/datasync get request, token:' + token + ' groupid:' + groupid

      group = SimpleChat.Groups.findOne({'_id': groupid})
      unless group
        console.log 'no group found:' + groupid
        return this.response.end('[]\n')

      syncDateSet=[]

      #取出群相册里面所有已经标注的数据
      person = ClusterPerson.find({group_id: groupid},{fields:{name: 1, faceId:1}}).fetch()
      person.forEach((item)->
        urls=[]
        if item and item.name
          dataset = ClusterLableDadaSet.find({group_id: groupid ,name: item.name}, {fields:{url: 1,style:1,sqlid:1}}).fetch()
          dataset.forEach((item2)->
            if item2 and item2.url
              urls.push({
                url:item2.url,
                style: item2.style || 'front',
                sqlid: item2.sqlid || null
              })
          )

        if item and item.faceId
          syncDateSet.push({faceId: item.faceId, urls: urls})
      )

      this.response.end(JSON.stringify(syncDateSet))
    )

  getInComTimeLen = (workstatus) ->
    group_id = workstatus.group_id;
    diff = 0;
    out_time = workstatus.out_time;
    today_end = workstatus.out_time;
    time_offset = 8
    group = SimpleChat.Groups.findOne({_id: group_id});
    if (group && group.offsetTimeZone)
      time_offset = group.offsetTimeZone;
    DateTimezone = (d, time_offset) ->
        if (time_offset == undefined)
          if (d.getTimezoneOffset() == 420)
              time_offset = -7
          else
              time_offset = 8
        #取得 UTC time
        utc = d.getTime() + (d.getTimezoneOffset() * 60000);
        local_now = new Date(utc + (3600000*time_offset))
        today_now = new Date(local_now.getFullYear(), local_now.getMonth(), local_now.getDate(), 
        local_now.getHours(), local_now.getMinutes());
      
        return today_now;

    #计算out_time
    if(workstatus.in_time)
      date = new Date(workstatus.in_time);
      fomatDate = date.shortTime(time_offset);
      isToday = PERSON.checkIsToday(workstatus.in_time,group_id)
      #不是今天的时间没有out_time的或者是不是今天时间，最后一次拍到的是进门的状态的都计算到当天结束
      if((!out_time and !isToday) or (workstatus.status is 'in' and !isToday))
        date = DateTimezone(date,time_offset);
        day_end = new Date(date).setHours(23,59,59);
        #day_end = new Date(this.in_time).setUTCHours(0,0,0,0) + (24 - time_offset)*60*60*1000 - 1;
        out_time = day_end;
        workstatus.in_time = date.getTime();
      #今天的时间（没有离开过公司）
      else if(!out_time and isToday)
        now_time = Date.now();
        out_time = now_time;
      #今天的时间（离开公司又回到公司）
      else if(out_time and workstatus.status is 'in' and isToday)
        now_time = Date.now();
        out_time = now_time;

    if(workstatus.in_time and out_time)
      diff = out_time - workstatus.in_time;

    if(diff > 24*60*60*1000)
      diff = 24*60*60*1000;
    else if(diff < 0)
      diff = 0;

    min = diff / 1000 / 60 ;
    hour = Math.floor(min/60)+' h '+Math.floor(min%60) + ' min';
    if(min < 60)
      hour = Math.floor(min%60) + ' min';
    if(diff == 0)
      hour = '0 min';
    return hour;

  getShortTime = (ts,group_id)->
    time_offset = 8
    group = SimpleChat.Groups.findOne({_id: group_id});
    if (group && group.offsetTimeZone)
      time_offset = group.offsetTimeZone;
    time = new Date(ts);
    return time.shortTime(time_offset,true);

  sendEmailToGroupUsers = (group_id)->
    if !group_id
      return
    group = SimpleChat.Groups.findOne({_id:group_id});
    if !group
      return

    date = Date.now();
    mod = 24*60*60*1000;
    date = date - (date % mod)
    yesterday = date - mod
    console.log 'date:'+ yesterday
    workstatus_content = ''
    WorkStatus.find({'group_id': group_id, 'date': yesterday}).forEach((target)->
      unless target.hide_it
        text = Assets.getText('email/work-status-content.html');
        text = text.replace('{{person_name}}', target.person_name);
        # app_user_status_color = 'gray'
        # app_notifaction_status = ''
        # if target.app_user_id
        #   app_user_status_color = 'green'
        #   if target.app_notifaction_status is 'on'
        #     app_notifaction_status = '<i class="fa fa-bell app-user-status" style="color:green;"></i>'
        #   app_user_status = '<i class="fa fa-user app-user-status" style="color:green;"></i>'+app_notifaction_status
        # text = text.replace('{{app_user_status_color}}',app_user_status_color);
        # text = text.replace('{{app_notifaction_status}}',app_notifaction_status);
        isStatusIN_color =  if target.status is 'in' then 'green' else 'gray'
        # if target.in_time > 0
        #   if PERSON.checkIsToday(target.in_time,group_id)
        #     isStatusIN_color = 'gray'
        # text = text.replace('{{isStatusIN_color}}',isStatusIN_color);

        InComTimeLen = getInComTimeLen(target)
        text = text.replace('{{InComTimeLen}}',InComTimeLen);
        isInStatusNotUnknownStyle = if target.in_status is 'unknown' then 'display:none;' else 'display:table-cell;'
        text = text.replace('{{isInStatusNotUnknownStyle}}',isInStatusNotUnknownStyle);
        isInStatusUnknownStyle = if target.in_status is 'unknown' then 'display:table-cell;' else 'display:none;'
        text = text.replace('{{isInStatusUnknownStyle}}',isInStatusUnknownStyle);
        if target.in_status isnt 'unknown'
          text = text.replace('{{in_image}}',target.in_image);
          text = text.replace('{{in_time}}',getShortTime(target.in_time,group_id))
          in_time_Color = 'green'
          if target.in_status is 'warning'
            in_time_Color = 'orange'
          else if target.in_status is 'error'
            in_time_Color = 'red'
          text = text.replace('{{in_time_Color}}',in_time_Color);
        historyUnknownOutStyle = 'display:none;'
        if isStatusIN_color is 'green'
          historyUnknownOutStyle = 'display:table-cell;color:red;'
        else
          if target.out_status is 'unknown'
            historyUnknownOutStyle = 'display:table-cell;'
        text = text.replace('{{historyUnknownOutStyle}}',historyUnknownOutStyle);

        isOutStatusNotUnknownStyle = if historyUnknownOutStyle is 'display:none;' then 'display:table-cell;' else 'display:none;'
        text = text.replace('{{isOutStatusNotUnknownStyle}}',isOutStatusNotUnknownStyle);
        if historyUnknownOutStyle is 'display:none;'
          text = text.replace('{{out_image}}',target.out_image);
          text = text.replace('{{out_time}}',getShortTime(target.out_time,group_id));
          out_time_Color = 'green'
          if target.out_status is 'warning'
            out_time_Color = 'orange'
          else if target.out_status is 'error'
            out_time_Color = 'red'
          text = text.replace('{{out_time_Color}}',out_time_Color);
        whats_up = ''
        if target.whats_up
          whatsUpLists = [];
          if typeof(target.whats_up) is 'string'
            whatsUpLists.push({
              person_name:target.person_name,
              content:target.whats_up,
              ts:target.in_time
              })
            # ...
          else
            whatsUpLists = target.whats_up
          for item in whatsUpLists
            whats_up = whats_up + '<p style="white-space: pre-wrap;"><strong>'+item.person_name+'</strong>['+getShortTime(item.ts,group_id)+']'+item.content
        else
          whats_up = '今天还没有工作安排...'
        text = text.replace('{{whats_up}}',whats_up);

        workstatus_content = workstatus_content + text

      )
    if workstatus_content.length > 0
      text = Assets.getText('email/work-status-report.html');
      text = text.replace('{{group.name}}', group.name);
      y_date = new Date(yesterday)
      year = y_date.getFullYear();
      month = y_date.getMonth() + 1;
      y_date_title = '(' + year + '-' + month + '-' +y_date.getDate() + ')';
      text = text.replace('{{date.fomatStr}}',y_date_title)
      text = text.replace('{{workStatus.content}}', workstatus_content);
      subject = group.name + ' 每日出勤报告'+y_date_title
    else
      return
    
      #console.log 'html:'+ JSON.stringify(text)
    SimpleChat.GroupUsers.find({group_id:group_id}).forEach(
      (fields)->
        if fields and fields.user_id
          user_id = fields.user_id
          #user_id = 'GriTByu7MhRGhQdPD'
          user = Meteor.users.findOne({_id:user_id});
          if user and user.emails and user.emails.length > 0
            email_address = user.emails[0].address
            #email_address = 'dsun@actionteca.com'
            isUnavailable = UnavailableEmails.findOne({address:email_address});
            unless isUnavailable
              #email_address = user.emails[0].address
              console.log 'groupuser : ' + user.profile.fullname + '  email address is :' + user.emails[0].address

              try
                Email.send({
                  to:email_address,
                  from:'点圈<notify@mail.tiegushi.com>',
                  subject:subject,
                  html : text,
                  envelope:{
                    from:'点圈<notify@mail.tiegushi.com>',
                    to:email_address + '<' + email_address + '>'
                  }
                })
                console.log 'try send mail to:'+email_address
              catch e
                console.log 'exception:send mail error = %s, userEmail = %s',e,email_address
                ###
                unavailableEmail = UnavailableEmails.findOne({address:email_address})
                if unavailableEmail
                  UnavailableEmails.update({reason:e});
                else
                  UnavailableEmails.insert({address:email_address,reason:e,createAt:new Date()});
                ###
    )


  Router.route('/restapi/sendReportByEmail/:token',{where:'server'}).get(()->
    token = this.params.token         #

    headers = {
      'Content-type':'text/html;charest=utf-8',
      'Date': Date.now()
    }
    this.response.writeHead(200, headers)
    console.log '/restapi/sendReportByEmail get request'
    #sendEmailToGroupUsers('ae64c98bdff9b674fb5dad4b')
    groups = SimpleChat.Groups.find({})
    groups.forEach((fields)->
      if fields
        sendEmailToGroupUsers(fields._id)
      )

    this.response.end(JSON.stringify({result: 'ok'}))
  )
  
  # Faces API 
  # [{
  #   'id': id,
  #   'uuid': uuid,
  #   'group_id': current_groupid,
  #   'img_url': url,
  #   'position': position,
  #   'type': img_type,
  #   'current_ts': int(time.time()*1000),
  #   'accuracy': accuracy,
  #   'fuzziness': fuzziness,
  #   'sqlid': sqlId,
  #   'style': style,
  #   'tid': tid,
  #   'img_ts': img_ts,
  #   'p_ids': p_ids,
  # }]
  Router.route('/restapi/workai/faces',{where:'server'}).post(()->
    data = this.request.body
    console.log(data)
    if (typeof data is 'object' and data.constructor is Array)
      data.forEach((face)->
        insertFaces(face)
      )
      this.response.end('{"result": "ok"}\n')
    else
      this.response.end('{"result": "ok", "reason": "params must be an Array"}\n')
  )

  # 定义相应的mailgun webhook, dropped,hardbounces,unsubscribe 下次不再向相应的邮件地址发信
  # docs: https://documentation.mailgun.com/en/latest/user_manual.html#webhooks
  @mailGunSendHooks = (address, type, reason)->
    if !address and !reason
      return console.log('need email address and webhook reason')

    console.log('Email send Hooks, send to '+address + ' failed , reason: '+ reason)

    unavailableEmail = UnavailableEmails.findOne({address: address})
    if unavailableEmail
      UnavailableEmails.update({_id: unavailableEmail._id},{$set:{
        reason:reason
      }})
    else
      UnavailableEmails.insert({
        address: address,
        reason: reason
        createAt: new Date()
      })

  # 发信失败跟踪 (Dropped Messages)
  Router.route('/hooks/emails/dropped', {where: 'server'}).post(()->

    data = this.request.body
    mailGunSendHooks(emails,'dropped')
    headers = {
      'Content-type': 'application/vnd.openxmlformats',
      'Content-Disposition': 'attachment; filename=' + title + '.xlsx'
    }

    this.response.writeHead(200, headers)
    this.response.end('{"result": "ok"}\n')
  )

  # 硬/软 退信跟踪 (Hard Bounces)
  Router.route('/hooks/emails/bounced', {where: 'server'}).post(()->
    data = this.request.body
    type = data.event || 'bounced'
    mailGunSendHooks(data.recipient,type)
    headers = {
      'Content-type': 'application/vnd.openxmlformats',
      'Content-Disposition': 'attachment; filename=' + title + '.xlsx'
    }

    this.response.writeHead(200, headers)
    this.response.end('{"result": "ok"}\n')
  )

  # 垃圾邮件跟踪 (Spam Complaints)
  Router.route('/hooks/emails/complained', {where: 'server'}).post(()->
    data = this.request.body
    type = data.event || 'complained'
    mailGunSendHooks(data.recipient,type)
    headers = {
      'Content-type': 'application/vnd.openxmlformats',
      'Content-Disposition': 'attachment; filename=' + title + '.xlsx'
    }

    this.response.writeHead(200, headers)
    this.response.end('{"result": "ok"}\n')
  )

  # 取消订阅跟踪 (Unsubscribes)
  Router.route('/hooks/emails/unsubscribe', {where: 'server'}).post(()->
    data = this.request.body
    type = data.event || 'unsubscribe'
    mailGunSendHooks(data.recipient,type)
    headers = {
      'Content-type': 'application/vnd.openxmlformats',
      'Content-Disposition': 'attachment; filename=' + title + '.xlsx'
    }

    this.response.writeHead(200, headers)
    this.response.end('{"result": "ok"}\n')
  )