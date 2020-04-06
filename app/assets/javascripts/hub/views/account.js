var Hub = Hub || {};

Hub.AccountView = Backbone.View.extend({
  tagName: 'div',
  className: 'page',
  events: {
    'submit #userForm' : 'save'
  },
  initialize: function() {
    //Lisen for updates to global user
    this.listenTo(Hub.appView.user, 'change', this.render);
    //Reset errors
    this.errors = [];

  },
  render: function(){
    this.$el.html(HandlebarsTemplates['account']({errors:this.errors,user:Hub.appView.user.toJSON()}));
    return this;
  },
  save : function(e){
    e.preventDefault();
    var _this = this;
    Hub.appView.user.save(Backbone.Syphon.serialize(this),{
      success:function(model, response, options){
        alert('ok');
      },
      error:function(model, xhr, options){
        //If save is bad then remove or revert old attributes
        //Hub.appView.user.set(model.previousAttributes());
        Hub.appView.user.unset('password');
        Hub.appView.user.unset('password_confirmation');
        _this.errors = [{message:'There was an error!'},{message:'Oops'}];
        _this.render();
      }
    });
  }
});