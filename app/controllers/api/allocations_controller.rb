class Api::AllocationsController < Api::AccessController
  # return a list of allocations this user is allowed to apply to programs
  def index
    if current_user.role != :user
      @allocations = []

      # Current site allocation
      @allocations << OpenStruct.new({site: OpenStruct.new({id: current_site.id, link: root_url(:host=>current_site.custom_host), title: current_site.title})})

      # Current sites Channel allocations
      channels = current_site.channels_for_role(current_user.role)
      channels.each do |channel|
        if channel.public || channel.site_id == current_site.id
          title = [:draft, :hidden].include?(channel.status) ? "#{channel.title} [#{channel.status}]" : channel.title
          @allocations << OpenStruct.new({
             site: OpenStruct.new({id: current_site.id, link: root_url(:host=>current_site.custom_host), title: current_site.title}),
             channel: OpenStruct.new({id: channel.id, link: channel_url(channel.path,:host=>current_site.custom_host), title: title})
          })          
        end
      end
      
      # All sites where this site is networked
      Site.all.elem_match(connections: { site_id: current_site.id,  user_id: nil }).each do |site|
        # site allocation
        @allocations << OpenStruct.new({site: OpenStruct.new({id: site.id, link: root_url(:host=>site.custom_host), title: site.title})})

        # sites Channel allocations
        channels = site.channels_for_role(current_user.role)
        channels.each do |channel|
          title = [:draft, :hidden].include?(channel.status) ? "#{channel.title} [#{channel.status}]" : channel.title
          if channel.public || channel.site_id == current_site.id
            @allocations << OpenStruct.new({
               site: OpenStruct.new({id: site.id, link: root_url(:host=>site.custom_host), title: site.title}),
               channel: OpenStruct.new({id: channel.id, link: channel_url(channel.path,:host=>site.custom_host), title: title})
            })          
          end

        end
  
      end
      respond_with(@allocations)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end     
  end
end
