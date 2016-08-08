if Meteor.isClient
  @baseGap = 5
  window.iabHandle = null
  Session.set('lastImportedUrl','')
  Session.setDefault('itemInAddPostPending',0)
  @getDisplayElementWidth=()->
    $('.addPost').width()*0.9
  handleSaveDraft = ()->
    layout = JSON.stringify(gridster.serialize())
    pub=[]
    title = $("#title").val()
    console.log "title = " + title
    addontitle = $("#addontitle").val()
    draftData = Drafts.find().fetch()
    draftId = draftData[0]._id;
    for i in [0..(draftData.length-1)]
      if i is 0
        if draftData[i].URI isnt ''
          mainImage = draftData[i].URI
        else
          mainImage = draftData[i].imgUrl
        mainText = $("#"+draftData[i]._id+"text").val()

      json = jQuery.parseJSON(layout);
      for item in json
        if item.id is draftData[i]._id
          draftData[i].data_row = item.row
          draftData[i].data_col = item.col
          draftData[i].data_sizex = item.size_x
          draftData[i].data_sizey = item.size_y
      if draftData[i].URI isnt '' and device.platform is 'Android'
        draftData[i].imgUrl = draftData[i].URI
      pub.push(draftData[i])

    sortBy = (key, a, b, r) ->
      r = if r then 1 else -1
      return -1*r if a[key] and b[key] and a[key] > b[key]
      return +1*r if a[key] and b[key] and a[key] < b[key]
      return +1*r if a[key] is undefined and b[key]
      return -1*r if a[key] and b[key] is undefined
      return 0
    pub.sort((a, b)->
      sortBy('data_row', a, b)
    )
    fromUrl = ''
    if Drafts.find({type:'image'}).count() > 0
      url = Drafts.find({type:'image'}).fetch()[0].url
    if url and url isnt ''
      fromUrl = url
    try
      if SavedDrafts.find({_id:draftId}).count() > 0
        SavedDrafts.update(
          {_id:draftId},
          {$set:{
            pub:pub,
            title:title,
            addontitle:addontitle,
            mainImage: mainImage,
            fromUrl: fromUrl,
            mainText: mainText,
            owner:Meteor.userId(),
            createdAt: new Date(),
          }}
        )
      else
        SavedDrafts.insert {
          _id:draftId,
          pub:pub,
          title:title,
          addontitle:addontitle,
          fromUrl:fromUrl,
          mainImage: mainImage,
          mainText: mainText,
          owner:Meteor.userId(),
          createdAt: new Date(),
        }
    catch error
      console.log("Insert SavedDrafts error! Try update it...");
      SavedDrafts.update(
        {_id:draftId},
        {$set:{
          pub:pub,
          title:title,
          addontitle:addontitle,
          fromUrl:fromUrl,
          mainImage: mainImage,
          mainText: mainText,
          owner:Meteor.userId(),
          createdAt: new Date(),
        }}
      )
    return
    insertLink = (linkInfo,mainImageUrl,found,inputUrl)->
    if mainImageUrl
      timestamp = new Date().getTime()
      if Drafts.find({type:'image'}).count() > 0
        Drafts.update({_id:Drafts.find({type:'image'}).fetch()[0]._id},{$set:{url:inputUrl}})
      Drafts.insert {
        type:'image',
        isImage:true,
        siteTitle:linkInfo.title,
        siteHost:linkInfo.host,
        owner: Meteor.userId(),
        imgUrl:mainImageUrl,
        filename:Meteor.userId()+'_'+timestamp+ '_' + mainImageUrl.replace(/^.*[\\\/]/, ''),
        URI:mainImageUrl,
        url:inputUrl,
        toTheEnd: true,
        data_row:'1',
        data_col:'3',
        data_sizex:'6',
        data_sizey:'6'}
  insertDownloadedImage = (linkInfo,imageExternalURL,found,inputUrl,file,width,height)->
    if file
      timestamp = new Date().getTime()
      if Drafts.find({type:'image'}).count() > 0
        Drafts.update({_id:Drafts.find({type:'image'}).fetch()[0]._id},{$set:{url:inputUrl}})
      sizey = Math.round( 6 * height / width )
      if sizey <= 0
        sizey = 1
      #if sizey >= 12
      #  sizey = 12
      Drafts.insert {
        type:'image',
        isImage:true,
        siteTitle:linkInfo.title,
        siteHost:linkInfo.host,
        owner: Meteor.userId(),
        imgUrl:'cdvfile://localhost/persistent/'+file.name,
        filename:file.name,
        URI:file.toURL(),
        url:inputUrl,
        toTheEnd: true,
        data_row:'1',
        data_col:'3',
        data_sizex:'6',
        data_sizey:sizey.toString()}
      #window.resolveLocalFileSystemURL file.toURL(), (fileEntry)->
        #fileURL = file.toURL()
        #fileName = fileURL.substring(fileURL.lastIndexOf('/')+1)
        #fileDir = fileURL.substring(0, fileURL.lastIndexOf('/'))
        #console.log 'parse file URL: filename: ' + fileName + ', dir: ' + fileDir
        #imageType = 'jpg';
        #console.log 'fileentry: ' + fileURL
        #if fileURL.endsWith('.png')
        #  imageType = 'png';
        #fileEntry.file (fileObj)->
          #console.log 'fileObj: ' + fileObj
          #console.log 'filesize: ' + fileObj.size
          #if fileObj.size > 100*1024
            #window.imageResizer.resizeImage( (data)->
                #console.log('resizeImage, filename: ' + data.filename + 'width: ' + data.width + ',height: ' + data.height)
              #,(error)->
                #console.log("Error : \r\n" + error)
              #,file.toURL(), 64, 0, {imageDataType:ImageResizer.IMAGE_DATA_TYPE_URL, resizeType:ImageResizer.RESIZE_TYPE_MIN_PIXEL, #format: imageType, storeImage: true, filename: fileName, directory: fileDir});      
  insertVideoWithDownloadedImage = (videoInfo, linkInfo,imageExternalURL,found,inputUrl,file,width,height)->
    if file
      sizey = Math.round( 6 * height / width )
      if sizey <= 0
        sizey = 1
      insertVideoInfo(videoInfo, sizey.toString())
  insertDefaultImage = (linkInfo,mainImageUrl,found,inputUrl)->
    if mainImageUrl
      timestamp = new Date().getTime()
      if Drafts.find({type:'image'}).count() > 0
        Drafts.update({_id:Drafts.find({type:'image'}).fetch()[0]._id},{$set:{url:inputUrl}})
      Drafts.insert {
        type:'image',
        isImage:true,
        siteTitle:linkInfo.title,
        siteHost:linkInfo.host,
        owner: Meteor.userId(),
        imgUrl:mainImageUrl,
        filename:mainImageUrl,
        URI:mainImageUrl,
        url:inputUrl,
        toTheEnd: true,
        data_row:'1',
        data_col:'3',
        data_sizex:'6',
        data_sizey:'6'}
  insertMusicInfo = (musicInfo)->
    Drafts.insert {
      type:'music',
      owner: Meteor.userId(),
      toTheEnd: true,
      text:'您当前程序不支持音频播放，请分享到微信中欣赏',
      musicInfo: musicInfo
      data_row:'1',
      data_col:'3',
      data_sizex:'6',
      data_sizey:'1'}
  insertVideoInfo = (videoInfo, sizey)->
    if sizey
      data_sizey = sizey
    else
      data_sizey = '4'
    console.log("data_sizey is "+data_sizey);
    Drafts.insert {
      type:'video',
      owner: Meteor.userId(),
      toTheEnd: true,
      text:'来自故事贴',
      videoInfo: videoInfo
      data_row:'1',
      data_col:'3',
      data_sizex:'6',
      data_sizey:data_sizey}
  processReadableText=(data)->
    fullText = ''
    if data.fullText
      fullText = data.fullText
    else
      documentBody = $.parseHTML( data.body )
      documentBody.innerHTML = data.body
      documentBody.innerHTML.length = data.bodyLength
      extracted = extract(documentBody)
      fullText = $(extracted).text()
      console.log 'Extracted is ' + toDisplay
    if fullText and fullText isnt ''
      toDisplay = fullText.substring(0, 200)
      toDisplay += ' ...'
      Drafts.insert {type:'text', toTheEnd:true ,isImage:false, owner: Meteor.userId(), text:toDisplay, fullText:fullText, style:'', data_row:'1', data_col:'3',  data_sizex:'6', data_sizey:'1'}
    processTitleOfPost(data)
  processTitleOfPost=(data)->
    if data.title
      console.log 'Title is ' + data.title
      Session.set('importProcedure',100)
      Meteor.setTimeout ()->
        unless ($('#title').val() and $('#title').val() isnt '')
          $('#title').val(data.title)
          $('#title').trigger('keyup')
        unless ($('#addontitle').val() and $('#addontitle').val() isnt '')
          $('#addontitle').val("")
      ,1000
  itemProcessor = (item,callback)->
    this.index++
    console.log('item[' + this.index + ']: ' + JSON.stringify(item))
    percentage = 5 + Math.round(94*(this.index/this.length))
    Session.set('importProcedure',percentage)
    if Session.get('cancelImport')
      Session.set('importProcedure',100)
      console.log('User canceled the url importing by click on the cancel button')
      return callback(new Error('Cancled'),item)
    if item.type is 'text'
      console.log('Processing Text')
      Drafts.insert {type:'text', toTheEnd:true ,noKeyboardPopup:true,isImage:false, owner: Meteor.userId(),\
          text:item.text, style:'',layout:item.layout, data_row:'1', data_col:'3',  data_sizex:'6', data_sizey:'1'}
    else if item.type is 'image'
      console.log('Processing Image ' + item.imageUrl)
      self = this
      if item.imageUrl and item.imageUrl isnt ''
        imageArray = []
        imageArray.push(item.imageUrl)
        return seekSuitableImageFromArrayAndDownloadToLocal imageArray,(file,w,h,found,index,total,source)->
          if file
            insertDownloadedImage(self.data,source,found,self.inputUrl,file,w,h)
          callback(null,item)
        ,150,true
    else if item.type is 'iframe'
      Drafts.insert {
        type:'image',
        isImage:true,
        inIframe:true,
        owner: Meteor.userId(),
        toTheEnd: true,
        text:'您当前程序不支持视频观看',
        iframe: item.iframe,
        imgUrl:'http://data.tiegushi.com/res/video_old_version.jpg',
        data_row:'1',
        data_col:'3',
        data_sizex:'6',
        data_sizey:'4'}
    else if item.type is 'music'
      insertMusicInfo(item.musicInfo)
    else if item.type is 'video'
      self = this
      if item.videoInfo.imageUrl
        imageArray = []
        imageArray.push(item.videoInfo.imageUrl)
        return seekSuitableImageFromArrayAndDownloadToLocal imageArray,(file,w,h,found,index,total,source)->
          if file
            item.videoInfo.imageUrl = 'cdvfile://localhost/persistent/'+file.name
            item.videoInfo.filename = file.name
            item.videoInfo.URI = file.toURL()
            insertVideoWithDownloadedImage(item.videoInfo, self.data,source,found,self.inputUrl,file,w,h)
          else
            insertVideoInfo(item.videoInfo)
          callback(null,item)
        ,1,true
      else
        insertVideoInfo(item.videoInfo)
    Meteor.setTimeout ()->
      callback(null,item)
    ,10
  renderResortedArticleAsync = (data,inputUrl,resortedObj)->
    resortedObj.itemProcessor = itemProcessor
    resortedObj.data = data
    resortedObj.inputUrl = inputUrl
    async.mapLimit(data.resortedArticle,1,resortedObj.itemProcessor.bind(resortedObj),(err,results)->
      console.log('error ' + err)
      processTitleOfPost(data)
    )
  @showPopupProgressBar = (callback)->
    Session.set('importProcedure',1)
    Session.set('cancelImport',false)
    window.popupProgressBar = $('.importProgressBar').bPopup
      positionStyle: 'absolute'
      position: [0, 0]
      onOpen: ()->
        $(this).find('#cancelImport').on('click',()->
          console.log('Clicked on cancelImport button')
          Session.set('cancelImport',true)
          popupProgressBar.close()
          $('.modal-backdrop.in').remove()
          if Drafts.find().count() < 1
            Router.go('/')
          if (callback)
            callback()
        )
      onClose: ()->
        window.popupProgressBar = undefined
        Session.set('importProcedure',0)
        $(this).find('#cancelImport').off('click')
        $(this).find('.progress-bar').css('width', '0%').attr('aria-valuenow', 0);
    Tracker.autorun (handler)->
      $('.importProgressBar').find('.progress-bar').css('width', Session.get('importProcedure')+'%').attr('aria-valuenow', Session.get('importProcedure'));
      if Session.equals('importProcedure',100)
        popupProgressBar.close()
        handler.stop()
  showEditingPopupProgressBar = ()->
    console.log('showEditingPopupProgressBar')
    preEditingBar = $('.toEditingProgressBar').bPopup
      positionStyle: 'absolute'
      position: [0, 0]
      onOpen: ()->
        updateShowEditPopupProgressBarPercentage(0,0,0)
        Session.set('itemInAddPostPending',0)
      onClose: ()->
        updateShowEditPopupProgressBarPercentage(0,0,0)
    preEditingBar
  updateShowEditPopupProgressBarPercentage=(percentage,i,n)->
    $('.toEditingProgressBar').find('.progress-bar').css('width', percentage+'%').attr('aria-valuenow', percentage).text(percentage+'%');
    $('.toEditingProgressBar').find('.processed').text(i);
    $('.toEditingProgressBar').find('.total').text(n);
  closePreEditingPopup = ()->
    $('.toEditingProgressBar').bPopup().close()
  deferedProcessAddPostItemsWithEditingProcessBar = (pub)->
    pub.processed=0
    Session.set('itemInAddPostPending',pub.length)
    Meteor.defer ()->
      async.mapLimit(pub,1,(item,callback)->
        console.log('getcallback------------')
        console.log(item)
        console.log(callback)
        Drafts.insert(item)
        Meteor.defer ()->
          pub.processed++
          updateShowEditPopupProgressBarPercentage(Math.round(100*pub.processed/pub.length),pub.processed,pub.length)
          callback(null,item)
      ,(error,result)->
        closePreEditingPopup()
        Session.set('itemInAddPostPending',0)
        console.log('error-----------------')
        console.log(error)
        unless error
          console.log('no error')
          
        layout = JSON.stringify(gridster.serialize())
        new_pub = jQuery.parseJSON(layout)

        sortBy = (key, a, b, r) ->
          r = if r then 1 else -1
          return -1*r if a[key] and b[key] and a[key] > b[key]
          return +1*r if a[key] and b[key] and a[key] < b[key]
          return +1*r if a[key] is undefined and b[key]
          return -1*r if a[key] and b[key] is undefined
          return 0
        new_pub.sort((a, b)->
          sortBy('row', a, b)
        )
        
        json = []
        for item in new_pub
          for row in pub
            if row._id is item.id
              row.data_row = item.row
              row.data_col = item.col
              row.data_sizex = item.size_x
              row.data_sizey = item.size_y
              json.push(row)
              break
        
        window.format_post_pub_wait = json
        $('body').append('<div id="format-post-pub-wait"></div>')
        console.log(json)
      )
  @getURL = (e) ->
    inputUrl = e.url
    console.log "input url: " + inputUrl
    if inputUrl && inputUrl isnt ''
      Session.set('lastImportedUrl',inputUrl)
      if Session.get("channel") isnt 'addPost'
        prepareToEditorMode()
        PUB.page '/add'
      unless window.popupProgressBar
        showPopupProgressBar()
      getContentListsFromUrl iabHandle,inputUrl,(data)->
        if data is null
          window.trackImportEvent inputUrl
          console.log('AnalyseUrl error, need add error notification')
          return
        console.log('Got data')
        Session.set('NewImgAdd',false)
        resortObj = {}
        seekOneUsableMainImage(data,(file,w,h,found,index,total,source)->
          console.log('found ' + found + ' index ' + index + ' total ' + total + ' fileObject ' + file + ' source ' + source )
          Session.set('importProcedure',5)
          if file
            insertDownloadedImage(data,source,found,inputUrl,file,w,h)
            resortObj.mainUrl = source
          else
            insertDefaultImage(data,'http://data.tiegushi.com/res/defaultMainImage1.jpg',false,inputUrl)
          if data.resortedArticle.length > 0 and data.resortedArticle[0].type is 'image' and data.resortedArticle[0].imageUrl is source
            data.resortedArticle.splice(0, 1)
          if data.resortedArticle.length > 0
            resortObj.index = 0
            resortObj.length = data.resortedArticle.length
            console.log('resortObj' + JSON.stringify(resortObj))
            renderResortedArticleAsync(data,inputUrl,resortObj)
          else
            processTitleOfPost(data)
        ,200)
    else
      PUB.toast('请粘贴需要引用的链接')
  @handleExitBrowser = ()->
    window.iabHandle = null
  @handleHideBrowser = ()->
    if Session.get("channel") is 'addPost' and Drafts.find().count() is 0
      Router.go '/'
    else
      PUB.postPageBack()
  @handlerLoadStartEvent = (e)->
    console.log('Load Start ' + JSON.stringify(e))
    Session.set('importProcedure',3)
  @handlerLoadErrorEvent = (e)->
    iabHandle.removeEventListener 'loadstop',getURL
    iabHandle.addEventListener 'hide',handleHideBrowser
    console.log('Load Error' + JSON.stringify(e))
    window.plugins.toast.showShortCenter("访问导入链接超时，请点击右上角\"导入\"再试一次。");
    Meteor.setTimeout ()->
      iabHandle.show()
    ,500
  @handlerLoadStopEvent = (e)->
    Session.set('importProcedure',4)
    Meteor.setTimeout ()->
      getURL(e)
    ,1200
  @hanldeDirectLinkServerImport = (url)->
    api_url = 'http://'+import_server_url+':'+IMPORT_SERVER_PORT+'/import'
    id = (new Mongo.ObjectID())._str
    api_url += '/' + Meteor.userId();
    api_url += '/' + encodeURIComponent(url);
    console.log("api_url="+api_url)
    showPopupProgressBar(()->
      return navigator.notification.confirm('快速导入不成功，是否尝试高级导入？'
          (index)->
            if index is 1 then handleDirectLinkImport(url, 1)
          '温馨提示', ['是', '否']
      )
    )
    intrval = Meteor.setInterval(()->
        if Session.get('importProcedure') is 100 or Session.get('cancelImport')
          return Meteor.clearInterval(intrval)
        if Session.get('importProcedure') < 95
          Session.set('importProcedure', Session.get('importProcedure') + 1)
      , 200);

    try
        Meteor.call('httpCall', 'GET', api_url, (err, res)->
          Session.set('importProcedure', 97)
          Session.set('importProcedure', 100)
          if (err)
            console.log("httpCall error: err="+JSON.stringify(err));
            #console.log(res.content);
          result = JSON.parse(res.content);
          if (err || !result || result.status != 'succ')
            return navigator.notification.confirm('快速导入不成功，是否尝试高级导入？'
              (index)->
                if index is 1 then handleDirectLinkImport(url, 1)
              '温馨提示', ['是', '否']
            )
          PUB.toast('导入成功，我们正在对图片进行处理。');
          #location = result.json;
          if result.json
            url_array = result.json.split('/')
            if url_array.length > 0
              postId = url_array[url_array.length-1]
              #Router.go('/posts/'+postId)

              if postId
                Meteor.subscribe('publicPosts', postId, {
                  onStop: ()->
                    Router.go('/posts/'+postId)
                  onReady: ()->
                    postItem = Posts.findOne({_id:postId})
                    Session.set("TopicPostId", postId)
                    Session.set("TopicTitle", postItem.title)
                    Session.set("TopicAddonTitle", postItem.addontitle)
                    Session.set("TopicMainImage", postItem.mainImage)
                    Router.go('/addTopicComment/')
                  onError: ()->
                    Router.go('/posts/'+postId)
                })
              else
                Router.go('/posts/'+postId)
        )
    catch error
        console.log("ERROR: httpCall, api_url="+api_url);
  @handleDirectLinkImport = (url, clientSide)->
    if withServerImport and clientSide is undefined
      console.log("Import url on server side...")
      hanldeDirectLinkServerImport(url)
    else
      console.log("Import url on mobile side...")
      showPopupProgressBar()
      if iabHandle
        iabHandle.removeEventListener 'import',getURL
        #iabHandle.removeEventListener 'exit',handleExitBrowser
        iabHandle.removeEventListener 'hide',handleHideBrowser
        iabHandle.removeEventListener 'loadstart',handlerLoadStartEvent
        iabHandle.removeEventListener 'loadstop',handlerLoadStopEvent
        iabHandle.removeEventListener 'loaderror',handlerLoadErrorEvent
      window.iabHandle = window.open(url, '_blank', 'hidden=yes,toolbarposition=top')
      if Session.get('isReviewMode') isnt '1'
        iabHandle.addEventListener 'import',getURL
        iabHandle.addEventListener 'loadstart',handlerLoadStartEvent
        iabHandle.addEventListener 'loadstop',handlerLoadStopEvent
        iabHandle.addEventListener 'loaderror',handlerLoadErrorEvent

  @handleAddedLink = (url)->
    if iabHandle
      iabHandle.removeEventListener 'import',getURL
      #iabHandle.removeEventListener 'exit',handleExitBrowser
      iabHandle.removeEventListener 'hide',handleHideBrowser
    if url and url isnt ''
      window.iabHandle = window.open(url, '_blank', 'hidden=no,toolbarposition=top')
    else
      window.iabHandle = window.open('', '_blank', 'hidden=no,toolbarposition=top')
    if Session.get('isReviewMode') isnt '1'
      iabHandle.addEventListener 'import',getURL
      #iabHandle.addEventListener 'exit',handleExitBrowser
      iabHandle.addEventListener 'hide',handleHideBrowser
  Template.addPost.onDestroyed ()->
    Session.set('showContentInAddPost',false)
    $('.tool-container').remove();
    $(window).children().off();
    if gridster
      gridster.destroy()
      gridster = null
  @initGridster=()->
    base_size=Math.floor(getDisplayElementWidth()/6 - baseGap*2);
    test = $("#display");
    `gridster = test.gridster({serialize_params: function ($w, wgd) {
        return {
            id: wgd.el[0].id,
            col: wgd.col,
            row: wgd.row,
            size_x: wgd.size_x,
            size_y: wgd.size_y
        };
    }, widget_base_dimensions: [base_size, base_size],widget_margins: [baseGap, baseGap], min_cols: 3, max_cols:6, resize: {enabled: true, max_size: [9,9], min_size: [2, 2], start: function(e, ui, $widget) {

    }, stop: function(e, ui, $widget) {
        //$widget.actImageFitCover(e, ui, $widget);
        //console.log("stop width:"+ $widget.width())
        var scale = $widget.actImageFitCover('cropStyle');
        Drafts.update({_id: $widget.attr('id')}, {$set: {scale:scale}});
        return;
    }, resize: function(e, ui, $widget) {
        //$widget.actImageFitCover(e, ui, $widget);
        //console.log("resize width:"+ $widget.width())
        $widget.actImageFitCover('cropStyle');
    }
    }}).data('gridster');`
  window.imageCounter2 = 1
  # the only document I found here https://github.com/percolatestudio/transition-helper/blob/master/transition-helper.js#L4
  Template.addPost.onRendered ()->
    console.log(this.data);
    
    pub = this.data.pub;
    fromUrl = ''
    if this.fromUrl and this.fromUrl isnt ''
      fromUrl = this.fromUrl
    pub.push {_id: new Mongo.ObjectID()._str, type:'image', isImage:true, url: fromUrl, owner: this.data.owner, imgUrl:this.mainImage, filename:'', URI:"", data_row:0,style:this.mainImageStyle}
    deferedProcessAddPostItemsWithEditingProcessBar(pub)
    
    if Meteor.userId()
      Meteor.call('initReaderPopularPosts')

    if Session.get('itemInAddPostPending') > 0
      showEditingPopupProgressBar()
    Meteor.subscribe("saveddrafts");
    window.imageCounter2 = 1
    window.insertRow = 1
    `global_toolbar_hidden = false`
    $('.addPost').css('min-height',$(window).height())
    $('.addPost').css('width',$(window).width())
    title = document.getElementById("title")
    if title?
      $('#title').css("height", "auto");
      scrollHeight = title.scrollHeight;
      $('#title').css('height', scrollHeight)

    addontitle = document.getElementById("addontitle")
    if addontitle?
      $('#addontitle').css("height", "auto");
      scrollHeight = addontitle.scrollHeight
      $('#addontitle').css('height', scrollHeight);

    console.log 'addPost rendered rev=37'
    #testMenu will be main/font/align. It's for controlling the icon on text menu
    Session.set('textMenu','main')
    Session.set('textareaFocused', false)
    $('.addPost #ViewOnWeb').toolbar
      content: '#linkOption-toolbar-options'
      position: 'top'
      hideOnClick: true
      $('.addPost #ViewOnWeb').on 'toolbarItemClick',(event,buttonClicked)->
        if buttonClicked.id is "del"
          if Drafts.find({type:'image'}).count() > 0
            Drafts.update({_id:Drafts.find({type:'image'}).fetch()[0]._id},{$set:{url:''}})
    initGridster()
    #Set is isReviewMode
    console.log "rendered isReviewMode="+Session.get('isReviewMode')
    if Session.get('isReviewMode') is '1'
        if gridster?
          console.log "rendered: gridster.disable 2"
          gridster.disable()
          gridster.disable_resize()
        $("#title").attr("disabled", "disabled")
        $("#addontitle").attr("disabled", "disabled")
        `global_toolbar_hidden = true`
    else if Session.get('isReviewMode') is '2' or Session.get('isReviewMode') is '0'
        console.log "rendered: gridster.enable "
        if gridster?
          gridster.enable()
        $("#title").attr("disabled", false)
        $("#addontitle").attr('disabled',false)
        `global_toolbar_hidden = false`
    Session.set('showContentInAddPost',true)
    return
    
  publishPostHandle = ()->
    layout = JSON.stringify(gridster.serialize())
    pub=[]
    addontitle = $("#addontitle").val()
    title = $("#title").val()

    modalUserId = $('#chooseAssociatedUser .modal-body dt.active').attr('userId')
    ownerUser = null
    
    if modalUserId is Meteor.userId() or !modalUserId
      ownerUser = Meteor.user()
    else
      ownerUser = {
        _id: modalUserId
        username: $('#chooseAssociatedUser .modal-body dt.active').attr('userName')
        profile: {
          icon: $('#chooseAssociatedUser .modal-body dt.active').attr('userIcon')
          fullname: $('#chooseAssociatedUser .modal-body dt.active').attr('userName')
        }
      }
      
    Session.set 'post-publish-user-id', ownerUser._id
    ownerName = if ownerUser.profile and ownerUser.profile.fullname then ownerUser.profile.fullname else ownerUser.username
    ownerIcon = if ownerUser.profile and ownerUser.profile.icon then ownerUser.profile.icon else '/userPicture.png'

    # if modalUserId isnt undefined or modalUserId isnt null
    #   ownerUser = Meteor.users.findOne({_id: modalUserId})
    #   Session.set 'post-publish-user-id', modalUserId
    # if modalUserId is Meteor.userId()

    # if ownerUser is undefined or ownerUser is null
    #   ownerUser = Meteor.user()
    #   Session.set 'post-publish-user-id', ''

    # try
    #   #ownerIcon = Meteor.user().profile.icon
    #   ownerIcon = ownerUser.profile.icon
    # catch
    #   ownerIcon = '/userPicture.png'
    Session.set 'draftTitle',''
    Session.set 'draftAddontitle',''
    # console.log 'Full name is ' + Meteor.user().profile.fullname
    # #if Meteor.user().profile.fullname && (Meteor.user().profile.fullname isnt '')
    # #  ownerName = Meteor.user().profile.fullname
    # if ownerUser.profile.fullname && (ownerUser.profile.fullname isnt '')
    #   ownerName = ownerUser.profile.fullname
    # else
    #   #ownerName = Meteor.user().username
    #   ownerName = ownerUser.username

    draftData = Drafts.find().fetch()
    postId = draftData[0]._id;
    fromUrl = draftData[0].url;

    #Save gridster layout first. If publish failed, we can recover the drafts
    for i in [0..(draftData.length-1)]
      if i is 0
        mainImage = draftData[i].imgUrl
        mainImageStyle = draftData[i].style
        mainText = $("#"+draftData[i]._id+"text").val()
      else
  #for some case user did not save the draft, directly published, the layout does not stored.
        json = jQuery.parseJSON(layout);
        for item in json
          if item.id is draftData[i]._id
            draftData[i].data_row = item.row
            draftData[i].data_col = item.col
            draftData[i].data_sizex = item.size_x
            draftData[i].data_sizey = item.size_y
        pub.push(draftData[i])
    sortBy = (key, a, b, r) ->
      r = if r then 1 else -1
      return -1*r if a[key] and b[key] and a[key] > b[key]
      return +1*r if a[key] and b[key] and a[key] < b[key]
      return +1*r if a[key] is undefined and b[key]
      return -1*r if a[key] and b[key] is undefined
      return 0
    pub.sort((a, b)->
      sortBy('data_row', a, b)
    )
    if Session.get('isReviewMode') is '2' or Posts.find({_id:postId}).count()>0
      Posts.update(
        {
          _id:postId
        },
        {
          $set:{
            pub:pub,
            title:title,
            heart:[],  #点赞
            retweet:[],#转发
            comment:[], #评论
            addontitle:addontitle,
            mainImage: mainImage,
            mainImageStyle:mainImageStyle,
            mainText: mainText,
            fromUrl: fromUrl,
            publish:true,
            #owner:Meteor.userId(),
            owner:ownerUser._id,
            ownerName:ownerName,
            ownerIcon:ownerIcon,
            createdAt: new Date(),
            appEdited: true
          }
        }
      )
    else
      Posts.insert( {
        _id:postId,
        pub:pub,
        title:title,
        browse:0,
        heart:[],  #点赞
        retweet:[],#转发
        comment:[], #评论
        commentsCount:0,
        addontitle:addontitle,
        mainImage: mainImage,
        mainImageStyle:mainImageStyle,
        mainText: mainText,
        fromUrl: fromUrl,
        publish:true,
        #owner:Meteor.userId(),
        owner:ownerUser._id,
        ownerName:ownerName,
        ownerIcon:ownerIcon,
        createdAt: new Date(),
        appEdited: true
      })
    #Delete from SavedDrafts if it is a saved draft.
    if SavedDrafts.find().count() is 1
      Session.setPersistent('mySavedDraftsCount',0)
      Session.setPersistent('persistentMySavedDrafts',null)
    SavedDrafts.remove({_id:postId})
    #Delete the Drafts
    Drafts.remove({})
    TempDrafts.remove({})
    if Session.get('isReviewMode') is '2'
      Router.go('/posts/'+postId)
    else
      Session.set("TopicPostId", postId)
      Session.set("TopicTitle", title)
      Session.set("TopicAddonTitle", addontitle)
      Session.set("TopicMainImage", mainImage)
      Router.go('addTopicComment')
  Template.addPost.helpers
    showContent:->
      Session.get('showContentInAddPost')
    mainImage:->
      Drafts.findOne({type:'image'})
    isIOS:->
      if withMusicSharing
        isIOS
      else
        false
    progressBarWidth:->
      Session.get('importProcedure')
    displayUrl:->
      if Drafts.findOne({type:'image'}) and Drafts.findOne({type:'image'}).url and Drafts.findOne({type:'image'}).url isnt ''
        ""
      else
        "display:none"
    linkUrl:->
      if Drafts.find({type:'image'}).count() > 0
        Drafts.find({type:'image'}).fetch()[0].url
    cancelDraftChange:->
      if TempDrafts.find({}).count() is 0
        return
      TempDraftData = TempDrafts.find({}).fetch()[0]
      try
        if SavedDrafts.find({_id:TempDraftData._id}).count() > 0
          SavedDrafts.update(
            {_id:TempDraftData._id},
            {$set:{
              pub:TempDraftData.pub,
              title:TempDraftData.title,
              addontitle:TempDraftData.addontitle,
              mainImage: TempDraftData.mainImage,
              fromUrl: TempDraftData.fromUrl,
              mainText: TempDraftData.mainText,
              owner:TempDraftData.owner,
              createdAt: TempDraftData.createAt,
            }}
          )
        else
          SavedDrafts.insert {
            _id:TempDraftData._id,
            pub:TempDraftData.pub,
            title:TempDraftData.title,
            addontitle:TempDraftData.addontitle,
            fromUrl:TempDraftData.fromUrl,
            mainImage: TempDraftData.mainImage,
            mainText: TempDraftData.mainText,
            owner:TempDraftData.owner,
            createdAt: TempDraftData.createdAt,
          }
      catch error
        console.log("Insert SavedDrafts error! Try update it...");
        SavedDrafts.update(
          {_id:TempDraftData._id},
          {$set:{
            pub:TempDraftData.pub,
            title:TempDraftData.title,
            addontitle:TempDraftData.addontitle,
            fromUrl:TempDraftData.fromUrl,
            mainImage: TempDraftData.mainImage,
            mainText: TempDraftData.mainText,
            owner:TempDraftData.owner,
            createdAt: TempDraftData.createdAt,
          }}
        )
      TempDrafts.remove {owner: Meteor.userId()}
      return
    saveDraft:->
      handleSaveDraft()
    showPostFooter:->
      if Session.get('isReviewMode') is '2' or Session.get('isReviewMode') is '0'
        if Session.get('textareaFocused') is false
          console.log("showPostFooter true")
          true
        else
          console.log("showPostFooter false")
          false
      else
        console.log("showPostFooter false")
        false
    isReviewMode:(value)->
      console.log "value is "+value + ", isReviewMode = "+Session.get('isReviewMode')
      if Session.get('isReviewMode') is value
        if Session.get('isReviewMode') is '1' or Session.get('isReviewMode') is '3'
            if gridster?
              console.log "gridster.disable 2"
              gridster.disable()
              gridster.disable_resize()
            $("#title").attr("disabled", "disabled")
            $("#addontitle").attr("disabled", "disabled")
            `global_toolbar_hidden = true`
            true
        else if Session.get('isReviewMode') is '2' or Session.get('isReviewMode') is '0'
            console.log "gridster.enable "
            if gridster?
              gridster.enable()
              gridster.enable_resize()
            $("#title").attr("disabled", false)
            $("#addontitle").attr('disabled',false)
            `global_toolbar_hidden = false`
            true
      else
        false
    pub:()->
      if Drafts.find().count() > 1
        for i in [0..(Drafts.find({}).count()-1)]
          Drafts.find({}).fetch()[i]
    hasAssocaitedUsers: ()->
      AssociatedUsers.find({}).count() > 0          
  Template.addPost.events
    'click #ViewOnWeb' :->
      if Meteor.isCordova and Session.get('isReviewMode') is '1'
        if Drafts.find({type:'image'}).count() > 0
          url = Drafts.find({type:'image'}).fetch()[0].url
          if url and url isnt ''
            fromUrl = url
            handleAddedLink(fromUrl)
    'beUnSelected .resortitem': (e)->
      if window.footbarOppration
        window.unSelectedElem = e.currentTarget
        window.footbarOppration = false
      else
        window.unSelectedElem = undefined
    'focus [name=textareatitle]':->
      Session.set('textareaFocused', true)
      $(".head").css 'position','absolute'
    'blur [name=textareatitle]':->
      Session.set('textareaFocused', false)
      $(".head").css 'position','fixed'
    ###
    'paste [name=textarea]' : (e)-> 
      #Session.set('textareaPaste', true)
      currentData = e.currentTarget.value  
      console.log ("currentData:"+currentData)
      pastedData = e.originalEvent.clipboardData.getData('Text')
      console.log("textarea paste ："+pastedData)  
      totalData = currentData + pastedData
      paragraphArray = []
      paragraphArrayTmp = []
      paragraphArrayTmp = totalData.split('\n')
      if paragraphArrayTmp.length > 0
        for i in [0..paragraphArrayTmp.length-1]                
          unless (paragraphArrayTmp[i].length == 0 or paragraphArrayTmp[i] == ' ') 
            paragraphArray.push(paragraphArrayTmp[i])
      if paragraphArray.length > 0
        console.log("paragraphArray.length="+paragraphArray.length)
        for i in [0..paragraphArray.length-1]               
          console.log('paragraphArray['+i+']='+paragraphArray[i])
          if i == 0  
            e.currentTarget.value  = paragraphArray[i]
            Drafts.update({_id: this._id}, {$set: {text: paragraphArray[i]}})
            if paragraphArray.length>1
              $(e.currentTarget).blur()
              window.unSelectedElem = $('.resortitem[id = "' + this._id + '"]').get(0)
              console.log 'elemId'+this._id
              console.log 'window.unSelectedElem==='+window.unSelectedElem
          else
            Drafts.insert {type:'text', currentCount:i+1, totalCount:paragraphArray.length,isImage:false, owner: Meteor.userId(), text:paragraphArray[i], style:'', data_row:'1', data_col:'3',  data_sizex:'6', data_sizey:'1'}
      #Session.set('textareaPaste', false)
    ###
    'change [name=textarea]' : (e,cxt)->
      console.log("textarea change "+ e.currentTarget.value)
      Drafts.update({_id: this._id}, {$set: {text: e.currentTarget.value}});
    'click #addAudio': ()->
      if isIOS
        window.plugins.iOSAudioPicker.getAudio((list)->
          ###
          {
            "artist":"Carrie Underwood",
            "albumTitle":"Greatest Hits: Decade #1",
            "ipodurl":"ipod-library://item/item.m4a?id=8615795969436387427",
            "title":"Something in the Water",
            "image":"BASE64",
            "duration":238.059,
            "exportedurl":"file:///var/mobile/Containers/Data/Application/B84BB3DE-20DC-4FF2-AD62-1A8D47337214/Library/Something%20in%20the%20Water.m4a",
            "filename":"Something in the Water.m4a",
            "genre":"Country"
          }
          ###
          #console.log('Got list' + JSON.stringify(list))
          for item in list
            if item
              musicInfo = {}
              if item.image and item.image isnt ''
                console.log('has image')
                if item.exportedurl and  item.exportedurl isnt ''
                  originalFilename = item.exportedurl.replace(/^.*[\\\/]/, '')
                  musicInfo.playUrl = 'cdvfile://localhost/persistent/files/' + originalFilename
                  musicInfo.URI = item.exportedurl
                  musicInfo.filename = Meteor.userId()+'_'+new Date().getTime()+ '_' + MD5(originalFilename)+'.'+originalFilename.split('.').pop();
                  musicInfo.songName = item.title
                  musicInfo.singerName = item.artist
                  console.log('Image ')
                  window.imageResizer.resizeImage( (data)->
                      musicInfo.image = "data:image/png;base64," + data.imageData;
                      console.log('Got image data ' + musicInfo.image);
                      insertMusicInfo(musicInfo)
                    ,(error)->
                      console.log("Error : \r\n" + error);
                      insertMusicInfo(musicInfo)
                    ,item.image
                    ,64, 64, {imageDataType:ImageResizer.IMAGE_DATA_TYPE_BASE64,format:'png'});

        ,()->
          console.log('Got error')
        ,'false','true');
    'click #addLink': ()->
      console.log 'Add Link ' + Session.get('lastImportedUrl')
      cordova.plugins.clipboard.paste (text)->
        if text and text isnt '' and text.indexOf('http') > -1
          handleAddedLink(text)
        else
          handleAddedLink(Session.get('lastImportedUrl'))
    'click #takephoto': ()->
      if Drafts.find().count() > 0
        window.footbarOppration = true
        if window.takePhoto
          window.takePhoto (result)->
            console.log 'result from camera is ' + JSON.stringify(result)
            if result
              Drafts.insert {type:'image', currentCount:1, totalCount:1,isImage:true, owner: Meteor.userId(),imgUrl:result.smallImage, filename:result.filename, URI:result.URI, data_row:'1', data_col:'3', data_sizex:'3', data_sizey:'3'}

    'click #addmore':->
      window.footbarOppration = true
      #uploadFile (result)->
      Session.set 'draftTitle',''
      Session.set 'draftAddontitle',''
      Session.set('NewImgAdd','false')
      selectMediaFromAblum(20, (cancel, result,currentCount,totalCount)->
        if cancel
          if Drafts.find().count() is 0
            PUB.back()
          return
        if result
          console.log 'Current Count is ' + currentCount + ' Total is ' + totalCount
          console.log 'image url is ' + result.smallImage
          Drafts.insert {type:'image', currentCount:currentCount, totalCount:totalCount,isImage:true, owner: Meteor.userId(),imgUrl:result.smallImage, filename:result.filename, URI:result.URI, data_row:'1', data_col:'3', data_sizex:'3', data_sizey:'3'}
          if (currentCount >= totalCount)
            Meteor.setTimeout ()->
              Template.addPost.__helpers.get('saveDraft')()
            ,100
      )
      return
    'click #addText':->
      window.footbarOppration = true
      Drafts.insert {type:'text', isImage:false, owner: Meteor.userId(), text:'', style:'', data_row:'1', data_col:'3',  data_sizex:'6', data_sizey:'1'}
      return
    'click .back':(event)->
      if Session.get('isReviewMode') is '2'
        navigator.notification.confirm('这个操作无法撤销', (r)->
          console.log('r is ' + r)
          if r isnt 1
            return
          Session.set 'isReviewMode','1'
          #Delete it from SavedDrafts
          draftData = Drafts.find().fetch()
          if draftData[0] and draftData[0]._id
            draftId = draftData[0]._id
            SavedDrafts.remove draftId
          #Clear Drafts
          Drafts.remove {owner: Meteor.userId()}
          Session.set('fromDraftPost',false)
          $('.addPost').addClass('animated ' + animateOutUpperEffect);
          Meteor.setTimeout ()->
            PUB.back()
          ,animatePageTrasitionTimeout
          return
        , '您确定要放弃未保存的修改吗？', ['放弃修改','继续编辑']);
      else
        Drafts.remove {owner: Meteor.userId()}
        $('.addPost').addClass('animated ' + animateOutUpperEffect);
        Meteor.setTimeout ()->
          PUB.back()
        ,animatePageTrasitionTimeout
        return
    'click #edit':(event)->
      Session.set 'isReviewMode','0'
      return
    'click #delete':(event)->
      navigator.notification.confirm('您是否要删除草稿？', (r)->
        if r isnt 2
          return
        Session.set 'isReviewMode','1'
        #Delete it from SavedDrafts
        draftData = Drafts.find().fetch()
        draftId = draftData[0]._id
        if SavedDrafts.find().count() is 1
          Session.setPersistent('mySavedDraftsCount',0)
          Session.setPersistent('persistentMySavedDrafts',null)
        SavedDrafts.remove draftId
        #Clear Drafts
        draftImageData = Drafts.find({type:'image'}).fetch()
        removeImagesFromCache(draftImageData)
        Drafts.remove {owner: Meteor.userId()}
        $('.addPost').addClass('animated ' + animateOutUpperEffect);
        Meteor.setTimeout ()->
          PUB.back()
        ,animatePageTrasitionTimeout
        return
      , '删除草稿', ['取消','确定']);

      return
    'click .cancle':->
      if TempDrafts.find({}).count()>0
        navigator.notification.confirm('这个操作无法撤销', (r)->
          console.log('r is ' + r)
          if r isnt 1
            return
          Session.set 'isReviewMode','1'
          Template.addPost.__helpers.get('cancelDraftChange')()
          #Clear Drafts
          Drafts.remove {owner: Meteor.userId()}
          TempDrafts.remove {owner: Meteor.userId()}
          Session.set('fromDraftPost',false)
          $('.addPost').addClass('animated ' + animateOutUpperEffect);
          Meteor.setTimeout ()->
            Router.go('/')
          ,animatePageTrasitionTimeout
          return
        , '您确定要放弃未保存的修改吗？', ['放弃修改','继续编辑']);
      else
        navigator.notification.confirm('这个操作无法撤销', (r)->
          console.log('r is ' + r)
          if r isnt 1
            return
          Session.set 'isReviewMode','1'
          #Delete it from SavedDrafts
          draftData = Drafts.find().fetch()
          if draftData[0] and draftData[0]._id
            draftId = draftData[0]._id
            SavedDrafts.remove draftId
          #Clear Drafts
          draftImageData = Drafts.find({type:'image'}).fetch()
          removeImagesFromCache(draftImageData)
          Drafts.remove {owner: Meteor.userId()}
          $('.addPost').addClass('animated ' + animateOutUpperEffect);
          Meteor.setTimeout ()->
            Router.go('/')
          ,animatePageTrasitionTimeout
          return
        , '您确定要删除未保存的草稿吗？', ['删除故事','继续创作']);
    'click .cancleCrop':->
      $('#blur_overlay').css('height','')
      $('#blur_bottom').css('height','')
      $('#blur_left').css('height','')
      $('#blur_right').css('height','')
      cropDraftId = Session.get('cropDraftId')

      $('#isImage'+cropDraftId).css('display',"block")
      $('#'+cropDraftId).css('display',"block")
      $('#crop'+cropDraftId).css('display',"none")
      Meteor.setTimeout ()->
        document.getElementById('default'+cropDraftId).innerHTML=""
      ,120
      $('#'+cropDraftId).css('z-index',"2")
      if Posts.find({_id:Drafts.find().fetch()[0]._id}).count() > 0
        Session.set 'isReviewMode','2'
      else
        Session.set 'isReviewMode','0'
    'click #cropDone':->
      $('#blur_overlay').css('height','')
      $('#blur_bottom').css('height','')
      $('#blur_left').css('height','')
      $('#blur_right').css('height','')
      cropDraftId = Session.get('cropDraftId')

      console.log cropDraftId
      imgSize =
        w : Session.get 'imgSizeW'
        h : Session.get 'imgSizeH'
      imgRatio =
        wh : imgSize.w / imgSize.h
        hw : imgSize.h / imgSize.w
      imgZoomSize =
        w : $("#default"+cropDraftId+" .crop-img").width()
        h : $("#default"+cropDraftId+" .crop-img").height()
      holderSize =
        w : $("#default"+cropDraftId).width()
        h : $("#default"+cropDraftId).height()
      holderRatio =
        wh : $("#default"+cropDraftId).width() / $("#default"+cropDraftId).height()
        hw : $("#default"+cropDraftId).height() / $("#default"+cropDraftId).width()
      if imgZoomSize.w * holderRatio.hw < imgZoomSize.h * holderRatio.wh
        img_width = (imgZoomSize.w / imgSize.w)*100 + '%'
        img_height = (imgZoomSize.h / imgSize.h)*imgRatio.hw*holderRatio.wh*100 + '%'
      else
        img_width = (imgZoomSize.w / imgSize.w)*imgRatio.wh*holderRatio.hw*100 + '%'
        img_height = (imgZoomSize.h / imgSize.h)*100 + '%'
      imgMove =
        t : $("#default"+cropDraftId+" .crop-img").css('top')
        l : $("#default"+cropDraftId+" .crop-img").css('left')
      img_top = (parseFloat(imgMove.t) / holderSize.h)*100 + '%'
      img_left = (parseFloat(imgMove.l) / holderSize.w)*100 + '%'
      console.log "imgRatio is "+JSON.stringify(imgRatio)+"holderRatio is "+JSON.stringify(holderRatio)+"imgSize is "+JSON.stringify(imgSize)\
        +" imgZoomSize is "+JSON.stringify(imgZoomSize)+" holderSize is "+JSON.stringify(holderSize)+" imgMove is "+JSON.stringify(imgMove)+" img_top is "+img_top

      w1 = $("#default"+cropDraftId+" .crop-img").css('width')
      h1 = $("#default"+cropDraftId+" .crop-img").css('height')
      l1 = $("#default"+cropDraftId+" .crop-img").css('left')
      t1 = $("#default"+cropDraftId+" .crop-img").css('top')
      cw = $("#default"+cropDraftId).width()
      ch = $("#default"+cropDraftId).height()

      style2 = "height:" + h1 + ';width:' + w1 + ';top:' + t1 + ';left:' + l1 + ';h_width:' + cw + ';h_height:' + ch + ';'

      style = "height:" + img_height + ';width:' + img_width + ';top:' + img_top + ';left:' + img_left + ';'
      console.log style
      zoom = $("#default"+cropDraftId).find('input')
      Drafts.update({_id: cropDraftId}, {$set: {style: style, scale:zoom.val(), style2:style2}});
      #update the style to the other image, or else there is a photo move after crop done.
      imgs = $('#isImage'+cropDraftId).find('img')
      img = $(imgs[0])
      img.attr('style', 'width:100%; height:100%;position:absolute;'+style);
      $('#isImage'+cropDraftId).css('display',"block")
      $('#'+cropDraftId).css('display',"block")
      $('#crop'+cropDraftId).css('display',"none")
      Meteor.setTimeout ()->
        document.getElementById('default'+cropDraftId).innerHTML=""
      ,120
      $('#'+cropDraftId).css('z-index',"2")
      if Posts.find({_id:Drafts.find().fetch()[0]._id}).count() > 0
        Session.set 'isReviewMode','2'
      else
        Session.set 'isReviewMode','0'

    'click #saveDraft':->
      Template.addPost.__helpers.get('saveDraft')()
      Drafts.remove {owner: Meteor.userId()}
      TempDrafts.remove {owner: Meteor.userId()}
      if Session.get('fromDraftPost') is true
        Session.set('fromDraftPost',false)
        savedDraftData = SavedDrafts.findOne({_id: Session.get('postContent')._id})
        if withDirectDraftShow
          if savedDraftData and savedDraftData.pub and savedDraftData._id
            Session.set('postContent',savedDraftData)
            PUB.page('/draftposts/'+savedDraftData._id)
            return
          else
            toastr.error('got wrong')
            return
      else
        history.back()
      #PUB.back()


    'click #publish, click #modalPublish': (e)->
      Session.set('fromDraftPost',false)
      if Session.get('isReviewMode') is '0' and e.currentTarget.id is "publish" and Template.addPost.__helpers.get('hasAssocaitedUsers')()
        return

      Meteor.defer ()->
        $('.modal-backdrop.fade.in').remove()

      if Meteor.user() is null
        window.plugins.toast.showShortBottom('请登录后发表您的故事')
        Router.go('/user')
        false
      else
        if(!Meteor.status().connected and Meteor.status().status isnt 'connecting')
          Meteor.reconnect()
        
        title = $("#title").val()
        if title is '' or title is '[空标题]'
          $("#title").val('')
          window.plugins.toast.showShortBottom('请为您的故事加个标题')
          return
        #get the images to be uploaded
        draftImageData = Drafts.find({type:'image'}).fetch()
        draftMusicData = Drafts.find({type:'music'}).fetch()
        draftVideoData = Drafts.find({type:'video'}).fetch()
        draftToBeUploadedImageData = []
        for i in [0..(draftImageData.length-1)]
            if draftImageData[i].imgUrl is undefined or draftImageData[i].imgUrl.toLowerCase().indexOf("http://")>= 0 or draftImageData[i].imgUrl.toLowerCase().indexOf("https://")>= 0
                draftToBeUploadedImageData.unshift({})
                continue
            draftToBeUploadedImageData.push(draftImageData[i])
        for music in draftMusicData
          if music.musicInfo.playUrl.toLowerCase().indexOf("http://")>= 0 or music.musicInfo.playUrl.toLowerCase().indexOf("https://")>= 0
            draftToBeUploadedImageData.unshift({})
            continue
          draftToBeUploadedImageData.push(music)
        for video in draftVideoData
          if video.videoInfo.imageUrl.toLowerCase().indexOf("http://")>= 0 or video.videoInfo.imageUrl.toLowerCase().indexOf("https://")>= 0
            draftToBeUploadedImageData.unshift({})
            continue
          draftToBeUploadedImageData.push(video)
        #uploadFileWhenPublishInCordova(draftToBeUploadedImageData, postId)
        #Don't add addpost page into history
        Session.set('terminateUpload', false)
        if draftToBeUploadedImageData.length > 0
          multiThreadUploadFileWhenPublishInCordova(draftToBeUploadedImageData, null, (err, result)->
            unless result
              window.plugins.toast.showShortBottom('上传失败，请稍后重试')
              return
            if result.length < 1
              window.plugins.toast.showShortBottom('上传失败，请稍后重试')
              return
            for item in result
              if item.uploaded and item._id
                if item.type is 'image' and item.imgUrl
                  Drafts.update({_id: item._id}, {$set: {imgUrl:item.imgUrl}});
                else if item.type is 'music' and item.musicInfo and item.musicInfo.playUrl
                  Drafts.update({_id: item._id}, {$set: {"musicInfo.playUrl":item.musicInfo.playUrl}});
                else if item.type is 'video' and item.videoInfo and item.videoInfo.imageUrl
                  Drafts.update({_id: item._id}, {$set: {"videoInfo.imageUrl":item.videoInfo.imageUrl}});
            if err
              window.plugins.toast.showShortBottom('上传失败，请稍后重试')
              return
            publishPostHandle()
            removeImagesFromCache(draftImageData)
          )
        else
          publishPostHandle()
        return
    'click .remove':(event)->
      Drafts.remove this._id
    'click .imgContainer': (e)->
      if Session.get('isReviewMode') isnt '1'
        return
      swipedata = []
      selected = 0
      draftData = Drafts.find({type:'image'}).fetch()
      for i in [1..(draftData.length-1)]
        if draftData[i].imgUrl
          if draftData[i].imgUrl is this.imgUrl
            selected = i-1
          swipedata.push
            href: draftData[i].imgUrl
            title: draftData[i].text
      $.swipebox swipedata,{
        initialIndexOnArray: selected
        hideCloseButtonOnMobile : true
        loopAtEnd: false
      }
  Template.chooseAssociatedUser.onRendered ()->
    # userIds = []
    # AssociatedUsers.find({}).forEach((item)->
    #     if Meteor.userId() isnt item.userIdA and !~ userIds.indexOf(item.userIdA)
    #         userIds.push(item.userIdA)

    #     if Meteor.userId() isnt item.userIdB and !~ userIds.indexOf(item.userIdB)
    #         userIds.push(item.userIdB)
    # )
    
    # Meteor.subscribe('associateduserdetails', userIds)
    Meteor.subscribe('userRelation')

  Template.chooseAssociatedUser.helpers
    accountList :->
      # userIds = []
      # AssociatedUsers.find({}).forEach((item)->
      #     if Meteor.userId() isnt item.userIdA and !~ userIds.indexOf(item.userIdA)
      #         userIds.push(item.userIdA)

      #     if Meteor.userId() isnt item.userIdB and !~ userIds.indexOf(item.userIdB)
      #         userIds.push(item.userIdB)
      # )
      
      # return Meteor.users.find({_id: {'$in': userIds}})
      return UserRelation.find({userId: Meteor.userId()})

  Template.chooseAssociatedUser.events
    "click .modal-body dl": (e, t)->
      t.$("dt.active").removeClass("active")
      $(e.currentTarget).find("dt").addClass('active')