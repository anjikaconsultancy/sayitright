# encoding: UTF-8

require 'test_helper'

class StringTest < ActionController::IntegrationTest

  
  test "terms extraction" do
    #http://www.columbia.edu/kermit/utf8.html
    #puts s.downcase.gsub(/\P{L}/,'')
    #puts "Hello You, this is a little test's for4you! ok55here 500 numbers".terms.length
    assert "Hello You, this is a little test's for4you! ok55here 500 numbers".terms.length > 5

    #autotest is breaking on unicode so dont write it anywhere
    #puts "能".length
    #puts "I can eat glass and it doesn't hurt me.".terms.length
    #puts "काचं शक्नोम्यत्तुम् । नोपहिनस्ति माम् ॥".terms.length
    #puts "Μπορώ να φάω σπασμένα γυαλιά χωρίς να πάθω τίποτα.".terms.length
    #puts "Je peux manger du verre, ça ne me fait pas mal.".terms
    #puts "मैं काँच खा सकता हूँ और मुझे उससे कोई चोट नहीं पहुंचती".terms.length
    #puts "你好，这是一个快速测试".terms
    assert "你好，这是一个快速测试".terms.length > 4,"chinese"
    assert "안녕하세요 빠른 테스트입니다".terms.length > 5,"korean"
    assert "こんにちは、これは簡単なテストです".terms.length > 5 ,"jap"
    assert "qwertyuiopasdfghjklzxcvbnm".terms.length ==0 ,"should reject too long"
  end
  
end