ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'database_cleaner'


class ActiveSupport::TestCase
  
  setup { 

    # Clean the db
    DatabaseCleaner.orm = "mongoid" 
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean

    # Clear Mongoid cache
    Mongoid::IdentityMap.clear
        
    # Clean the memcache
    Rails.cache.clear
    
    # Clear the indextank
    indextank = IndexTank::Client.new ENV['INDEXTANK_API_URL']
    tindex = indextank.indexes "#{Rails.env}_things"
    tindex.delete_by_search "announced:true"
    
    #docids = []
    
    #s = tindex.search("announced:true",:len=>5000,:fetch => "type,name")
    #puts s.inspect
    #s['results'].each {|doc|
    #  docids << doc['docid']
    #}
    #tindex.bulk_delete(docids) unless docids.blank?
          
    puts "\n---- #{self.class.name} - #{self.method_name} ----\n"
  }

    


end