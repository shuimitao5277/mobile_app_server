if Meteor.isClient
  Template.discover.helpers
    hasDiscover: ()->
      withDiscover
  Template.moments.rendered=->
    $(window).scroll (event)->
        console.log "moments window scroll event: "+event
        target = $("#showMoreMomentsResults");
        MOMENTS_ITEMS_INCREMENT = 10;
        console.log "target.length: " + target.length
        if (!target.length)
            return;
        threshold = $(window).scrollTop() + $(window).height() - target.height();
        console.log "threshold: " + threshold
        console.log "target.top: " + target.offset().top
        if target.offset().top < threshold
            if (!target.data("visible"))
                target.data("visible", true);
                Session.set("momentsitemsLimit",
                Session.get("momentsitemsLimit") + MOMENTS_ITEMS_INCREMENT);
        else
            if (target.data("visible"))
                target.data("visible", false);
  Template.moments.helpers
    moments:->
      Moments.find({currentPostId:Session.get("postContent")._id})
    time_diff: (created)->
      GetTime0(new Date() - created)
    moreResults:->
      !(Moments.find({currentPostId:Session.get("postContent")._id}).count() < Session.get("momentsitemsLimit"))
    loading:->
      Session.equals('momentsCollection','loading')
    loadError:->
      Session.equals('momentsCollection','error')
      
