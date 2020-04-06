var Hub = Hub || {};

Hub.ProgramsView = Backbone.View.extend({
  tagName: 'div',
  className: 'page',
  initialize: function() {
    this.listenTo(this.collection, 'sync',this.render);
    
    this.listenTo(Hub.appView, 'program-save',this.reload);
    
    this.collection.fetch();
  },
  events: {
    'click a.prev': 'previous',
    'click a.next': 'next',
    'click a.current': 'current'
  },
  reload : function(){
    this.collection.fetch();
    $('.prev').addClass('disabled')
  },
  render: function(){
    this.$el.html(HandlebarsTemplates['programs']({programs: this.collection.toJSON(), pages: this.collection.pageInfo()}));
    if (typeof this.collection.pageInfo() != 'undefined'){
      $('#'+this.collection.pageInfo().page).addClass('current-page')
    }
    return this;
  },
  previous: function() {
    this.collection.previousPage();
    return false;
  },
  next: function() {
    this.collection.nextPage();
    return false;
  },
  current: function(e){
    this.collection.currentPage(event.target.id);
  }
});