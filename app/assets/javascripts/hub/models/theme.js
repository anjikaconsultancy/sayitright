var Hub = Hub || {};

Hub.ThemeModel = Backbone.Model.extend({
  collection: Hub.ThemeCollection,
  urlRoot: '/api/themes'  
});

Hub.ThemeCollection = Backbone.Collection.extend({
  model: Hub.ThemeModel,
  url:'/api/themes'
});