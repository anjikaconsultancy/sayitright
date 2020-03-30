var Hub = Hub || {};

Hub.UserView = Backbone.View.extend({
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
    this.$el.html(HandlebarsTemplates['hub/templates/user']({user:this.model.toJSON(),view_id:this.id,options:{roles:[{name:'Administrator',value:'administrator'},{name:'Manager',value:'manager'},{name:'Moderator',value:'moderator'},{name:'Publisher',value:'publisher'},{name:'User',value:'user'}]}}));
    return this;
  },
  save : function(e){
    e.preventDefault();

    this.model.save(Backbone.Syphon.serialize(this),{
      success:function(model, response, options){
        alert('ok');
      },
      error:function(model, xhr, options){

        alert('fail');
      }
    });
  },
  close : function(e){
    e.preventDefault();  
    Backbone.history.navigate('users',{trigger: true});
  },
});