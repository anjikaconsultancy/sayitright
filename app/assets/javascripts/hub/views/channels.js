var Hub = Hub || {};

Hub.ChannelsView = Backbone.View.extend({
  tagName: 'div',
  className: 'page',
  initialize: function() {
    this.listenTo(this.collection, 'sync',this.render);
    this.listenTo(Hub.appView, 'channel-save',this.reload);
    
    this.collection.fetch();
  },
  reload : function(){
    this.collection.fetch();
  },  
  render: function(){
    this.$el.html(HandlebarsTemplates['hub/templates/channels']({channels:this.collection.toJSON()}));
    return this;
  }
});