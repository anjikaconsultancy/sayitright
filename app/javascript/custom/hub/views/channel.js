var Hub = Hub || {};

Hub.ChannelView = Backbone.View.extend({
  tagName: 'div',
  className: 'page',
  events: {
    'submit .channel-form' : 'save',
    'click .close-button' : 'close',
    'click .choose-preview-button' : 'choosePreview',
    'click .remove-preview-button' : 'removePreview'
  },  
  initialize: function() {
    this.listenTo(this.model, 'sync',this.render);
    if(this.model.has('id')){
      this.model.fetch();
    }
  },
  render: function(){
    this.$el.html(HandlebarsTemplates['hub/templates/channel']({channel:this.model.toJSON(),view_id:this.id}));
    //Need to do this in template somehow - also need to default if it is empty or save fails
    this.$('#'+this.id+'_channelStatus').val(this.model.get('status')||'published');
    
    //Init Content Editor
    //Send in elements as might not be in dom yet
    this.contentEditor = new MediumEditor($('#'+this.id+'_channelContent').get(),{
      buttons:['bold', 'italic', 'underline','strikethrough', 'anchor','header1','quote','pre','subscript','superscript','orderedlist','unorderedlist'],
      buttonLabels: {'header1':'<b>H</b>'},
      firstHeader: 'h3',
      secondHeader: 'h4'
    });
    
    return this;
  },
  save : function(e){
    e.preventDefault();

    $s = this.$('.save-button');
    $s.button('loading');
    
    //serialize form
    var data = Backbone.Syphon.serialize(this);
    
    //Grab any html data
    data['content'] = this.$('#'+this.id+'_channelContent').html();
        
    this.model.save(data,{
      success:function(model, response, options){
        $s.button('reset');
        
        //We need to fetch as put does not get data
        model.fetch();
        //Trigger results load if its loaded
        Hub.appView.trigger('channel-save');
        
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

  close : function(e){
    e.preventDefault();  
    Backbone.history.navigate('channels',{trigger: true});
  },
  
  choosePreview : function (e){
    e.preventDefault(); //or does form submit???
    var _this = this;
    filepicker.pickAndStore({mimetype:"image/*", folders:false,openTo: 'COMPUTER',multiple:false}, {location:"S3",container:Hub.settings.uploadBucket}, function(InkBlobs){
      console.log(_this.id,JSON.stringify(InkBlobs));
      if(InkBlobs.length > 0){
        _this.$('#'+_this.id+'_channelPreviewImg').attr('src','https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/web/'+encodeURIComponent(InkBlobs[0].url) + '/resize/fill/width/640/height/360/format.jpg');
        _this.$('#'+_this.id+'_channelPreviewSource').val('https://s3.amazonaws.com/'+Hub.settings.uploadBucket+'/'+InkBlobs[0].key);
      }
    });
  },
  removePreview : function (e){
    e.preventDefault();
    var _this = this;

    _this.$('#'+_this.id+'_channelPreviewImg').attr('src','');
    _this.$('#'+_this.id+'_channelPreviewSource').val('');
  }
});