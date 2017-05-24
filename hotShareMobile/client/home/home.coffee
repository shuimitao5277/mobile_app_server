#space 2
if Meteor.isClient
  toNum = (a) ->
    if a is null or a is undefined or a is ''
      return
      
    c = a.split('.')
    num_place = [
      ''
      '0'
      '00'
      '000'
      '0000'
    ]
    r = num_place.reverse()
    i = 0
    while i < c.length
      len = c[i].length
      c[i] = r[len] + c[i]
      i++
    res = c.join('')
    res
  @checkNewVersion2 = ->
    if CHECK_UPDATE
      platform = if Blaze._globalHelpers.isIOS() then 'ios' else (if Blaze._globalHelpers.isAndroid() then 'android' else 'others')
      HTTP.get(version_host_url,(err,result)->
        if err
          console.log(err)
          return
        data = result.data
        console.log(data)
        currentVersion = version_of_build
        if platform is 'ios'
          stableVersion = data.stable_ios
          latestVersion = data.latest_ios
          stableRelease = data.stable_release_ios
          latestRelease = data.latest_release_ios
        if platform is 'android'
          stableVersion = data.stable_android
          latestVersion = data.latest_android
          stableRelease = data.stable_release_android
          latestRelease = data.latest_release_android
        window.localStorage.setItem('stableVersion',stableVersion)
        window.localStorage.setItem('latestVersion',latestVersion)
        if currentVersion < stableVersion
          # 强制升级
          navigator.notification.alert('建议升级到' + latestVersion+'\n主要更新'+stableRelease,goToUpdate,'您使用的故事贴版本太旧啦！', '立即升级')
        else if currentVersion < latestVersion
          # 推荐升级
          navigator.notification.confirm('故事贴 V' + latestVersion+' 已经发布\n主要更新: \n'+latestRelease, (index)->
            if index is 1
              goToUpdate()
          '有新版本', '立即升级,稍后再说')
      )
    else
      return
  @checkNewVersion = ->
    platform = if Blaze._globalHelpers.isIOS() then 'ios' else (if Blaze._globalHelpers.isAndroid() then 'android' else 'others')
    version = Versions.findOne({})
    if !window.localStorage.getItem("latestVersion")
      console.log 'no localStorage latestVersion.'
      window.localStorage.setItem("latestVersion", version_of_build)
    if version and version[platform]
      latestVersion = version[platform]
    else
      latestVersion = version_of_build
    _latestVersion = toNum(latestVersion) 
    _version_of_build = toNum(version_of_build)
    _localLatestVersion = toNum(window.localStorage.getItem("latestVersion"))
    
    if _latestVersion > _version_of_build and _latestVersion > _localLatestVersion
      # window.localStorage.setItem("latestVersion", latestVersion)
      console.log 'set latestVersionAlert true. '
      Session.set('latestVersionAlert', true)
    else
      Session.set('latestVersionAlert', false)

    if _latestVersion > _version_of_build
      console.log '有新版本：' + _latestVersion
      return true
    if _latestVersion <= _version_of_build
      console.log '当前版本已是最新版本！'
      return false
  @goToUpdate = ->
    if Blaze._globalHelpers.isIOS()
      cordova.InAppBrowser.open('https://itunes.apple.com/app/gu-shi-tie/id957024953', '_system')
    else
      cordova.InAppBrowser.open('http://a.app.qq.com/o/simple.jsp?pkgname=org.hotshare.everywhere', '_system')
  Template.home.helpers
    wasLogon:()->
      Session.get('persistentLoginStatus')
    isCordova:()->
      Meteor.isCordova
    isFirstLog:()->
      Session.get('isFlag');
  Template.home.events
    'click .top-series-btn': (event)->
       Router.go '/seriesList'
    'click #follow': (event)->
       Router.go '/searchFollow'
    'click .clickHelp':(event)->
      PUB.page '/help'
    'click .closebtn':()->
      $('.app-rate').fadeOut()
      promptForRatingWindowButtonClickHandler(2)
    'click .btn-rate1':()->
      $('.app-rate').fadeOut()
      promptForRatingWindowButtonClickHandler(3)
    'click .btn-rate2':()->
      $('.app-rate').fadeOut()
      promptForRatingWindowButtonClickHandler(3)
  Template.home.rendered=->
    flag = window.localStorage.getItem("firstLog") == 'first'
    Session.set('isFlag', !flag)
    checkNewVersion()

Tracker.autorun((t)->
  if Session.get('latestVersionAlert')
    t.stop()
    setTimeout(()->
      # Dialogs.alert('我们已为您备好更有趣新版本，记得去更新哦~', null, '新版本提示', '好的')
      navigator.notification.confirm(
          '我们已为您备好更有趣新版本，记得去更新哦~'
          (index)->
            if index is 2
              goToUpdate()
          '新版本提示'
          ['下次更新', '马上更新']
        )
    , 1000)
);
