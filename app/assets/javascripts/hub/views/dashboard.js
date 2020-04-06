var Hub = Hub || {};

Hub.DashboardView = Backbone.View.extend({
  tagName: "div",
  className: "page",
  initialize: function() {
    //Listen for any updates to current user  
    this.listenTo(Hub.appView.user, "change", this.render);
    
    //Lisen for updates to dashboard
    this.listenTo(this.model, "change", this.render);
    this.model.fetch();
  },
  render: function(){
    this.$el.html(HandlebarsTemplates['dashboard']({user:Hub.appView.user.toJSON(),site:Hub.appView.site.toJSON(),system:Hub.appView.system.toJSON(),dashboard:this.model.toJSON()}));
    return this;
  }
});