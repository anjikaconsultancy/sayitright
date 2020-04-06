var Hub = Hub || {};

Hub.ThemesView = Backbone.View.extend({
  tagName: 'div',
  className: 'page',
  events: {
    'click .btn-remove-theme' : 'removeTheme',
    'click .btn-apply-theme' : 'applyTheme'
  },   
  initialize: function() {
    this.listenTo(Hub.appView.site, 'sync',this.render);
    this.listenTo(this.collection, 'sync',this.render);
    this.collection.fetch();
  },
  render: function(){
    this.$el.html(HandlebarsTemplates['themes']({themes:this.collection.toJSON(),site:Hub.appView.site.toJSON()}));
    return this;
  },
  
  removeTheme:function(e){
    Hub.appView.site.set('theme',{id:null})
    Hub.appView.site.save()
    //(data,{
    //  success:function(model, response, options){
    //  },
    //  error:function(model, xhr, options){
    //  }
    //});    
    
  },
  applyTheme:function(e){
    var $t = this.$(e.currentTarget);
    
    Hub.appView.site.set('theme',{id:$t.data('theme')})

    Hub.appView.site.save()
    //(data,{
    //  success:function(model, response, options){
    //  },
    //  error:function(model, xhr, options){
    //  }
    //});      
  },
  
});