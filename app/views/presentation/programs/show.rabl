object false => :response

extends "presentation/base"

child @channel do
  node(:id) { |o| o.id.to_s }
  attributes :name, :title

  node("is_#{@channel.id}"){true}
    
end

child @program do
  node(:id) { |o| o.id.to_s }
  attributes :name, :title, :playlist, :tags, :preview_url, :preview_original, :image_url, :rel, :language

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
  
  node(:tags) do |this|
    this["tags"] #getter returns a string, we want the array
  end
  
  child @program.site do
    node(:id) { |o| o.id.to_s }
    attributes :host, :title, :description, :icon_image_url, :logo_image_url, :icon_image_origianl, :logo_image_original
    node(:url) do |this|
      root_url(:host => this.custom_host, protocol: 'http')
    end
  end

  child @program.user do
    node(:id) { |o| o.id.to_s }
    attributes :name, :avatar_image_url, :header_image_url, :avatar_image_original, :header_image_original
    node(:bio){|p| Sanitize.clean(p.bio) }
    
    # node(:path){|p| user_path(p.path)}  Add path back when we can show networked users in local site
    node(:url){|p| user_url(p.path,:host=>p.site.custom_host)}  

  end  
  
  node(:publish_at) do |this| 
    {
      :full_date=>this.publish_at.strftime("%A, #{this.publish_at.day.ordinalize} %B %Y - %l:%M%p"),
      :short_date=>this.publish_at.strftime("%m/%d/%Y"),
      :short_time=>this.publish_at.strftime("%T")      
    }
  end

  node("is_#{@program.id}"){true}

  node(:description){|p| Sanitize.clean(p.description).truncate(128, :separator => ' ', :omission => '...') }

  node(:summary){|p| Sanitize.clean(p.summary) }

  #path is relative link on this site
  node(:path){|p| program_path(p.path(current_site))}  
  
  #url is absolute url on original site
  node(:url){|p| program_url(p.path,:host=>p.site.custom_host)}  

  #playlist is an absolute url on this site  
  node(:playlist, :if=>lambda { |p| p.has_segments? }) do |p|
    %Q|<iframe src="#{program_playlist_url(p.path(current_site))}" style="min-width:400;min-height:400;" allowTransparency seamless webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>|
  end 
  
  child({@program.segments=>"segments"},:if=>lambda { |this| this.has_segments? }) do
    node(:id) { |o| o.id.to_s }
    attributes :position,:kind,:content,:url
    node(:embed_url, :if=>lambda {|this| this.kind==:external}) { |o|
      "https://cdn.iframe.ly/api/iframe?api_key=#{ENV['IFRAMELY_API_KEY']}&url=#{o.url}"
    }
    child :clip, :if=>lambda { |this| this.has_clip? } do
      node(:id) { |o| o.id.to_s }
      attributes :status, :encoded, :kind, :width,:height,:duration
      node(:image_url) { |o| o.limit_1920_url }
      node(:video, :if=>lambda {|this|this.kind==:video}) do  |this|
        {
        :hq_url => "//#{ENV['S3_CLOUD_FRONT']}/clips/#{this.id}/hls.m3u8",
        :dq_url => "//#{ENV['S3_CLOUD_FRONT']}/clips/#{this.id}/hq.mp4",
        :mq_url => "//#{ENV['S3_CLOUD_FRONT']}/clips/#{this.id}/mq.mp4",
        :lq_url => "//#{ENV['S3_CLOUD_FRONT']}/clips/#{this.id}/lq.mp4",
        :sq_url => "//#{ENV['S3_CLOUD_FRONT']}/clips/#{this.id}/sq.mp4"
        }
      end
    end
  end    
  
  node :content do |p|
    p.fragments.each_with_object("") do |f,o|
      case f.kind
      when :clip
        case f.clip.kind
        when :video
          if f.clip.encoded
            o << %Q|<div style="position:relative;padding-bottom: #{(f.clip.height.to_f/f.clip.width.to_f)*100.0}%;padding-top:0;height:0;overflow:hidden;"><iframe style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;" src="#{program_element_path(p.path,f.id)}" allowTransparency seamless webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe></div>|
          end
        when :image
          if f.clip.encoded
            if f.content.present?              
              o << %Q|<figure><a href="#{f.clip.image_url}" target="image"><img src="#{f.clip.limit_1920_url}"></a><figcaption>#{Sanitize.clean(f.content,Sanitize::Config::BASIC)}</figcaption></figure>|
            else
              o << %Q|<figure><a href="#{f.clip.image_url}" target="image"><img src="#{f.clip.limit_1920_url}"></a></figure>|
            end          
          end
        else
          o << %Q|<div><a href="#{f.clip.original_url}>Download</a></div>|
        end
      when :text
        sanitize = { :elements => ['a', 'p','h3','b','i','u','strong','em','ol','ul','li','strike','blockquote','pre','sub','sup'], :attributes => {'a' => ['href', 'title']}, :protocols => {'a' => {'href' => ['http', 'https', 'mailto']}}}

        o << %Q|<div>#{Sanitize.clean(f.content,sanitize)}</div>| 
      when :external
        o << %Q|<script src="https://cdn.iframe.ly/embed.js?api_key=#{ENV['IFRAMELY_API_KEY']}"></script>|
        o << %Q|<div><div>#{f.content}</div><a href="#{f.url}" data-iframely-url></a></div>|
      end
    end
  end
end