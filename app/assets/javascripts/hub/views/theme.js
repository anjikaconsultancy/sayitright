var Hub = Hub || {};

Hub.ThemeView = Backbone.View.extend({
  tagName: 'div',
  className: 'page',
  events: {
    'submit .editor-form' : 'save',
    'click .close-button' : 'close'
  },  
  initialize: function() {
    this.$el.html(HandlebarsTemplates['theme']({model:this.model.toJSON(),view_id:this.id}));
    this.templateEditor = ace.edit(this.$('#'+this.id+'_modelTemplate')[0]);
    this.templateEditor.setTheme('ace/theme/chrome');
    this.templateEditor.setShowPrintMargin(false);
    this.templateEditor.getSession().setMode('ace/mode/handlebars');

    this.listenTo(this.model, 'sync',this.render);
    if(this.model.has('id')){
      this.model.fetch();
    }
    
  },
  render: function(){
    //Init Source Editor
    if(this.$('#'+this.id+'_modelTemplate').length>0){
      //only update the content if its new or not going to trigger a scroll to top
      if(this.templateEditor.getValue().length<100){
        this.templateEditor.getSession().setValue(this.model.get('template'));
        this.templateEditor.getSession().getUndoManager().reset();
        //Dont know why its selected by default
        this.templateEditor.clearSelection();
      }

    }    
    
    //fix model
    this.$('#'+this.id+'_modelTitle').val(this.model.get('title'));
    this.$('#'+this.id+'_modelDescription').val(this.model.get('description'));
    
    return this;
  },
  save : function(e){
    e.preventDefault();

    $s = this.$('.save-button');
    $s.button('loading');    
    
    //serialize form
    var data = Backbone.Syphon.serialize(this);
    
    //Grab any html data
    data['template'] = this.templateEditor.getValue();
            
    this.model.save(data,{
      success:function(model, response, options){
        //We need to fetch as put does not get data
        //Dont dothis as it triggers render and we dont want to loose current state
        model.fetch();
        $s.button('reset');

      },
      error:function(model, xhr, options){
        $s.button('reset');

        alert('fail');
      }
    });
  },

  close : function(e){
    e.preventDefault();  
    Backbone.history.navigate('themes',{trigger: true});
  }
  
});