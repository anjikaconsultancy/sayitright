var Hub = Hub || {};

Hub.ProfileView = Backbone.View.extend({
  tagName: 'div',
  className: 'page',
  events: {
    'submit #userForm' : 'save',
    'click .choose-header-button' : 'chooseHeader',
    'click .remove-header-button' : 'removeHeader',
    'click .choose-avatar-button' : 'chooseAvatar',
    'click .remove-avatar-button' : 'removeAvatar'      
  },
  initialize: function() {
    //Lisen for updates to global user
    this.listenTo(Hub.appView.user, 'change', this.render);
  },
  render: function(){
    this.$el.html(HandlebarsTemplates['hub/templates/profile']({user:Hub.appView.user.toJSON(),view_id:this.id}));
    return this;
  },
  save : function(e){
    e.preventDefault();
    Hub.appView.user.save(Backbone.Syphon.serialize(this),{
      success:function(model, response, options){
        alert('ok');
      },
      error:function(model, xhr, options){

        alert('fail');
      }
    });
  },
  chooseAvatar : function (e){
    e.preventDefault(); //or does form submit???
    var _this = this;
    filepicker.pickAndStore({mimetype:"image/*", folders:false,openTo: 'COMPUTER',multiple:false}, {location:"S3",container:Hub.settings.uploadBucket}, function(InkBlobs){
      console.log(_this.id,JSON.stringify(InkBlobs));
      if(InkBlobs.length > 0){
        _this.$('#'+_this.id+'_userAvatarImg').attr('src','https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/web/'+encodeURIComponent(InkBlobs[0].url) + '/resize/fill/width/256/height/256/format.png');
        _this.$('#'+_this.id+'_userAvatarSource').val('https://s3.amazonaws.com/'+Hub.settings.uploadBucket+'/'+InkBlobs[0].key);
      }
    });
  },
  removeAvatar : function (e){
    e.preventDefault();
    var _this = this;

    _this.$('#'+_this.id+'_userAvatarImg').attr('src','');
    _this.$('#'+_this.id+'_userAvatarSource').val('');
  },
  chooseHeader : function (e){
    e.preventDefault(); //or does form submit???
    var _this = this;
    filepicker.pickAndStore({mimetype:"image/*", folders:false,openTo: 'COMPUTER',multiple:false}, {location:"S3",container:Hub.settings.uploadBucket}, function(InkBlobs){
      console.log(_this.id,JSON.stringify(InkBlobs));
      if(InkBlobs.length > 0){
        _this.$('#'+_this.id+'_userHeaderImg').attr('src','https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/web/'+encodeURIComponent(InkBlobs[0].url) + '/resize/fill/width/640/height/360/format.jpg');
        _this.$('#'+_this.id+'_userHeaderSource').val('https://s3.amazonaws.com/'+Hub.settings.uploadBucket+'/'+InkBlobs[0].key);
      }
    });
  },
  removeHeader : function (e){
    e.preventDefault();
    var _this = this;

    _this.$('#'+_this.id+'_userHeaderImg').attr('src','');
    _this.$('#'+_this.id+'_userHeaderSource').val('');
  },  
});