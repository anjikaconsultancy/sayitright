var Hub = Hub || {};

Hub.ClipModel = Backbone.Model.extend({
  collection: Hub.ClipCollection,
  urlRoot: '/api/clips'
});

Hub.ClipCollection = Backbone.Collection.extend({
  model: Hub.ClipModel,
  url:'/api/clips'
});