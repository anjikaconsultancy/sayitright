var Hub = Hub || {};

Hub.ProgramModel = Backbone.Model.extend({
  collection: Hub.ProgramCollection,
  urlRoot: '/api/programs'
});

Hub.ProgramCollection = Backbone.Collection.extend({
  model: Hub.ProgramModel,
  url: function() {
    return '/api/programs' + '?' + $.param({page: this.page});
  },
  pageInfo: function() {
    if(this.models.length > 0){
      this.total = this.total ? this.total : this.models[0].attributes.total;
      this.page  = this.page ? this.page : this.models[0].attributes.page;
      this.pages = this.pages ? this.pages : this.models[0].attributes.pages;
      var info = {
        total: this.total,
        page: this.page,
        pages: this.pages,
        prev: false,
        next: false
      };

      if(this.page > 1){
        info.prev = true
      }else{
        info.prev = false
      }

      if(this.page < info.pages){
        info.next = true
      }else{
        info.next = false
      }
      return info;
    }
  },
  nextPage: function() {
    if (!this.pageInfo().next) {
      return false;
    }
    this.page = this.page + 1;
    return this.fetch();
  },
  previousPage: function() {
    if (!this.pageInfo().prev) {
      return false;
    }
    this.page = this.page - 1;
    return this.fetch();
  },
  currentPage: function(page_no) {
    page_no = parseInt(page_no)
    if (page_no > this.pageInfo().pages) {
      return false;
    }
    this.page = page_no;
    return this.fetch();
  }

});