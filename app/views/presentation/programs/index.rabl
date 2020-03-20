object false => :response

extends "presentation/base"

child @station do
  node(:id) { |o| o.id.to_s }
  attributes :name, :title
  node("is_#{@station.id}"){true}

  child @station.pages do
    node(:id) { |o| o.id.to_s }
    attributes :name, :title
    node(:path){|page| page_path(page.path)}
  end   
end

child @channel do
  node(:id) { |o| o.id.to_s }
  attributes :name, :title

  node("is_#{@channel.id}"){true}
    
end


child(:programs) do
  child @programs.items=>:program do |program|
    node(:id) { |o| o.id.to_s }
    attributes :id, :name, :title, :status, :tags, :preview_url, :preview_original, :image_url

    node(:author) do |program|           
      {
        :id=>program.user.id,
        :name=>program.user.name,
        :bio=>program.user.bio,
        :website=>program.user.website,
        :avatar_image_original=>program.user.avatar_image_original,
        :avatar_image_url=>program.user.avatar_image_url       
      }
    end 
    node(:description){|p| Sanitize.clean(p.description).truncate(256, :separator => ' ', :omission => '...') }

    node(:publish_at) do |this| 
      {
        :full_date=>this.publish_at.strftime("%A, #{this.publish_at.day.ordinalize} %B %Y - %l:%M%p"),
        :short_date=>this.publish_at.strftime("%m/%d/%Y"),
        :short_time=>this.publish_at.strftime("%T")
      }
    end

  
    node(:path) do |program| 
      if @channel
        channel_program_path(@channel.path,program.path(current_site))
      else
        program_path(program.path(current_site))
      end
    end

    node :previews, :if => lambda { |m| m.has_preview? } do |program|
      {
        :limit_1920_url  => program.preview.limit_1920_url,
        :limit_960_url  => program.preview.limit_960_url,
        :crop_160x90_url  => program.preview.crop_160x90_url,
        :crop_320x180_url => program.preview.crop_320x180_url,
        :crop_480x270_url => program.preview.crop_480x270_url,
        :crop_640x360_url => program.preview.crop_640x360_url,
        :crop_1280x720_url => program.preview.crop_1280x720_url,
        :crop_1920x1080_url => program.preview.crop_1920x1080_url
      }
    end
  end
  
  node(:count){@programs.count}
  node(:page){@programs.page}
  node(:pages){@programs.pages}
  node(:next_page, :if=>lambda{|this|@programs.pages > @programs.page}){programs_path(:page=>@programs.page+1)}
  node(:previous_page, :if=>lambda{|this|@programs.page > 1}){programs_path(:page=>@programs.page-1)}

end