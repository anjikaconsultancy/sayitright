var Hub = Hub || {};

Hub.PageView = Backbone.View.extend({
  tagName: 'div',
  className: 'page',
  events: {
    'submit .editor-form' : 'save',
    'click .close-button' : 'close'
  },  
  initialize: function() {
    this.listenTo(this.model, 'sync',this.render);
    if(this.model.has('id')){
      this.model.fetch();
    }
  },
  render: function(){
    this.$el.html(HandlebarsTemplates['hub/templates/page']({model:this.model.toJSON(),view_id:this.id}));

    //Need to do this in template somehow - also need to default if it is empty or save fails
    this.$('#'+this.id+'_modelStatus').val(this.model.get('status')||'published');

    console.log('#'+this.id+'_modelContent',this.$('#'+this.id+'_modelContent').html())
    //Init Source Editor
    if(this.$('#'+this.id+'_modelContent').length>0){
      console.log('Init Ace Editor');
      //this.contentEditor = ace.edit(this.id+'_modelContent');
      this.contentEditor = ace.edit(this.$('#'+this.id+'_modelContent')[0]);
      this.contentEditor.setTheme('ace/theme/chrome');
      this.contentEditor.setShowPrintMargin(false);
      this.contentEditor.getSession().setMode('ace/mode/html');
      //Dont write html into template div this is better
      this.contentEditor.getSession().setValue(this.model.get('content'));
      this.contentEditor.getSession().getUndoManager().reset();
      
      //Dont know why its selected by default
      this.contentEditor.clearSelection();

    } 
    
    return this;
  },
  save : function(e){
    e.preventDefault();

    //serialize form
    var data = Backbone.Syphon.serialize(this);
    
    //Grab any html data
    data['content'] = this.contentEditor.getValue();

    this.model.save(data,{
      success:function(model, response, options){
        //We need to fetch as put does not get data
        model.fetch();

        alert('ok saved');
      },
      error:function(model, xhr, options){
        alert('fail');
      }
    });
  },

  close : function(e){
    e.preventDefault();  
    Backbone.history.navigate('pages',{trigger: true});
  }
  
});