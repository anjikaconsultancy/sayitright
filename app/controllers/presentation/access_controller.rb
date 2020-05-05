class Presentation::AccessController < ApplicationController
     
  respond_to :html,:json,:xml,:pop
  
  layout nil
  
  before_action do
    # For timing this request and viewing cached pages
    @request_time = Time.now
    
    # Set cache header
    unless params[:nocache].present?
      expires_in 10.seconds, public: true
    end
  end

  before_action do
    # Disable any non-live site
    unless current_site&.status == :live
      render :text=> "Sorry, this site has been disabled. Contact support@sayitright.com form more information."
      false
    else
      true
    end
  end
  
  before_action do
    # Redirect if not on domain when present and not development server

    # Count parts so we can detect subdomain on either .com .co.uk etc.
    parts = ENV['DEFAULT_HOST']&.count "."
    sub_domain = request.subdomain(parts)
    if ENV["RACK_ENV"] != "development" and request.domain(parts) == ENV['DEFAULT_HOST'] and sub_domain != "www"
      if current_site.domains.present?
        # redirect_to request.fullpath, host: current_site.domains.first.host
        redirect_to request.protocol + current_site.domains.first.host + request.port_string + request.fullpath
      end
    end      
    
  end  

  # Our pager helper
  def pager(items,limit)
    count = items&.count
    pages = (count / limit.to_f).ceil
    # pages start at 1
    page = [[(params[:page].presence || 1).to_i,1].max,pages].min #>0 <pages
    OpenStruct.new({
      items: items&.page(page).per(limit).cache.entries,  
      count: count,
      page: page,
      pages: pages,
      limit: limit
    })
  end

    
  # When we render Rabl inline it does not get all the helpers, so wrap cloudinary in our own
  #helper_method :cdn_image_path
  
  #def cdn_image_path(source,options)
  #  Cloudinary::Utils.cloudinary_url(source, options)
  #end
  
  
  def render_rabl
    render_with({})
  end
  
  def render_footer
    footer = ""
    if current_site.google_analytics_id.present? or (current_site.network.present? and current_site.network.google_analytics_id.present?)
      footer << "<script>"
      footer << "(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){\n"
      footer << "(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),\n"
      footer << "m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)\n"
      footer << "})(window,document,'script','//www.google-analytics.com/analytics.js','ga');\n"
      
      footer << "ga('create','#{current_site.google_analytics_id}','auto',{'name':'siteTracker'});\n" if current_site.google_analytics_id.present?
      footer << "ga('create','#{current_site.network.google_analytics_id}','auto',{'name':'networkTracker'});\n" if current_site.network.present? and current_site.network.google_analytics_id.present? and current_site.host != current_site.network.host 

      footer << "ga('siteTracker.send','pageview');\n" if current_site.google_analytics_id.present?
      footer << "ga('networkTracker.send','pageview');\n" if current_site.network.present? and current_site.network.google_analytics_id.present? and current_site.host != current_site.network.host
      
      footer << "</script>\n"
    end
    return footer
  end
  
  def render_mustache(template,data)
    #This renders a mustache template and injects our footer code
    insertion_index = template&.index("</body") || template&.length
    template = template[0...insertion_index] << render_footer << template[insertion_index..-1] rescue ''
    Mustache.render(template,data) 
  end
  
  def render_with(locals)
    respond_with do |format|
      format.html { # This needs to be first for IE
        rabl = Rabl::Renderer.new("presentation/#{controller_name}/#{action_name}",nil,:locals=>locals,:scope=>self, :view_path => 'app/views', :format => 'hash').render

        if params[:theme].present?
          render html: render_mustache(Theme.find(params[:theme]).template, rabl) 
        elsif current_site.theme.present?
          render html: render_mustache(current_site.theme.template, rabl).html_safe
        else          
          render html: render_mustache(Theme.find(ENV['DEFAULT_THEME_ID']).template, rabl)
        end
      }
      format.pop {
        rabl = Rabl::Renderer.new("presentation/#{controller_name}/#{action_name}",nil,:locals=>locals,:scope=>self, :view_path => 'app/views', :format => 'hash').render
        
        render html: render_mustache(Theme.find(ENV['POPUP_THEME_ID']).template, rabl)
      }
      format.json {
        
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = '*'
        headers['Access-Control-Request-Method'] = '*'
        headers['Access-Control-Max-Age'] = '10000'
        headers['Access-Control-Allow-Headers'] = '*' #'Origin, X-Requested-With, Content-Type, Accept, Authorization'
        
        Rabl::Renderer.new("presentation/#{controller_name}/#{action_name}",nil,:locals=>locals,:scope=>self, :view_path => 'app/views', :format => 'json').render
      }
      format.xml {Rabl::Renderer.new("presentation/#{controller_name}/#{action_name}",nil,:locals=>locals,:scope=>self, :view_path => 'app/views', :format => 'xml').render}
      format.any { # This needs to be last and same as html for defaults
        rabl = Rabl::Renderer.new("presentation/#{controller_name}/#{action_name}",nil,:locals=>locals,:scope=>self, :view_path => 'app/views', :format => 'hash').render

        if current_site.theme.present?
          render html: render_mustache(current_site.theme.template, rabl)
        else          
          render html: render_mustache(Theme.find(ENV['DEFAULT_THEME_ID']).template, rabl)
        end
      }
    end    
  end
end