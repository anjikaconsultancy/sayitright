xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", "xmlns:content"=>"http://purl.org/rss/1.0/modules/content/", "xmlns:media" => "http://search.yahoo.com/mrss/", "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd", "xmlns:image" => "http://purl.org/rss/1.0/modules/image/", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:ibmwcm" => "http://purl.org/net/ibmfeedsvc/wcm/1.0"  do
  xml.channel do
    xml.title @channel.title
    xml.description @channel.summary 
    xml.link channel_url(@channel.path)
    xml.image do
      xml.title @channel.title
      xml.url @channel.preview_url
      xml.link root_url
    end  

    @programs.items.each do |program|      
      xml.item do                      
        xml.guid program.path
        xml.title program.title
        xml.description Sanitize.clean(program.description).truncate(128, :separator => ' ', :omission => '...')
        xml.itunes :image, href: program.preview_url
        xml.media :content, url: program.preview_resize_url(params[:media_width].present? ? params[:media_width] : '640',params[:media_height].present? ? params[:media_height] : '360','crop'), medium: 'image'        
        
        xml.pubDate program.publish_at.strftime('%a, %d %b %Y %H:%M:%S %z')                 
                 
        if @channel
          xml.link program.rel.present? ? program.rel : channel_program_url(@channel.path,program.path(current_site))
        else
          xml.link program.rel.present? ? program.rel : program_url(program.path(current_site))
        end
        xml.content :encoded do
          xml.cdata! <<-HTML
#{
program.segments.each_with_object("") do |f,o|
  case f.kind
  when :clip
    case f.clip.kind
    when :video
      if f.clip.encoded
        o << %Q|<a href="#{program.rel.present? ? program.rel : @channel.present? ? channel_program_url(@channel.path,program.path(current_site)) : program_url(program.path(current_site))}"><img style="width:100%;max-width:100%;" src="#{f.clip.limit_1920_url}"></a>|        
      end
    when :image
      if f.clip.encoded
        if f.content.present?              
          o << %Q|<a href="#{program.rel.present? ? program.rel : @channel.present? ? channel_program_url(@channel.path,program.path(current_site)) : program_url(program.path(current_site))}"><img style="width:100%;max-width:100%;" src="#{f.clip.limit_1920_url}"><span>#{Sanitize.clean(f.content,Sanitize::Config::BASIC)}</span></a>|
        else
          o << %Q|<a href="#{program.rel.present? ? program.rel : @channel.present? ? channel_program_url(@channel.path,program.path(current_site)) : program_url(program.path(current_site))}"><img style="width:100%;max-width:100%;" src="#{f.clip.limit_1920_url}"></a>|
        end          
      end
    end  
  end
end
}
#{
program.fragments.each_with_object("") do |f,o|
  case f.kind
  when :clip
    case f.clip.kind
    when :video
      if f.clip.encoded
        o << %Q|<a href="#{program.rel.present? ? program.rel : @channel.present? ? channel_program_url(@channel.path,program.path(current_site)) : program_url(program.path(current_site))}"><img style="width:100%;max-width:100%;" src="#{f.clip.limit_1920_url}"></a>|        
      end
    when :image
      if f.clip.encoded
        if f.content.present?              
          o << %Q|<a href="#{program.rel.present? ? program.rel : @channel.present? ? channel_program_url(@channel.path,program.path(current_site)) : program_url(program.path(current_site))}"><img style="width:100%;max-width:100%;" src="#{f.clip.limit_1920_url}"><span>#{Sanitize.clean(f.content,Sanitize::Config::BASIC)}</span></a>|
        else
          o << %Q|<a href="#{program.rel.present? ? program.rel : @channel.present? ? channel_program_url(@channel.path,program.path(current_site)) : program_url(program.path(current_site))}"><img style="width:100%;max-width:100%;" src="#{f.clip.limit_1920_url}"></a>|
        end          
      end
    end  
  when :text
    sanitize = { :elements => ['a', 'p','h3','b','i','u','strong','em','ol','ul','li','strike','blockquote','pre','sub','sup'], :attributes => {'a' => ['href', 'title']}, :protocols => {'a' => {'href' => ['http', 'https', 'mailto']}}}
    o << %Q|<div>#{Sanitize.clean(f.content,sanitize)}</div>| 
  end
end
}
HTML
        end
      end       
    end 
    xml.ibmwcm :count, @programs.count
    xml.ibmwcm :page, @programs.page
    xml.ibmwcm :pages, @programs.pages    

    if @programs.pages > @programs.page
      xml.ibmwcm :next_page, channel_programs_url(@channel.path,:page=>@programs.page+1)
    end

    if @programs.page > 1
      xml.ibmwcm :previous_page, channel_programs_url(@channel.path,:page=>@programs.page-1)
    end           
  end
end