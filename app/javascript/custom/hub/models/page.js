var Hub = Hub || {};

Hub.PageModel = Backbone.Model.extend({
  collection: Hub.PageCollection,
  urlRoot: '/api/pages'
});

Hub.PageCollection = Backbone.Collection.extend({
  model: Hub.PageModel,
  url:'/api/pages'
});