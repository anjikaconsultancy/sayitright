class Allocation
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::ForbiddenAttributesProtection

  embedded_in :program
  
  # Can be listed on a site or site and channel
  # - You must also set the parent heirachy e.g. :site or :site and :channel
  belongs_to :site
  validates_presence_of :site_id
  
  belongs_to :channel

  validate :channel_is_public_or_owned_by_site 

  def channel_is_public_or_owned_by_site
    if (channel && channel.public) || (channel && channel.site_id == site_id) || channel == nil # TODO: Publicity on Sites
      true
    else
      errors.add(:site_id, "is the only site that can create allocations on this channel")
    end
  end

  # Status - state which can be set depending on users permissions
  # :disabled - this program has been disabled by the owner and may not be shown at this location
  # :blocked - this program has been blocked by the site and may not be shown at this location 
  # :shared - this program has been shared by the owner, but needs moderation
  # :published - this program has been accepted and published at this location
  STATES = [:disabled,:blocked,:shared,:published,'disabled','blocked','shared','published']  
  field :status, type: Symbol, default: :published
  validates_inclusion_of :status, in: Allocation::STATES
    
  # Featured priority
  field :featured, type: Integer, default: 0
   
end
