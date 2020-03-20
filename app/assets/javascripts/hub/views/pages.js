var Hub = Hub || {};

Hub.PagesView = Backbone.View.extend({
  tagName: 'div',
  className: 'page',
  initialize: function() {
    this.listenTo(this.collection, 'sync',this.render);
    this.collection.fetch();
  },
  render: function(){
    this.$el.html(HandlebarsTemplates['hub/templates/pages']({pages:this.collection.toJSON()}));
    return this;
  }
});