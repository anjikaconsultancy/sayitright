var Hub = Hub || {};

Hub.ProgramView = Backbone.View.extend({
  tagName: 'div',
  className: 'page',
  events: {
    'submit .editor-form' : 'save',
    'click .close-button' : 'close',
    'click .program-editor-item-add' : 'addContent',
    'click .program-editor-item-remove' : 'removeContent',
    'click .program-editor-item-move' : 'moveContent',
    'change .program-editor-allocations-check' : 'toggleAllocation',
    'change #programEditorAllocationsFilter' : 'filterAllocations',
    'click [data-tab]' : 'changeTab',
//    'click .program-editor-allocations-item .close' : 'removeAllocation',
//    'click .program-editor-allocations-add' : 'addAllocation',
    'click .program-editor-segment-add' : 'addSegment',
    'click .program-editor-item-cancel' : 'cancelSegment'
  },  
  initialize: function() {
    //console.log('init');
    
    // We need a local copy of allocations as we edit it
    this.allocations = new Hub.AllocationCollection();    
    this.listenTo(this.allocations, 'sync', this.render);
    this.allocations.fetch();
    
    this.listenTo(this.model, 'sync',this.render);
    // We cant do react like reactivity as it scrolls to top and clears other inputs
    //this.listenTo(Hub.appView.allocations, 'change',this.render);
    if(this.model.has('id')){
      this.model.fetch();
    }
    
    
    //TODO - add timer for refreshClips
    
  },
  render: function(){
    // Get a list we can use to filter by sites
    var allocatedSites = _.uniq(this.allocations.toJSON(), function(model){
      return model.site.id;
    });
    
    //console.log(this.model)
    
    
    //console.log(this.model,Hub.appView.site)
    if(!this.model.id){
      this.model.set('allocations',[
        {
          nid: 'new_allocation_'+new Date().getTime(), //Need to hack in fake id for new items
          status: 'published',
          channel:null,
          view_id:this.id, // cant remeber why we need this??
          status: 'published',
          site: Hub.appView.site.toJSON()
        }])
    }
    //console.log(this.model)
    
    var savedAllocations = this.model.get('allocations');
    //console.log(savedAllocations)
    
    this.allocations.map(function(a){
      a.set({
        cid:a.cid, // Hack in the cid so the template can access it
        // Attach an allocation if there is one saved
        allocation: _.find(savedAllocations,function(f){
          var site = a.get('site');
          var channel = a.get('channel');
          
          if(f.site && site){
            if(channel && f.channel){
              return (site.id == f.site.id) && (channel.id == f.channel.id);
            } else {
              // Look for both null channels
              return site.id == f.site.id && (channel == f.channel);
            }
          } else {
            return false;
          }
        })
      });
    });
    
    // Were modifying this so needs to be local!!
    var allocations = this.allocations.toJSON();
    //console.log('allocations',allocations);
    
    // Build a list with allocation information
    // var allocations = _.map(Hub.appView.allocations.toJSON(), function(a){
      
    //   //console.log('a', a);
    //   // See if we have a saved allocation and store it
    //   a.allocation = _.find(savedAllocations,function(f){
    //     if(f.site && a.site){
    //       if(a.channel && f.channel){
    //         return (a.site.id == f.site.id) && (a.channel.id == f.channel.id);
    //       } else {
    //         // Look for both null channels
    //         return a.site.id == f.site.id && (a.channel == f.channel);
    //       }
    //     } else {
    //       return false;
    //     }
    //   });
      
    //   return a;
    // })
    
    // console.log('a',allocations, savedAllocations);
    
    this.$el.html(HandlebarsTemplates['program']({model:this.model.toJSON(),allocatedSites: allocatedSites, allocations:allocations,view_id:this.id}));
    
    var _this = this;
    
    //Copy content to editors
    this.$('.program-editor-fragments .program-editor-fragment').each(function(index){
      _this.enableWysiwyg($(this));
      _this.enableEmbedly($(this));
      _this.enableClip($(this));
    });

    this.$('.program-editor-segments .program-editor-segment').each(function(index){
      _this.enableEmbedly($(this));
      _this.enableClip($(this));
    });    
    
    //Need to do this in template somehow - also need to default if it is empty or save fails
    this.$('#'+this.id+'_modelStatus').val(this.model.get('status')||'published');    
    
    // New Allocations
    //programs-editor-allocations-list

    //allocations 
    //TODO - move global ?

    // var c = new Hub.AllocationCollection();    
    // c.fetch({success:function(collection, response, options){
    //   var allocations = ""; 
    //   collection.each(function(item){
    //       var site = item.get('site');
    //       var channel = item.get('channel');
    //       var title = site.title;
    //       if(channel){
    //         title += ' / ' + channel.title;
    //       }
    //       var $btn = $('<button type="button" class="program-editor-allocations-add btn btn-default btn-xs btn-block"></button>');
    //       $btn.text(title);
    //       $btn.attr('data-site',JSON.stringify(site));
    //       $btn.attr('data-channel',JSON.stringify(channel));
    //       allocations += $btn.wrap('<div>').parent().html();
    //   });
    //   _this.$('.program-editor-allocations-button').popover({
    //     html:true,
    //     title: 'Allocations',
    //     container: '#form_'+_this.id,
    //     content: '<div class="scrollbars" style="max-height:200px;overflow:auto;">' + allocations + '</div>'
    //   });

    // }});    
    
    return this;
  },

  refreshClips : function(){
    var _this = this;
    _this.$('.program-editor-fragment,.program-editor-segment').each(function(index){
      $c = $(this).find('.program-editor-fragment-clip,.program-editor-segment-clip');
      
      //console.log($c.data('kind'),$c.data('clip-id'),$c.data('status'),$c.data('encoded'));
      //if($c.data('encoded') $c.data('status')=="ready"){
      
      //}
    });

      /*
          this.$('.program-editor-fragments .program-editor-fragment').each(function(index){

      var clip = new Hub.ClipModel();
            clip.save({source:'http://s3.amazonaws.com/' + Hub.settings.uploadBucket + '/' + val.key},{
              success:function(model, response, options){
                //We need to fetch as put does not get data, and wait for response as we dont want to trigger full page refresh
                clip.fetch({
                  success:function(model, response, options){
                    var $i = $(HandlebarsTemplates[''+target+'s/clip']({is_new:true,id:'new_'+target+'_'+new Date().getTime(),kind:'clip',position:0,content:'',clip:model,view_id:_this.id}));
                    if($c.length>0){
                      $i.insertBefore($c);}
                    else{
                      $i.appendTo($f);
                    }          
                    _this.enableClip($i);                  
                  },
                  error:function(model, xhr, options){console.log('Error loading clip');}
                });
              },
              error:function(model, xhr, options){console.log('Error creating clip');}
            });
      */
      
  },

  enableClip : function($parent){
    $c = $parent.find('.program-editor-fragment-clip,.program-editor-segment-clip');
    
    if($c.data('status')=="ready"){
      switch($c.data('kind')){
        case 'image':
            //$c.html('<img src="https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/'+encodeURIComponent($c.data('url')+'/file') +'/resize/limit/width/640/height/360/format.jpg">')
            $c.html('<img style="max-width:100%;" src="'+$c.data('preview') + '">');        
            break;
        case 'video':
            //$c.html('<img src="https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/'+encodeURIComponent($c.data('url')+'/thumbnails/0000.jpg') +'/resize/limit/width/640/height/360/format.jpg">')
            $c.html('<img style="max-width:100%;" src="'+$c.data('preview') + '">');        
            break;
      }
    }else{      
      if($c.hasClass('program-editor-segment-clip')){
        $c.html('<div class="text-center program-editor-segment-loading"><i class="glyphicon-repeat glyphicon-spin" style="font-size:30px;"></i></div>');
      }else{
        $c.html('<div class="text-center program-editor-fragment-loading"><i class="glyphicon-repeat glyphicon-spin" style="font-size:30px;"></i></div>');        
      }
    }
  },
  enableWysiwyg : function($parent){
    //until wysiwyg works with text area we need to manually activate them all
    $parent.find('.program-editor-fragment-wysiwyg').html($parent.find('[name$="[content]"]').val());
    
    $parent.data('wysiwyg',new MediumEditor($parent.find('.program-editor-fragment-wysiwyg').get(),{
      buttons:['bold', 'italic', 'underline','strikethrough', 'anchor','header1','quote','pre','subscript','superscript','orderedlist','unorderedlist'],
      buttonLabels: {'header1':'<b>H</b>'},
      firstHeader: 'h3',
      secondHeader: 'h4'
    }));      
  },
  enableEmbedly : function($parent){
    var url = $parent.find('[name$="[url]"]').val();
    if (typeof(url) != "undefined"){
      $.get('https://iframe.ly/api/oembed?url='+url+'&api_key='+Hub.settings.iframelyKey, function(data){
        if (data.thumbnail_url){
          $parent.find('.program-editor-embedly-item').html('<img src="'+data.thumbnail_url+'">');
        }
        $parent.find('[name$="[content]"]').val(data.title);
      });
    }
    // iframely.load()
    //   console.log("lkjshkjhkjhkj")
    // });
    // $parent.find('[name$="[content]"]').val("hello");
    // $.embedly.oembed(url, {query: {maxwidth: 480,maxheight: 360,chars: 200,autoplay: false}}).done(function(results){
    //   if(results.length>0 && !results[0].invalid){
    //     if(results[0].thumbnail_url){
    //       $parent.find('.program-editor-embedly-item').html('<img src="'+results[0].thumbnail_url+'">');
    //     }
    //     $parent.find('[name$="[content]"]').val(results[0].title);
    //   }else{
    //     $parent.hide();
    //     $parent.find('[name$="[_destroy]"]').val(true);
    //   }
    // });
  },
  
  save : function(e){
    e.preventDefault();

    $s = this.$('.save-button');
    $s.button('loading');
    
    //update any data to form inputs
    this.updateContent();
    
    //serialize form
    var data = Backbone.Syphon.serialize(this);
    //Convert serialized hashes template hack to arrays for rails
    //Note that syphon does not support object[][field] format so we need to hack in an id object[{{id}}][field]
    //so long as the id is unique it will work and we can map them correctly below
    data.fragments = _.map(data.fragments,function(value,key){return value});
    data.segments = _.map(data.segments,function(value,key){return value});
    data.allocations = _.map(data.allocations,function(value,key){return value});
    
    //console.log(data);
    //return false;
    
    this.model.save(data,{
      success:function(model, response, options){
        $s.button('reset');
        //We need to fetch as put does not get data
        model.fetch();
        
        //Trigger results load if its loaded
        Hub.appView.trigger('program-save');
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
    Backbone.history.navigate('programs',{trigger: true});
  },
  addSegment :function(e){
    var $t = this.$(e.currentTarget);
    var $c = $t.closest('.program-editor-segment');
    $c.find('.program-editor-segment-insert').show();
    
  },
  cancelSegment : function(e){
    var $t = this.$(e.currentTarget);
    var $c = $t.closest('.program-editor-segment');
    $c.find('.program-editor-segment-insert').hide(); 
  },
  addContent : function(e){
    e.preventDefault();  
    var $t = this.$(e.currentTarget);
    var target = $t.data('target');
    
    var $c = $t.closest('.program-editor-'+target);
    
    $c.find('.program-editor-'+target+'-insert').hide(); 

    
    var $f = this.$('.program-editor-'+target+'s');
    var _this = this;

    switch($t.data('kind')){
      case 'external':
        var url = prompt("Enter a url");
        if(url != null){
          var $i = $(HandlebarsTemplates[''+target+'s/external']({is_new:true,id:'new_'+target+'_'+new Date().getTime(),kind:'external',position:0,content:'',url:url,view_id:this.id}));
          
          if($c.length>0){
            $i.insertBefore($c);}
          else{
            $i.appendTo($f);
          }          
          this.enableEmbedly($i);
        }
        break;  
      case 'clip':
        filepicker.pickAndStore({ folders:false,openTo: 'COMPUTER',multiple:true}, {location:"S3",container:Hub.settings.uploadBucket}, function(InkBlobs){
          console.log(_this.id,JSON.stringify(InkBlobs));
          _.each(InkBlobs, function(val,key){
            var clip = new Hub.ClipModel();
            clip.save({source:'https://s3.amazonaws.com/' + Hub.settings.uploadBucket + '/' + val.key},{
              success:function(model, response, options){
                //We need to fetch as put does not get data, and wait for response as we dont want to trigger full page refresh
                clip.fetch({
                  success:function(model, response, options){
                    var $i = $(HandlebarsTemplates[''+target+'s/clip']({is_new:true,id:'new_'+target+'_'+new Date().getTime(),kind:'clip',position:0,content:'',clip:model,view_id:_this.id}));
                    if($c.length>0){
                      $i.insertBefore($c);}
                    else{
                      $i.appendTo($f);
                    }          
                    _this.enableClip($i);                  
                  },
                  error:function(model, xhr, options){console.log('Error loading clip');}
                });
              },
              error:function(model, xhr, options){console.log('Error creating clip');}
            });
          }); 
        });        
        break;
      default:
        if(target=='fragment'){
          var $i = $(HandlebarsTemplates[''+target+'s/text']({is_new:true,id:'new_'+target+'_'+new Date().getTime(),kind:'text',position:0,content:'<p>Enter some text...</p>',view_id:this.id}));
          if($c.length>0){
            $i.insertBefore($c);}
          else{
            $i.appendTo($f);
          }          
          this.enableWysiwyg($i);
        }
    }
  },

  removeContent : function(e){
    e.preventDefault();  
    var $t = this.$(e.currentTarget);
    var target = $t.data('target');
    
    var $c = $t.closest('.program-editor-'+target);
    $c.find('[name$="[_destroy]"]').val(true);

    $c.hide();
  },
  
  moveContent : function(e){
    e.preventDefault(); 
    var $t = this.$(e.currentTarget);
    var target = $t.data('target');
    
    var $f = this.$('.program-editor-'+target+'s .program-editor-'+target);
    var $c = $t.closest('.program-editor-'+target);
    if($t.data('move')=='up'){
      $c.insertBefore($c.prev());
    }else{
      if(!$c.next().hasClass('program-editor-'+target+'-buttons')){
        $c.insertAfter($c.next());      
      }
    }
  },
  updateContent : function(){
    //update anything that needs moving to form data
    var _this = this;
    this.$('.program-editor-fragments .program-editor-fragment').each(function(index){
      //recalculate positions based on DOM position
      _this.$(this).find('[name$="[position]"]').val(index);
      
      //copy wysiwyg data
      //$(this).find('[name$="[content]"]').val($(this).data('wysiwyg').serialize());
      $w = _this.$(this).find('.program-editor-fragment-wysiwyg');
      if($w.length>0){
        _this.$(this).find('[name$="[content]"]').val($w.html());
      }
    });

    this.$('.program-editor-segments .program-editor-segment').each(function(index){
      //recalculate positions based on DOM position
      _this.$(this).find('[name$="[position]"]').val(index);      
    });
  },
  
  toggleAllocation  : function(e){
    var $t = this.$(e.currentTarget);
    var checked = $t.prop('checked');
    var cid = $t.parent().data('cid');
    var item = this.allocations.get(cid);
    
//    console.log(item)
    var a = item.get('allocation');
    
    // If it is saved it will have an id
    if(a && a.id){
      // Item is not new so handle update by setting the destroy flag on the allocation
      if(!checked){
        a.destroy = true;
      } else {
        a.destroy = false;
      }
      item.set({allocation:a});
    } else{
      // If not saved just add/remove on collection
      if(!checked){
        item.set({allocation:null});
      } else {
        item.set({
          allocation: {
            nid: 'new_allocation_'+new Date().getTime(), //Need to hack in fake id for new items
            status: 'published',
            site:item.get('site'),
            channel:item.get('channel'),
            view_id:this.id
          }
        });
      }
    }
    // Replace the whole allocation
    var $i = $(HandlebarsTemplates['forms/allocation-new'](item.toJSON()));
    //console.log($i)
    $t.parent().replaceWith($i);
  },
  
  filterAllocations: function(e){
    var v = e.currentTarget.value;
    if(v=="all" || v==""){
      this.$('.program-editor-allocations-item').css( "display", "block");
    }else if(v=="allocated"){
      this.$('.program-editor-allocations-item').css( "display", "none");
      this.$('.program-editor-allocations-item[data-allocated="true"]').css( "display", "block");
    }else if(v=="unallocated"){
      this.$('.program-editor-allocations-item').css( "display", "block");
      this.$('.program-editor-allocations-item[data-allocated="true"]').css( "display", "none");
    }else{
      this.$('.program-editor-allocations-item').css( "display", "none");
      this.$('.program-editor-allocations-item[data-site="'+v+'"]').css( "display", "block");
    }
  },
  
  changeTab : function(e){
    var $t = this.$(e.currentTarget);
    this.$($t.data('show')).css( "display", "block");
    this.$($t.data('hide')).css( "display", "none");
    $t.parent().children().toggleClass('active');
  },
  
  removeAllocation : function(e){
    e.preventDefault(); 
    var $t = this.$(e.currentTarget);
    
    var $c = $t.closest('.program-editor-allocations-item');
  
    if($c.length>0){
      $c.find('[name$="[_destroy]"]').val(true);

      $c.hide();      
    }
  },
  addAllocation : function(e){
    e.preventDefault(); 
    this.$('.program-editor-allocations-button').popover('toggle');
    
    var $t = this.$(e.currentTarget);
    var $a = this.$('.program-editor-allocations');
    var $i = $(HandlebarsTemplates['forms/allocation']({is_new:true,id:'new_allocation_'+new Date().getTime(),status:'published',site:$t.data('site'),channel:$t.data('channel'),view_id:this.id}));
    $i.appendTo($a);
  }

});
