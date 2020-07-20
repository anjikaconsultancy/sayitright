module Presentation::AccessHelper

  def current_site
    return @current_site if @current_site.present?

    if params[:site_host].present?
      # Switch site
      @current_site = nil
      session[:site_host] = params[:site_host]
    end

    if defined? @current_site and @current_site.present?
      @current_site
    else
      if session[:site_host].present?
        # Grab the site from a session id
        @current_site = Site.find_by(host: session[:site_host])
      else
        # Count parts so we can detect subdomain on either .com .co.uk etc.
        parts = ENV['DEFAULT_HOST'].count "."
        sub_domain = request.subdomain(parts)
        if request.domain(parts) == ENV['DEFAULT_HOST'] and sub_domain != "www"
          @current_site = Site.find_by(host: request.subdomain(parts))
        else
          #Site.elem_match(domains: { host: domain.host})
          @current_site = Site.find_by(:domains.elem_match => { host: request.host })
        end
        @current_site = Site.first if @current_site.blank?
      end
    end
    puts "==============================================================="
    puts "#{ENV['DEFAULT_HOST']}"
    puts "#{parts}"
    puts "#{sub_domain}"
    puts "#{request.host}"
    puts "#{@current}"
    puts "==============================================================="
    return @current_site
  end
end
