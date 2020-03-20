collection @programs

node(:id) { |o| o.id.to_s }
attributes :name, :title, :preview_url, :preview_original, :image_url

node(:path){|p| program_path(p.path)}
node(:publish_at){|this| this.publish_at.to_formatted_s(:long)}

node(:description){|p| Sanitize.clean(p.description).truncate(128, :separator => ' ', :omission => '...') }
node(:total) { @programs.total_count }
node(:page) { @programs.current_page }
node(:pages) { @programs.num_pages }
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
