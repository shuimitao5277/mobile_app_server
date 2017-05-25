Meteor.startup(function(){
    if(Versions.find().count() === 0){
      Versions.insert({
        ios: "0.8.61",
        android: "0.9.2"
      });
    }
    Meteor.defer(function(){
	    if(Moments.find().count() === 0){
	      try{
		var views=Viewers.find({},{sort:{createdAt: 1}});
		if(views.count()>0){
		  views.forEach(function(data){
		                //根据看过帖子的人的userId，找到看过的帖子
		                var viewposts=Viewers.find({userId:data.userId,postId:{$ne:data.postId}},{sort:{createdAt: 1}});
		                var currentpost = Posts.findOne(data.postId);
		                var userinfo = Meteor.users.findOne({_id: data.userId},{fields: {'username':1,'profile.fullname':1,'profile.icon':1, 'profile.anonymous':1}});
		                if(viewposts.count()>0 && currentpost && userinfo){
		                    viewposts.forEach(function(pdata){
		                        var readpost = Posts.findOne(pdata.postId);
		                        if(currentpost && readpost){
				                //1. 给当前帖子，增加所有看过的帖子
				                if(Moments.findOne({currentPostId:currentpost._id, readPostId:readpost._id})){
				                  Moments.update(
				                    {currentPostId:currentpost._id, readPostId:readpost._id},
				                    {$set:{
				                            currentPostId:currentpost._id,
				                            userId:data.userId,
				                            userIcon:userinfo.profile.icon,
				                            username:userinfo.profile.fullname? userinfo.profile.fullname: userinfo.username,
				                            readPostId:readpost._id,
				                            mainImage:readpost.mainImage,
				                            title:readpost.title,
				                            addontitle:readpost.addontitle,
				                            createdAt:pdata.createdAt
				                          }
				                    }
				                  );
				                }else{
				                  Moments.insert({
				                    currentPostId:currentpost._id,
				                    userId:data.userId,
				                    userIcon:userinfo.profile.icon,
				                    username:userinfo.profile.fullname? userinfo.profile.fullname: userinfo.username,
				                    readPostId:readpost._id,
				                    mainImage:readpost.mainImage,
				                    title:readpost.title,
				                    addontitle:readpost.addontitle,
				                    createdAt:pdata.createdAt
				                  });
				                }
				                //2. 给所有看过的帖子，增加当前帖子
				                if(Moments.findOne({currentPostId:readpost._id, readPostId:currentpost._id})){
				                  Moments.update(
				                    {currentPostId:readpost._id, readPostId:currentpost._id},
				                    {$set:{
				                            currentPostId:readpost._id,
				                            userId:data.userId,
				                            userIcon:userinfo.profile.icon,
				                            username:userinfo.profile.fullname? userinfo.profile.fullname: userinfo.username,
				                            readPostId:currentpost._id,
				                            mainImage:currentpost.mainImage,
				                            title:currentpost.title,
				                            addontitle:currentpost.addontitle,
				                            createdAt:new Date()
				                          }
				                    }
				                  );
				                }else{
				                  Moments.insert({
				                    currentPostId:readpost._id,
				                    userId:data.userId,
				                    userIcon:userinfo.profile.icon,
				                    username:userinfo.profile.fullname? userinfo.profile.fullname: userinfo.username,
				                    readPostId:currentpost._id,
				                    mainImage:currentpost.mainImage,
				                    title:currentpost.title,
				                    addontitle:currentpost.addontitle,
				                    createdAt:new Date()
				                  });
				                }
			                }
		                    });
		                }
		  });
		}
	      }catch(error){}
	    }
    });
    if(RefComments.find().count() === 0){
      RefComments.insert({
        text: "看贴回帖是一种美德",
        createdAt: new Date() // current time
      });
      RefComments.insert({
        text: "好贴，要顶",
        createdAt: new Date() // current time
      });
      RefComments.insert({
        text: "沙发",
        createdAt: new Date() // current time
      });
      RefComments.insert({
        text: "板凳",
        createdAt: new Date() // current time
      });
      RefComments.insert({
        text: "地板",
        createdAt: new Date() // current time
      });
      RefComments.insert({
        text: "看贴回帖是一种美德!",
        createdAt: new Date() // current time
      });
      RefComments.insert({
        text: "好贴，要顶!",
        createdAt: new Date() // current time
      });
      RefComments.insert({
        text: "沙发~~",
        createdAt: new Date() // current time
      });
      RefComments.insert({
        text: "板凳~~",
        createdAt: new Date() // current time
      });
      RefComments.insert({
        text: "地板~~",
        createdAt: new Date() // current time
      });
    }
//创建话题列表数据库
    var TopicsId = [];
    if(Topics.find().count() === 0){
        TopicsId[0] = Topics.insert({
            type:'theme',
            text:'精选',
            imgUrl:'/theme/theme1.jpg'
        });
        TopicsId[1] = Topics.insert({
            type:'theme',
            text:'大图片',
            imgUrl:'/theme/theme2.jpg'
        });
        TopicsId[2] = Topics.insert({
            type:'theme',
            text:'小故事',
            imgUrl:'/theme/theme3.jpg'
        });
        TopicsId[3] = Topics.insert({
            type:'theme',
            text:'去的地方',
            imgUrl:'/theme/theme4.jpg'
        });
        TopicsId[4] = Topics.insert({
            type:'theme',
            text:'了解最新信息',
            imgUrl:'/theme/theme5.jpg'
        });
        TopicsId[5] = Topics.insert({
            type:'topic',
            text:'人物',
            imgUrl:''
        });
        TopicsId[6] = Topics.insert({
            type:'topic',
            text:'奇闻',
            imgUrl:''
        });
        TopicsId[7] = Topics.insert({
            type:'topic',
            text:'自然',
            imgUrl:''
        });
        TopicsId[8] = Topics.insert({
            type:'topic',
            text:'情感',
            imgUrl:''
        });
        TopicsId[9] = Topics.insert({
            type:'topic',
            text:'旅游',
            imgUrl:''
        });
        TopicsId[10] = Topics.insert({
            type:'topic',
            text:'艺术',
            imgUrl:''
        });
        TopicsId[11] = Topics.insert({
            type:'topic',
            text:'民俗',
            imgUrl:''
        });
        TopicsId[12] = Topics.insert({
            type:'topic',
            text:'拓展',
            imgUrl:''
        });
        TopicsId[13] = Topics.insert({
            type:'topic',
            text:'娱乐',
            imgUrl:''
        });
        TopicsId[14] = Topics.insert({
            type:'topic',
            text:'时事',
            imgUrl:''
        });
    };
//创建Follows推荐列表数据库
//如果数据中没有记录，创建用户，然后加到推荐列表数据库Follows中
//这样可以加快拉出推荐列表的速度。
    if(Follows.find().count() === 0){
       var postId;
//创建公共粉丝用户，关注所有推荐用户，从公共粉丝用户的FollowPosts里提取推荐帖子，加快推荐帖子速度
        try{
            followeeId = Meteor.users.findOne({'username': 'suggestPosts' })._id;
        }
        catch(error)
        {
            //创建公共粉丝用户，关注所有推荐用户，从公共粉丝用户的FollowPosts里提取推荐帖子，加快推荐帖子速度
            followeeId = Accounts.createUser({
                username:'suggestPosts',
                password:'actiontec123',
                email:'suggestposts@ggmail.com',
                profile:{
                    icon:'/follows/icon1.png',
                    desc:"留下美好的瞬间！就看我的！",
                    fullname:'伊人'
                }
            });
        }
//创建偶像用户1
       followerId = Accounts.createUser({
           username:'Chase',
           password:'actiontec123',
           email:'ChaseJarvis@ggmail.com',
           profile:{
               icon:'/follows/icon1.png',
               desc:"留下美好的瞬间！就看我的！",
               fullname:'伊人'
           }
       });
       Follower.insert({
           userId: followeeId,
           followerId: followerId,
           createAt: new Date()
       });
//加入偶像推荐列表
       Follows.insert({
           icon:'/follows/icon1.png',
           userId:followerId,
           username:'Chase',
           fullname:'伊人',
           desc:"留下美好的瞬间！就看我的！",
           share1:'/follows/11.jpg',
           share2:'/follows/12.jpg',
           share3:'/follows/13.jpg',
           index:1
       });
//加偶像的3个Post
       postId = Posts.insert({
          pub: [{_id:'1',isImage:true,imgUrl:'http://www.ss750.cn/follows/112.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'2',isImage:false,text:'秋水共长天一色',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'3',isImage:true,imgUrl:'http://www.ss750.cn/follows/113.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'4',isImage:false,text:'夕阳无限好',data_row:10,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'5',isImage:true,imgUrl:'http://www.ss750.cn/follows/114.jpg',data_row:11,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'6',isImage:false,text:'只是近黄昏',data_row:15,data_col:1,data_sizex:6,data_sizey:1}],
          title:'落霞与孤鹜齐飞',
          addontitle:'秋水共长天一色',
          mainImage: 'http://www.ss750.cn/follows/111.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'伊人',
          ownerIcon:'/follows/icon1.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'落霞与孤鹜齐飞',
            addontitle:'秋水共长天一色',
            mainImage: 'http://www.ss750.cn/follows/111.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'伊人',
            ownerIcon:'/follows/icon1.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'落霞与孤鹜齐飞',
          addontitle:'秋水共长天一色',
          mainImage: 'http://www.ss750.cn/follows/111.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'伊人',
          ownerIcon:'/follows/icon1.png',
          createdAt: new Date(),
          topicId: TopicsId[0]
       });
       TopicPosts.insert({
          postId:postId,
          title:'落霞与孤鹜齐飞',
          addontitle:'秋水共长天一色',
          mainImage: 'http://www.ss750.cn/follows/111.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'伊人',
          ownerIcon:'/follows/icon1.png',
          createdAt: new Date(),
          topicId: TopicsId[1]
       });
       TopicPosts.insert({
          postId:postId,
          title:'落霞与孤鹜齐飞',
          addontitle:'秋水共长天一色',
          mainImage: 'http://www.ss750.cn/follows/111.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'伊人',
          ownerIcon:'/follows/icon1.png',
          createdAt: new Date(),
          topicId: TopicsId[7]
       });
       TopicPosts.insert({
          postId:postId,
          title:'落霞与孤鹜齐飞',
          addontitle:'秋水共长天一色',
          mainImage: 'http://www.ss750.cn/follows/111.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'伊人',
          ownerIcon:'/follows/icon1.png',
          createdAt: new Date(),
          topicId: TopicsId[9]
       });
       postId = Posts.insert({
          pub: [{_id:'7',isImage:true,imgUrl:'http://www.ss750.cn/follows/122.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'8',isImage:false,text:'心里开出一朵花',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'9',isImage:true,imgUrl:'http://www.ss750.cn/follows/123.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'10',isImage:false,text:'爱让我们相恋',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'因为爱情',
          addontitle:'义无反顾',
          mainImage: 'http://www.ss750.cn/follows/121.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'伊人',
          ownerIcon:'/follows/icon1.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'因为爱情',
            addontitle:'义无反顾',
            mainImage: 'http://www.ss750.cn/follows/121.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'伊人',
            ownerIcon:'/follows/icon1.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'因为爱情',
          addontitle:'义无反顾',
          mainImage: 'http://www.ss750.cn/follows/121.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'伊人',
          ownerIcon:'/follows/icon1.png',
          createdAt: new Date(),
          topicId: TopicsId[2]
       });
       TopicPosts.insert({
          postId:postId,
          title:'因为爱情',
          addontitle:'义无反顾',
          mainImage: 'http://www.ss750.cn/follows/121.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'伊人',
          ownerIcon:'/follows/icon1.png',
          createdAt: new Date(),
          topicId: TopicsId[8]
       });
       postId = Posts.insert({
          pub: [{_id:'11',isImage:true,imgUrl:'http://www.ss750.cn/follows/132.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'12',isImage:false,text:'曾经我们手牵着手',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'13',isImage:true,imgUrl:'http://www.ss750.cn/follows/133.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'14',isImage:false,text:'你说要我等你回来',data_row:10,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'15',isImage:true,imgUrl:'http://www.ss750.cn/follows/134.jpg',data_row:11,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'16',isImage:false,text:'亲爱的，你在哪里',data_row:15,data_col:1,data_sizex:6,data_sizey:1}],
          title:'十年',
          addontitle:'我等得花儿都谢了',
          mainImage: 'http://www.ss750.cn/follows/131.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'伊人',
          ownerIcon:'/follows/icon1.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'十年',
            addontitle:'我等得花儿都谢了',
            mainImage: 'http://www.ss750.cn/follows/131.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'伊人',
            ownerIcon:'/follows/icon1.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'十年',
          addontitle:'我等得花儿都谢了',
          mainImage: 'http://www.ss750.cn/follows/131.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'伊人',
          ownerIcon:'/follows/icon1.png',
          createdAt: new Date(),
          topicId: TopicsId[2]
       });
       TopicPosts.insert({
          postId:postId,
          title:'十年',
          addontitle:'我等得花儿都谢了',
          mainImage: 'http://www.ss750.cn/follows/131.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'伊人',
          ownerIcon:'/follows/icon1.png',
          createdAt: new Date(),
          topicId: TopicsId[8]
       });
//创建偶像用户2
       followerId = Accounts.createUser({
           username:'Rocco',
           password:'actiontec123',
           email:'RoccoDispirito@ggmail.com',
           profile:{
               icon:'/follows/icon2.png',
               desc:"喜欢上了摄影，于是改变了自己的生活。",
               fullname:'文亭'
           }
       });
       Follower.insert({
            userId: followeeId,
            followerId: followerId,
            createAt: new Date()
       });
       Follows.insert({
           icon:'/follows/icon2.png',
           userId:followerId,
           username:'Rocco',
           fullname:'文亭',
           desc:"喜欢上了摄影，于是改变了自己的生活。",
           share1:'/follows/21.jpg',
           share2:'/follows/22.jpg',
           share3:'/follows/23.jpg',
           index:2
       });
       postId = Posts.insert({
          pub: [{_id:'17',isImage:true,imgUrl:'http://www.ss750.cn/follows/212.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'18',isImage:false,text:'冬日原野',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'19',isImage:true,imgUrl:'http://www.ss750.cn/follows/213.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'20',isImage:false,text:'星星之火',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'冬季',
          addontitle:'我想大约会是在冬季',
          mainImage: 'http://www.ss750.cn/follows/211.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'文亭',
          ownerIcon:'/follows/icon2.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'冬季',
            addontitle:'我想大约会是在冬季',
            mainImage: 'http://www.ss750.cn/follows/211.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'文亭',
            ownerIcon:'/follows/icon2.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'冬季',
          addontitle:'我想大约会是在冬季',
          mainImage: 'http://www.ss750.cn/follows/211.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'文亭',
          ownerIcon:'/follows/icon2.png',
          createdAt: new Date(),
          topicId: TopicsId[3]
       });
       TopicPosts.insert({
          postId:postId,
          title:'冬季',
          addontitle:'我想大约会是在冬季',
          mainImage: 'http://www.ss750.cn/follows/211.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'文亭',
          ownerIcon:'/follows/icon2.png',
          createdAt: new Date(),
          topicId: TopicsId[7]
       });
       postId = Posts.insert({
          pub: [{_id:'21',isImage:true,imgUrl:'http://www.ss750.cn/follows/222.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'22',isImage:false,text:'卢浮魅影',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'23',isImage:true,imgUrl:'http://www.ss750.cn/follows/223.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'24',isImage:false,text:'蒙娜丽莎的微笑',data_row:10,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'25',isImage:true,imgUrl:'http://www.ss750.cn/follows/224.jpg',data_row:11,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'26',isImage:false,text:'罗马，罗马',data_row:15,data_col:1,data_sizex:6,data_sizey:1}],
          title:'欧罗巴剪影',
          addontitle:'阿尔卑斯山',
          mainImage: 'http://www.ss750.cn/follows/221.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'文亭',
          ownerIcon:'/follows/icon2.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'欧罗巴剪影',
            addontitle:'阿尔卑斯山',
            mainImage: 'http://www.ss750.cn/follows/221.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'文亭',
            ownerIcon:'/follows/icon2.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'欧罗巴剪影',
          addontitle:'阿尔卑斯山',
          mainImage: 'http://www.ss750.cn/follows/221.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'文亭',
          ownerIcon:'/follows/icon2.png',
          createdAt: new Date(),
          topicId: TopicsId[9]
       });
       TopicPosts.insert({
          postId:postId,
          title:'欧罗巴剪影',
          addontitle:'阿尔卑斯山',
          mainImage: 'http://www.ss750.cn/follows/221.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'文亭',
          ownerIcon:'/follows/icon2.png',
          createdAt: new Date(),
          topicId: TopicsId[12]
       });
       TopicPosts.insert({
          postId:postId,
          title:'欧罗巴剪影',
          addontitle:'阿尔卑斯山',
          mainImage: 'http://www.ss750.cn/follows/221.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'文亭',
          ownerIcon:'/follows/icon2.png',
          createdAt: new Date(),
          topicId: TopicsId[10]
       });
       postId = Posts.insert({
          pub: [{_id:'27',isImage:true,imgUrl:'http://www.ss750.cn/follows/232.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'28',isImage:false,text:'无论在冰天雪地',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'29',isImage:true,imgUrl:'http://www.ss750.cn/follows/233.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'30',isImage:false,text:'还是明朗天空',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'我一直在等待',
          addontitle:'一个女孩',
          mainImage: 'http://www.ss750.cn/follows/231.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'文亭',
          ownerIcon:'/follows/icon2.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'我一直在等待',
            addontitle:'一个女孩',
            mainImage: 'http://www.ss750.cn/follows/231.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'文亭',
            ownerIcon:'/follows/icon2.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'我一直在等待',
          addontitle:'一个女孩',
          mainImage: 'http://www.ss750.cn/follows/231.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'文亭',
          ownerIcon:'/follows/icon2.png',
          createdAt: new Date(),
          topicId: TopicsId[2]
       });
       TopicPosts.insert({
          postId:postId,
          title:'我一直在等待',
          addontitle:'一个女孩',
          mainImage: 'http://www.ss750.cn/follows/231.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'文亭',
          ownerIcon:'/follows/icon2.png',
          createdAt: new Date(),
          topicId: TopicsId[8]
       });
//创建偶像用户3
       followerId = Accounts.createUser({
           username:'Matt',
           password:'actiontec123',
           email:'MattCrump@ggmail.com',
           profile:{
               icon:'/follows/icon3.png',
               desc:"在感受中－－拍摄； 在拍摄中----感悟------",
               fullname:'秋雨梧桐'
           }
       });
       Follower.insert({
            userId: followeeId,
            followerId: followerId,
            createAt: new Date()
       });
       Follows.insert({
           icon:'/follows/icon3.png',
           userId:followerId,
           username:'Matt',
           fullname:'秋雨梧桐',
           desc:"在感受中－－拍摄； 在拍摄中----感悟------",
           share1:'/follows/31.jpg',
           share2:'/follows/32.jpg',
           share3:'/follows/33.jpg',
           index:3
       });
       postId = Posts.insert({
          pub: [{_id:'31',isImage:true,imgUrl:'http://www.ss750.cn/follows/312.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'32',isImage:false,text:"街上",data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'33',isImage:true,imgUrl:'http://www.ss750.cn/follows/313.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'34',isImage:false,text:'红叶',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'芝加哥游记',
          addontitle:'从Willis塔俯瞰',
          mainImage: 'http://www.ss750.cn/follows/311.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'秋雨梧桐',
          ownerIcon:'/follows/icon3.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'芝加哥游记',
            addontitle:'从Willis塔俯瞰',
            mainImage: 'http://www.ss750.cn/follows/311.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'秋雨梧桐',
            ownerIcon:'/follows/icon3.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'芝加哥游记',
          addontitle:'从Willis塔俯瞰',
          mainImage: 'http://www.ss750.cn/follows/311.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'秋雨梧桐',
          ownerIcon:'/follows/icon3.png',
          createdAt: new Date(),
          topicId: TopicsId[3]
       });
       TopicPosts.insert({
          postId:postId,
          title:'芝加哥游记',
          addontitle:'从Willis塔俯瞰',
          mainImage: 'http://www.ss750.cn/follows/311.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'秋雨梧桐',
          ownerIcon:'/follows/icon3.png',
          createdAt: new Date(),
          topicId: TopicsId[9]
       });
       postId = Posts.insert({
          pub: [{_id:'35',isImage:true,imgUrl:'http://www.ss750.cn/follows/322.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'36',isImage:false,text:'街景',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'37',isImage:true,imgUrl:'http://www.ss750.cn/follows/323.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'38',isImage:false,text:'九曲花街',data_row:10,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'39',isImage:true,imgUrl:'http://www.ss750.cn/follows/324.jpg',data_row:11,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'40',isImage:false,text:'渔人码头',data_row:15,data_col:1,data_sizex:6,data_sizey:1}],
          title:'三番——随走随拍',
          addontitle:'酒庄',
          mainImage: 'http://www.ss750.cn/follows/321.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'秋雨梧桐',
          ownerIcon:'/follows/icon3.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'三番——随走随拍',
            addontitle:'酒庄',
            mainImage: 'http://www.ss750.cn/follows/321.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'秋雨梧桐',
            ownerIcon:'/follows/icon3.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'三番——随走随拍',
          addontitle:'酒庄',
          mainImage: 'http://www.ss750.cn/follows/321.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'秋雨梧桐',
          ownerIcon:'/follows/icon3.png',
          createdAt: new Date(),
          topicId: TopicsId[3]
       });
       TopicPosts.insert({
          postId:postId,
          title:'三番——随走随拍',
          addontitle:'酒庄',
          mainImage: 'http://www.ss750.cn/follows/321.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'秋雨梧桐',
          ownerIcon:'/follows/icon3.png',
          createdAt: new Date(),
          topicId: TopicsId[9]
       });
       postId = Posts.insert({
          pub: [{_id:'41',isImage:true,imgUrl:'http://www.ss750.cn/follows/332.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'42',isImage:false,text:'怎么可能喜欢孤独，不过是不乱交朋友罢了',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'43',isImage:true,imgUrl:'http://www.ss750.cn/follows/333.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'44',isImage:false,text:'一个人也很好',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'孤独的人',
          addontitle:'是可耻的',
          mainImage: 'http://www.ss750.cn/follows/331.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'秋雨梧桐',
          ownerIcon:'/follows/icon3.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'孤独的人',
            addontitle:'是可耻的',
            mainImage: 'http://www.ss750.cn/follows/331.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'秋雨梧桐',
            ownerIcon:'/follows/icon3.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'孤独的人',
          addontitle:'是可耻的',
          mainImage: 'http://www.ss750.cn/follows/331.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'秋雨梧桐',
          ownerIcon:'/follows/icon3.png',
          createdAt: new Date(),
          topicId: TopicsId[5]
       });
       TopicPosts.insert({
          postId:postId,
          title:'孤独的人',
          addontitle:'是可耻的',
          mainImage: 'http://www.ss750.cn/follows/331.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'秋雨梧桐',
          ownerIcon:'/follows/icon3.png',
          createdAt: new Date(),
          topicId: TopicsId[6]
       });
//创建偶像用户4
       followerId = Accounts.createUser({
           username:'Veronica',
           password:'actiontec123',
           email:'VeronicaBelmont@ggmail.com',
           profile:{
               icon:'/follows/icon4.png',
               desc:"用第三只眼睛看这五彩的世界.",
               fullname:'赋闲的快门'
           }
       });
       Follower.insert({
            userId: followeeId,
            followerId: followerId,
            createAt: new Date()
       });
       Follows.insert({
           icon:'/follows/icon4.png',
           userId:followerId,
           username:'Veronica',
           fullname:'赋闲的快门',
           desc:"用第三只眼睛看这五彩的世界.",
           share1:'/follows/41.jpg',
           share2:'/follows/42.jpg',
           share3:'/follows/43.jpg',
           index:4
       });
       postId = Posts.insert({
          pub: [{_id:'45',isImage:true,imgUrl:'http://www.ss750.cn/follows/412.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'46',isImage:false,text:"不别惊慌",data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'47',isImage:true,imgUrl:'http://www.ss750.cn/follows/413.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'48',isImage:false,text:'美丽总在风浪后',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'冲浪',
          addontitle:'只需一个滑板',
          mainImage: 'http://www.ss750.cn/follows/411.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'赋闲的快门',
          ownerIcon:'/follows/icon4.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'冲浪',
            addontitle:'只需一个滑板',
            mainImage: 'http://www.ss750.cn/follows/411.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'赋闲的快门',
            ownerIcon:'/follows/icon4.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'冲浪',
          addontitle:'只需一个滑板',
          mainImage: 'http://www.ss750.cn/follows/411.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'赋闲的快门',
          ownerIcon:'/follows/icon4.png',
          createdAt: new Date(),
          topicId: TopicsId[11]
       });
       TopicPosts.insert({
          postId:postId,
          title:'冲浪',
          addontitle:'只需一个滑板',
          mainImage: 'http://www.ss750.cn/follows/411.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'赋闲的快门',
          ownerIcon:'/follows/icon4.png',
          createdAt: new Date(),
          topicId: TopicsId[13]
       });
       postId = Posts.insert({
          pub: [{_id:'49',isImage:true,imgUrl:'http://www.ss750.cn/follows/422.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'50',isImage:false,text:'有纯真的时光',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'51',isImage:true,imgUrl:'http://www.ss750.cn/follows/423.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'52',isImage:false,text:'像个秘密藏在我的心上',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'有一个地方',
          addontitle:'只有我知道',
          mainImage: 'http://www.ss750.cn/follows/421.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'赋闲的快门',
          ownerIcon:'/follows/icon4.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'有一个地方',
            addontitle:'只有我知道',
            mainImage: 'http://www.ss750.cn/follows/421.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'赋闲的快门',
            ownerIcon:'/follows/icon4.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'有一个地方',
          addontitle:'只有我知道',
          mainImage: 'http://www.ss750.cn/follows/421.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'赋闲的快门',
          ownerIcon:'/follows/icon4.png',
          createdAt: new Date(),
          topicId: TopicsId[4]
       });
       TopicPosts.insert({
          postId:postId,
          title:'有一个地方',
          addontitle:'只有我知道',
          mainImage: 'http://www.ss750.cn/follows/421.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'赋闲的快门',
          ownerIcon:'/follows/icon4.png',
          createdAt: new Date(),
          topicId: TopicsId[14]
       });
       postId = Posts.insert({
          pub: [{_id:'53',isImage:true,imgUrl:'http://www.ss750.cn/follows/432.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'54',isImage:false,text:'华丽的女人',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'55',isImage:true,imgUrl:'http://www.ss750.cn/follows/433.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'56',isImage:false,text:'精彩的时间',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'美丽的夜晚',
          addontitle:'美丽的世界',
          mainImage: 'http://www.ss750.cn/follows/431.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'赋闲的快门',
          ownerIcon:'/follows/icon4.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'美丽的夜晚',
            addontitle:'美丽的世界',
            mainImage: 'http://www.ss750.cn/follows/431.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'赋闲的快门',
            ownerIcon:'/follows/icon4.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'美丽的夜晚',
          addontitle:'美丽的世界',
          mainImage: 'http://www.ss750.cn/follows/431.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'赋闲的快门',
          ownerIcon:'/follows/icon4.png',
          createdAt: new Date(),
          topicId: TopicsId[0]
       });
       TopicPosts.insert({
          postId:postId,
          title:'美丽的夜晚',
          addontitle:'美丽的世界',
          mainImage: 'http://www.ss750.cn/follows/431.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'赋闲的快门',
          ownerIcon:'/follows/icon4.png',
          createdAt: new Date(),
          topicId: TopicsId[5]
       });
//创建偶像用户5
       followerId = Accounts.createUser({
           username:'Philip',
           password:'actiontec123',
           email:'PhilipBloom@ggmail.com',
           profile:{
               icon:'/follows/icon5.png',
               desc:"用心灵感受，用镜头记忆！",
               fullname:'银羽飞舞'
           }
       });
       Follower.insert({
            userId: followeeId,
            followerId: followerId,
            createAt: new Date()
       });
       Follows.insert({
           icon:'/follows/icon5.png',
           userId:followerId,
           username:'Philip',
           fullname:'银羽飞舞',
           desc:"用心灵感受，用镜头记忆！",
           share1:'/follows/51.jpg',
           share2:'/follows/52.jpg',
           share3:'/follows/53.jpg',
           index:5
       });
       postId = Posts.insert({
          pub: [{_id:'57',isImage:true,imgUrl:'http://www.ss750.cn/follows/512.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'58',isImage:false,text:'是森林深处满目的萤火虫',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'59',isImage:true,imgUrl:'http://www.ss750.cn/follows/513.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'60',isImage:false,text:'还是天涯海角的云雾缭绕',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'天堂',
          addontitle:'在哪里',
          mainImage: 'http://www.ss750.cn/follows/511.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'银羽飞舞',
          ownerIcon:'/follows/icon5.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'天堂',
            addontitle:'在哪里',
            mainImage: 'http://www.ss750.cn/follows/511.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'银羽飞舞',
            ownerIcon:'/follows/icon5.png',
            createdAt: new Date(),
            followby: followeeId
       });
       TopicPosts.insert({
          postId:postId,
          title:'天堂',
          addontitle:'在哪里',
          mainImage: 'http://www.ss750.cn/follows/511.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'银羽飞舞',
          ownerIcon:'/follows/icon5.png',
          createdAt: new Date(),
          topicId: TopicsId[1]
       });
       TopicPosts.insert({
          postId:postId,
          title:'天堂',
          addontitle:'在哪里',
          mainImage: 'http://www.ss750.cn/follows/511.jpg',
          heart:0,
          retweet:0,
          comment:0,
          owner:followerId,
          ownerName:'银羽飞舞',
          ownerIcon:'/follows/icon5.png',
          createdAt: new Date(),
          topicId: TopicsId[6]
       });
       postId = Posts.insert({
          pub: [{_id:'61',isImage:true,imgUrl:'http://www.ss750.cn/follows/522.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'62',isImage:false,text:'是含笑遮面',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'63',isImage:true,imgUrl:'http://www.ss750.cn/follows/523.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'64',isImage:false,text:'还是直直地看着我',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'天使',
          addontitle:'你的样子',
          mainImage: 'http://www.ss750.cn/follows/521.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'银羽飞舞',
          ownerIcon:'/follows/icon5.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'天使',
            addontitle:'你的样子',
            mainImage: 'http://www.ss750.cn/follows/521.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'银羽飞舞',
            ownerIcon:'/follows/icon5.png',
            createdAt: new Date(),
            followby: followeeId
       });
       postId = Posts.insert({
          pub: [{_id:'65',isImage:true,imgUrl:'http://www.ss750.cn/follows/532.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'66',isImage:false,text:'思念',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'67',isImage:true,imgUrl:'http://www.ss750.cn/follows/533.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'68',isImage:false,text:'向往',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'爱多深',
          addontitle:'笔记本',
          mainImage: 'http://www.ss750.cn/follows/531.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'银羽飞舞',
          ownerIcon:'/follows/icon5.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'爱多深',
            addontitle:'笔记本',
            mainImage: 'http://www.ss750.cn/follows/531.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'银羽飞舞',
            ownerIcon:'/follows/icon5.png',
            createdAt: new Date(),
            followby: followeeId
       });
//创建偶像用户6
       followerId = Accounts.createUser({
           username:'Doug',
           password:'actiontec123',
           email:'DougMenuez@ggmail.com',
           profile:{
               icon:'/follows/icon6.png',
               desc:"光影魅力无限 实话实说是我的个性 不断追求突破自我就是进步！",
               fullname:'天高神远'
           }
       });
        Follower.insert({
            userId: followeeId,
            followerId: followerId,
            createAt: new Date()
        });
       Follows.insert({
           icon:'/follows/icon6.png',
           userId:followerId,
           username:'Doug',
           fullname:'天高神远',
           desc:"光影魅力无限 实话实说是我的个性 不断追求突破自我就是进步！",
           share1:'/follows/61.jpg',
           share2:'/follows/62.jpg',
           share3:'/follows/63.jpg',
           index:6
       });
       postId = Posts.insert({
          pub: [{_id:'69',isImage:true,imgUrl:'http://www.ss750.cn/follows/612.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'70',isImage:false,text:'一瞬间',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'71',isImage:true,imgUrl:'http://www.ss750.cn/follows/613.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'72',isImage:false,text:'有没有',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'怦然',
          addontitle:'心动',
          mainImage: 'http://www.ss750.cn/follows/611.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'天高神远',
          ownerIcon:'/follows/icon6.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'怦然',
            addontitle:'心动',
            mainImage: 'http://www.ss750.cn/follows/611.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'天高神远',
            ownerIcon:'/follows/icon6.png',
            createdAt: new Date(),
            followby: followeeId
       });
       postId = Posts.insert({
          pub: [{_id:'73',isImage:true,imgUrl:'http://www.ss750.cn/follows/622.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'74',isImage:false,text:'Minerva这个名字来自罗马的知识，魔法，医药，商业和防御女神',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'75',isImage:true,imgUrl:'http://www.ss750.cn/follows/623.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'76',isImage:false,text:'三个女神发现了这个苹果，让特洛伊王子Paris选择谁是最美的',data_row:10,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'77',isImage:true,imgUrl:'http://www.ss750.cn/follows/624.jpg',data_row:11,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'78',isImage:false,text:'Phrygia人的帽子',data_row:15,data_col:1,data_sizex:6,data_sizey:1}],
          title:'辛黛瑞拉',
          addontitle:'希腊神话与艺术作品',
          mainImage: 'http://www.ss750.cn/follows/621.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'天高神远',
          ownerIcon:'/follows/icon6.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'辛黛瑞拉',
            addontitle:'希腊神话与艺术作品',
            mainImage: 'http://www.ss750.cn/follows/621.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'天高神远',
            ownerIcon:'/follows/icon6.png',
            createdAt: new Date(),
            followby: followeeId
       });
       postId = Posts.insert({
          pub: [{_id:'79',isImage:true,imgUrl:'http://www.ss750.cn/follows/632.jpg',data_row:1,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'80',isImage:false,text:'霍拉提雅克路易·大卫',data_row:5,data_col:1,data_sizex:6,data_sizey:1},
                {_id:'81',isImage:true,imgUrl:'http://www.ss750.cn/follows/633.jpg',data_row:6,data_col:1,data_sizex:6,data_sizey:4},
                {_id:'82',isImage:false,text:'卡比托利欧博物馆',data_row:10,data_col:1,data_sizex:6,data_sizey:1}],
          title:'埃涅阿斯',
          addontitle:'关于特洛伊的画和雕塑',
          mainImage: 'http://www.ss750.cn/follows/631.jpg',
          heart:[],  
          retweet:[],
          comment:[],
          owner:followerId,
          ownerName:'天高神远',
          ownerIcon:'/follows/icon6.png',
          createdAt: new Date()
       });
       FollowPosts.insert({
            postId:postId,
            title:'埃涅阿斯',
            addontitle:'关于特洛伊的画和雕塑',
            mainImage: 'http://www.ss750.cn/follows/631.jpg',
            heart:0,
            retweet:0,
            comment:0,
            browse:0,
            owner:followerId,
            ownerName:'天高神远',
            ownerIcon:'/follows/icon6.png',
            createdAt: new Date(),
            followby: followeeId
       });
       
      
    }
    
    // 创建婚恋摄影家topic
    if(Topics.find({text:'婚恋摄影家'}).count() === 0){
      TopicsId[15] = Topics.insert({
          type: 'topic',
          text: '婚恋摄影家',
          imgUrl: ''
        });
    }
    // 创建婚恋摄影家偶像用户
    if(Follows.find({username:'Hunlian'}).count() === 0){
        try{
            followeeId = Meteor.users.findOne({'username': 'suggestPosts' })._id;
        }
        catch(error)
        {
            //创建公共粉丝用户，关注所有推荐用户，从公共粉丝用户的FollowPosts里提取推荐帖子，加快推荐帖子速度
            followeeId = Accounts.createUser({
                username:'suggestPosts',
                password:'actiontec123',
                email:'suggestposts@ggmail.com',
                profile:{
                    icon:'/follows/icon1.png',
                    desc:"留下美好的瞬间！就看我的！",
                    fullname:'伊人'
                }
            });
        }
      //  创建tagFollow偶像用户
      followerId = Accounts.createUser({
           username:'Hunlian',
           password:'actiontec123',
           email:'Hunlian@ggmail.com',
           profile:{
               icon:'/follows/icon7.png',
               desc:"铭记这一浪漫时刻,定格美好和感人的婚恋瞬间！",
               fullname:'婚恋摄影家',
           },
       });
        Follower.insert({
            userId: followeeId,
            followerId: followerId,
            createAt: new Date()
        });
       Follows.insert({
           icon:'/follows/icon7.png',
           userId:followerId,
           username:'Hunlian',
           fullname:'婚恋摄影家',
           desc:"铭记这一浪漫时刻,定格美好和感人的婚恋瞬间！",
           share1:'/follows/71.jpg',
           share2:'/follows/72.jpg',
           share3:'/follows/73.jpg',
           index:7
       });
    }
});