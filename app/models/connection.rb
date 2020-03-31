class Connection
  include Mongoid::Document
  include ActiveModel::ForbiddenAttributesProtection
  
  # Polymorphic embedded in site, channel or station
  embedded_in :connectable, polymorphic: true

  # Who is authorised to post  
  belongs_to :site, class_name: 'Site', inverse_of: nil
  belongs_to :user, class_name: 'User', inverse_of: nil

  # Do they require moderation
  field :moderated, type: Boolean, default: true  
  
end
