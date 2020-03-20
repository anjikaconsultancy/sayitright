#I18n.exception_handler = lambda do |exception, locale, key, options|
#  case exception
#  when I18n::MissingTranslationData
#    key.split(".").last.humanize
#    #key.humanize
#  else
#    raise exception
#  end
#end

#:rescue_format => :html

#module I18n
#  def self.handle_missing_translations(*args)
#    raise args.first
#  end
#end
# MissingTranslationData

#I18n.exception_handler = :handle_missing_translations