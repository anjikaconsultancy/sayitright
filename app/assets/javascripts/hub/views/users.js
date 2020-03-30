Hub.UsersView = Backbone.View.extend({
  tagName: 'div',
  className: 'page',
  initialize: function() {
    this.listenTo(this.collection, 'sync',this.render);
    this.collection.fetch();
  },
  render: function(){
    this.$el.html(HandlebarsTemplates['hub/templates/users']({items:this.collection.toJSON()}));
    return this;
  }
});