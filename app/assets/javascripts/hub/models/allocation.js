var Hub = Hub || {};

Hub.AllocationModel = Backbone.Model.extend({
  collection: Hub.AllocationCollection,
  urlRoot: '/api/allocations'
});

Hub.AllocationCollection = Backbone.Collection.extend({
  model: Hub.AllocationModel,
  url:'/api/allocations'
});