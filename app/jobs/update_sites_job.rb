class UpdateSitesJob # < Struct.new(:empty)
  def perform
    # Just re-save all sites they will update themselves
    Site.all.each do |site|
      puts "Updating Site #{site.id}"
      site.save
    end
  end
  
  def failure
  end
end