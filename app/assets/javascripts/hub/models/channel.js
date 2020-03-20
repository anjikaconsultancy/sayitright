var Hub = Hub || {};

Hub.ChannelModel = Backbone.Model.extend({
  collection: Hub.ChannelCollection,
  urlRoot: '/api/channels'
});

Hub.ChannelCollection = Backbone.Collection.extend({
  model: Hub.ChannelModel,
  url:'/api/channels'
});