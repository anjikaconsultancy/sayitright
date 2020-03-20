var Hub = Hub || {};

//TODO: Globally handle pushstate routing example
//http://artsy.github.io/blog/2012/06/25/replacing-hashbang-routes-with-pushstate/

Hub.AppRouter = Backbone.Router.extend({
  initialize: function(){
    //Maintain a stack of views so we can keep content loaded or close as needed
    this.views = {};
    
    //TODO: Event handlers & idle detection to remove views.
  },
  loadPage: function(route,view,options){
    //We maintain a stack of page views, so only load when we need to
    var _this = this;
    if(!Hub.appView.$pages.find('#'+route+'_view').length){
      console.log('Load Route',route); 

      var viewOptions = {id:route+'_view'};
      
      if(_.has(options,'model')){
        viewOptions['model'] =  new Hub[options.model](options.attributes);
      }else if(_.has(options,'collection')){
        viewOptions['collection'] =  new Hub[options.collection]();
      }

      this.views[route] = new Hub[view](viewOptions);
      
      Hub.appView.$('#pages').append(this.views[route].render().$el.css('top','100%'));      
      setTimeout(function(){_this.views[route].$el.css('top','0%')},10);//css transition
      //TODO trigger event or timeout to remove dead views
    }else{
      console.log('Show Route',route);        
      //Move view to end top of list and slide in   
      Hub.appView.$pages.append(this.views[route].$el.css('top','100%'));
      setTimeout(function(){_this.views[route].$el.css('top','0%')},10);
    }
  },
  routes: {
    'settings': function(){this.loadPage('settings','SettingsView',{});},
    'account': function(){this.loadPage('account','AccountView',{});},
    'profile': function(){this.loadPage('profile','ProfileView',{});},
    'programs': function(){this.loadPage('programs','ProgramsView',{collection:'ProgramCollection'});},
    'programs/new': function(){this.loadPage('program_new'+new Date().getTime(),'ProgramView',{model:'ProgramModel',attributes:{title:'New Program'}});},
    'programs/:id': function(id){this.loadPage('program_'+id,'ProgramView',{model:'ProgramModel',attributes:{id:id}});},
    'channels': function(){this.loadPage('channels','ChannelsView',{collection:'ChannelCollection'});},
    'channels/new': function(){this.loadPage('channel_new'+new Date().getTime(),'ChannelView',{model:'ChannelModel',attributes:{}});},
    'channels/:id': function(id){this.loadPage('channel_'+id,'ChannelView',{model:'ChannelModel',attributes:{id:id}});},
    'pages': function(){this.loadPage('pages','PagesView',{collection:'PageCollection'});},
    'pages/new': function(){this.loadPage('page_new'+new Date().getTime(),'PageView',{model:'PageModel',attributes:{}});},
    'pages/:id': function(id){this.loadPage('page_'+id,'PageView',{model:'PageModel',attributes:{id:id}});},
    'users': function(){this.loadPage('users','UsersView',{collection:'UserCollection'});},
    'users/new': function(){this.loadPage('user_new'+new Date().getTime(),'UserView',{model:'UserModel',attributes:{}});},
    'users/:id': function(id){this.loadPage('user_'+id,'UserView',{model:'UserModel',attributes:{id:id}});},
    'themes': function(){this.loadPage('themes','ThemesView',{collection:'ThemeCollection'});},
    'themes/new': function(){this.loadPage('theme_new'+new Date().getTime(),'ThemeView',{model:'ThemeModel',attributes:{}});},
    'themes/:id': function(id){this.loadPage('theme_'+id,'ThemeView',{model:'ThemeModel',attributes:{id:id}});},
    '*actions': function(actions){this.loadPage('dashboard','DashboardView',{model:'DashboardModel'});}
  }
});