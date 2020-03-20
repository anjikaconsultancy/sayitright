xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", "xmlns:media" => "http://search.yahoo.com/mrss/", "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd", "xmlns:image" => "http://purl.org/rss/1.0/modules/image/", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:ibmwcm" => "http://purl.org/net/ibmfeedsvc/wcm/1.0"  do
  xml.channel do
    xml.title current_site.title
    xml.description current_site.summary 
    xml.link root_url   
    
    @programs.items.each do |program|      
      xml.item do                      
        xml.guid program.path
        xml.title program.title
        xml.description Sanitize.clean(program.description).truncate(128, :separator => ' ', :omission => '...')
        xml.itunes :image, href: program.preview_url 
        xml.media :content, url: program.preview_resize_url(params[:media_width].present? ? params[:media_width] : '640',params[:media_height].present? ? params[:media_height] : '360','crop'), medium: 'image'        
        
        xml.pubDate program.publish_at.strftime('%a, %d %b %Y %H:%M:%S %z')
        xml.author "#{program.user.email}"+ " " +"(#{program.user.name})"         
                 
        if @channel
          xml.link program.rel.present? ? program.rel : channel_program_url(@channel.path,program.path(current_site))
        else
          xml.link program.rel.present? ? program.rel : program_url(program.path(current_site))
        end        
      end
    end 

    xml.ibmwcm :count, @programs.count
    xml.ibmwcm :page, @programs.page
    xml.ibmwcm :pages, @programs.pages  
    

    if @programs.pages > @programs.page
      xml.ibmwcm :next_page, programs_url(:page=>@programs.page+1)
    end

    if @programs.page > 1
      xml.ibmwcm :previous_page, programs_url(:page=>@programs.page-1)
    end         
  end
end