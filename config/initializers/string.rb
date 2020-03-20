class String
  #return terms for search indexing
  #we first clean punctuation, then split into word boundries, suitable for most languages and then simple stemming with singularize
  #however, cjk chinese etc need to be split on character boundries so we do quick dirty 2 char splits, maybe need to do the same with 1 char offset or change to 1 char split
  #we then get a frequency map, the least frequently used words/characters is what we keep for indexing!
  #this splits on unicode word boundry and letters, counts frequency, sorts by least frequent and returns array
  #you can then just grab the first n array items depending on how big your index needs to be

  
  STOP_WORDS = %w(a am an as at all also and any be by do go he i if in is it its me my no of on or so to un up us we was the this)

  def terms

    s = self.downcase.gsub(/\p{P}/u,'').squish

    #\p{InCJK_Unified_Ideographs} - tried [\u4E00-\u9FFF] - only chinese?
    #(\p{Han}|\p{Katakana}|\p{Hiragana}\p|{Hangul}) - seems to work
    #we also reject any word > 20 chars to loose any huge blocks of cjk text
    #p{L}+ was w+ it now seems to split words if they have numbers in them etc.
    #ORDER IS IMPORTANT, ANY LETTER OR WORD IS GREEDY SO LEAVE TILL LAST
    (s.scan(/\p{Han}{2}|\p{Katakana}{2}|\p{Hiragana}{2}|\p{Hangul}{2}|\p{N}+|\p{L}+|w+/u)-STOP_WORDS).map(&:singularize).reject{|i|i.blank?||i.length>20}.inject(Hash.new 0){|c, w|c[w]+=1;c}.sort{|a,b|a[1]<=>b[1]}.map{|a|a[0]}
  end
end