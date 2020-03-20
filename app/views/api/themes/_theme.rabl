# We don't sent id's for new models, or create tries to find the nested embeds models
node(:id, :if=>@theme.persisted?) { |o| o.id.to_s }

attributes :title, :description,:template,:availability,:editable,:options,:formats,:syntax