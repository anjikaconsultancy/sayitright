var Hub = Hub || {};

Hub.UserModel = Backbone.Model.extend({
  collection: Hub.UserCollection,
  urlRoot: '/api/users'  
});

Hub.UserCollection = Backbone.Collection.extend({
  model: Hub.UserModel,
  url:'/api/users'
});

//We used to be able to send the url into UserModel to get the current user but it dont work in latest backbone?
Hub.CurrentUserModel = Backbone.Model.extend({
  url: '/api/user'  
});