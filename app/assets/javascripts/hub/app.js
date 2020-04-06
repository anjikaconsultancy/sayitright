var Hub = Hub || {};

Hub.AppView = Backbone.View.extend({

  el:'#hub',

  events: {
    'click A': 'interceptor',
    'hide.bs.collapse .nav-menu':function(e){this.$(e.target).parent().find('button i').removeClass('glyphicon-minus').addClass('glyphicon-plus')},
    'show.bs.collapse .nav-menu':function(e){this.$(e.target).parent().find('button i').removeClass('glyphicon-plus').addClass('glyphicon-minus')},
    'mouseover #menu [data-toggle="tooltip"]':function(e){if(!this.$el.hasClass('menu-open')){this.$(e.currentTarget).tooltip('show')};},
    'mouseout #menu [data-toggle="tooltip"]':function(e){this.$(e.currentTarget).tooltip('hide');}
  },

  interceptor: function(e){
    var href = $(e.currentTarget).closest('A').attr('href');

    if(href.indexOf('://')>-1 || href.indexOf('/')==0){ // http:// or /root path - just pass through
      return true;
    }else if(href.indexOf('#')==0){ // links internal to interfaces
      e.preventDefault();    
      return false;
    }else{ // Router managed
      e.preventDefault();    
      Backbone.history.navigate(href, {trigger: true});
    }
  },
  
  initialize: function() {
    //Fetch and listen for system status
    this.system = new Hub.SystemModel();
    this.listenTo(this.system, 'change', this.render);
    this.system.fetch();
    
    //Fetch and listen for current user - we need to send in url of current user
    //cant pass in url anymore?
    //this.user = new Hub.UserModel({},{url: '/api/user'});
        
    this.user = new Hub.CurrentUserModel({});

    this.listenTo(this.user, 'change', this.render);
    this.user.fetch();

    //Fetch and listen for current site
    this.site = new Hub.SiteModel();
    this.listenTo(this.site, 'change', this.render);
    this.site.fetch();
          
    //Cache pages target
    this.$pages = this.$('#pages');
      
    //Show menu if big enough
    if($(window).width()>992){
      this.$el.addClass('menu-open');
    }
    


    //Hide loader
    window.setTimeout(function(){this.$('#loader').fadeOut(400)},1000);
  },

  render: function() {
    
    //Update content in place do not re-render whole page
    //this.$('#menu_user_name').text(this.user.get('name'));

    //Render Menu
    this.$('#menu').html(HandlebarsTemplates['menu']({user:this.user.toJSON()}));
    
    //Bootstrap tooltips
    this.$('#menu [data-toggle="tooltip"]').tooltip({trigger:'manual'});    
    
    return this;
  }

});
