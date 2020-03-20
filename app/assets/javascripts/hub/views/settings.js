var Hub = Hub || {};

Hub.SettingsView = Backbone.View.extend({
  tagName: 'div',
  className: 'page',
  events: {
    'change #siteHostEdit': 'switchHostEdit',
    'submit #settingsForm' : 'save',
    'click .choose-icon-button' : 'chooseIcon',
    'click .remove-icon-button' : 'removeIcon',
    'click .choose-background-button' : 'chooseBackground',
    'click .remove-background-button' : 'removeBackground',
    'click .choose-banner-button' : 'chooseBanner',
    'click .remove-banner-button' : 'removeBanner',
    'click .choose-header-button' : 'chooseHeader',
    'click .remove-header-button' : 'removeHeader',
    'click .choose-logo-button' : 'chooseLogo',
    'click .remove-logo-button' : 'removeLogo',
    'click .site-domain-add' : 'addDomain',
    'click .site-domain .close' : 'removeDomain'
  },
  initialize: function() {
    //Lisen for updates to global site (moved to sync not change as this caused re-render problems)
    this.listenTo(Hub.appView.site, 'sync', this.render);
  },
  render: function(){
    this.$el.html(HandlebarsTemplates['hub/templates/settings']({site:Hub.appView.site.toJSON(),view_id:this.id}));
    return this;
  },
  switchHostEdit:function(e){
    this.$('#siteHost').prop('disabled', !this.$('#siteHostEdit').prop('checked'));
  },
  save : function(e){
    e.preventDefault();

    var $s = this.$('.save-button');
    $s.button('loading');    

    var data = Backbone.Syphon.serialize(this);
    //Convert serialized hashes template hack to arrays for rails
    //Note that syphon does not support object[][field] format so we need to hack in an id object[{{id}}][field]
    //so long as the id is unique it will work and we can map them correctly below
    data.domains = _.map(data.domains,function(value,key){return value});
    
    Hub.appView.site.save(data,{
      success:function(model, response, options){
        model.fetch();

        $s.button('reset');
      },
      error:function(model, xhr, options){
        $s.button('reset');
        console.log(xhr.responseJSON.errors);
        var msg = '';
        _.each(xhr.responseJSON.errors,function(value, key, list){
          msg += key + ' ' + value.join('\n'+key+' ')
        });
        alert('Save Failed:\n' + msg );
      }
    });
  },
  chooseLogo : function (e){
    e.preventDefault(); //or does form submit???
    var _this = this;
    filepicker.pickAndStore({mimetype:"image/*", folders:false,openTo: 'COMPUTER',multiple:false}, {location:"S3",container:Hub.settings.uploadBucket}, function(InkBlobs){
      console.log(_this.id,JSON.stringify(InkBlobs));
      if(InkBlobs.length > 0){
        console.log(_this.$('#'+_this.id+'_siteLogoSource'));
        _this.$('#'+_this.id+'_siteLogoImg').attr('src','https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/web/'+encodeURIComponent(InkBlobs[0].url) + '/resize/fill/width/400/height/200/format.png');
        _this.$('#'+_this.id+'_siteLogoSource').val('https://s3.amazonaws.com/'+Hub.settings.uploadBucket+'/'+InkBlobs[0].key);
      }
    });
  },
  removeLogo : function (e){
    e.preventDefault();
    var _this = this;

    _this.$('#'+_this.id+'_siteLogoImg').attr('src','');
    _this.$('#'+_this.id+'_siteLogoSource').val('');
  },
  chooseIcon : function (e){
    e.preventDefault(); //or does form submit???
    var _this = this;
    filepicker.pickAndStore({mimetype:"image/*", folders:false,openTo: 'COMPUTER',multiple:false}, {location:"S3",container:Hub.settings.uploadBucket}, function(InkBlobs){
      console.log(_this.id,JSON.stringify(InkBlobs));
      if(InkBlobs.length > 0){
        _this.$('#'+_this.id+'_siteIconImg').attr('src','https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/web/'+encodeURIComponent(InkBlobs[0].url) + '/resize/fill/width/256/height/256/format.png');
        _this.$('#'+_this.id+'_siteIconSource').val('https://s3.amazonaws.com/'+Hub.settings.uploadBucket+'/'+InkBlobs[0].key);
      }
    });
  },
  removeIcon : function (e){
    e.preventDefault();
    var _this = this;

    _this.$('#'+_this.id+'_siteIconImg').attr('src','');
    _this.$('#'+_this.id+'_siteIconSource').val('');
  },
  chooseBackground : function (e){
    e.preventDefault(); //or does form submit???
    var _this = this;
    filepicker.pickAndStore({mimetype:"image/*", folders:false,openTo: 'COMPUTER',multiple:false}, {location:"S3",container:Hub.settings.uploadBucket}, function(InkBlobs){
      console.log(_this.id,JSON.stringify(InkBlobs));
      if(InkBlobs.length > 0){
        _this.$('#'+_this.id+'_siteBackgroundImg').attr('src','https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/web/'+encodeURIComponent(InkBlobs[0].url) + '/resize/fill/width/640/height/360/format.jpg');
        _this.$('#'+_this.id+'_siteBackgroundSource').val('https://s3.amazonaws.com/'+Hub.settings.uploadBucket+'/'+InkBlobs[0].key);
      }
    });
  },
  removeBackground : function (e){
    e.preventDefault();
    var _this = this;

    _this.$('#'+_this.id+'_siteBackgroundImg').attr('src','');
    _this.$('#'+_this.id+'_siteBackgroundSource').val('');
  },
  chooseHeader : function (e){
    e.preventDefault(); //or does form submit???
    var _this = this;
    filepicker.pickAndStore({mimetype:"image/*", folders:false,openTo: 'COMPUTER',multiple:false}, {location:"S3",container:Hub.settings.uploadBucket}, function(InkBlobs){
      console.log(_this.id,JSON.stringify(InkBlobs));
      if(InkBlobs.length > 0){
        _this.$('#'+_this.id+'_siteHeaderImg').attr('src','https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/web/'+encodeURIComponent(InkBlobs[0].url) + '/resize/fill/width/640/height/360/format.jpg');
        _this.$('#'+_this.id+'_siteHeaderSource').val('https://s3.amazonaws.com/'+Hub.settings.uploadBucket+'/'+InkBlobs[0].key);
      }
    });
  },
  removeHeader : function (e){
    e.preventDefault();
    var _this = this;

    _this.$('#'+_this.id+'_siteHeaderImg').attr('src','');
    _this.$('#'+_this.id+'_siteHeaderSource').val('');
  },
  chooseBanner : function (e){
    e.preventDefault(); //or does form submit???
    var _this = this;
    filepicker.pickAndStore({mimetype:"image/*", folders:false,openTo: 'COMPUTER',multiple:false}, {location:"S3",container:Hub.settings.uploadBucket}, function(InkBlobs){
      console.log(_this.id,JSON.stringify(InkBlobs));
      if(InkBlobs.length > 0){
        _this.$('#'+_this.id+'_siteBannerImg').attr('src','https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/web/'+encodeURIComponent(InkBlobs[0].url) + '/resize/fill/width/728/height/90/format.png');
        _this.$('#'+_this.id+'_siteBannerSource').val('https://s3.amazonaws.com/'+Hub.settings.uploadBucket+'/'+InkBlobs[0].key);
      }
    });
  },
  removeBanner : function (e){
    e.preventDefault();
    var _this = this;

    _this.$('#'+_this.id+'_siteBannerImg').attr('src','');
    _this.$('#'+_this.id+'_siteBannerSource').val('');
  },
  addDomain : function(e){
    var domain = prompt("Enter a domain");
    if(domain != null){
      var $i = $(HandlebarsTemplates['hub/templates/forms/domain']({is_new:true,id:'new_domain_'+new Date().getTime(),host:domain,view_id:this.id}));
      $i.appendTo(this.$('.site-domains'));
    }
  },
  removeDomain : function (e){
    var $t = this.$(e.currentTarget);
    
    var $c = $t.closest('.site-domain');
    $c.find('[name$="[_destroy]"]').val(true);
    $c.hide();
    
  } 
});