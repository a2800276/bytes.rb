require 'test/unit'
require 'bytes_abound'

class Test_X < Test::Unit::TestCase

class D
  def method_missing m, *args
    :still_works
  end
end
class C < D
  include X
  def test
    x1234
  end
end

class E 
  include X
  def __method_missing m, *args
    :also_works
  end
end

class F < String
  include X
end



def test_basics	
  c = C.new
  assert_equal("\x12\x34", c.test)  
  assert_equal(String, c.test.class)
  assert_equal("\x34\x56", c.x3456)
  x = X::X.new("\xab")
  assert_equal("\xab", x)
  x2 = x.xcd
  assert_equal("\xab", x)
  assert_equal("\xab\xcd", x2)
end 

def test_include
  c = C.new
  assert_equal(:still_works, c.some_crap_method)
  d = E.new
  assert_equal("\x98", d.x98)
  assert_equal(:also_works, d.boring_method)
end

def test_hex
  x = X.x23
  assert_equal("\x23", x)
  assert_equal("\x23\x45", x.x45)
  assert_equal("\x23\x45\x67\xab", x.x45.x67.xab)
  assert_equal("\x23\x45\x67\xab", x.x45_x67_xab)
  assert_equal("\x23\x45\x67\xab", x.x45_67_ab)
  assert_equal("\x23\x45\x67\xab", x.x45x67xab)
  assert_equal("\x23\x45\x67\xab", x.x4567ab)
  assert_equal("\x23", x)
  assert_raises(RuntimeError) {
    x.xababa
  }
  assert_raises(NoMethodError) {
    x.xababag
  }
end

def test_binary
  b = X.b11111111
  assert_equal("\xff", b)
  assert_equal("\xff\xff", b.b1111_1111)
  assert_equal("\xff\xff", b.b1111b1111)
  assert_equal("\xff\xff\x00", b.b11111111.b00000000)
  assert_raises(RuntimeError) {
    b.b11111111.b0000001
  }
  assert_raises(NoMethodError) {
    b.baaaa0000.b0000001
  }
  assert_equal("\xff", b)
end

def test_octal
end

def test_chaining
  f = F.new # extends String
  x = f.x23
  assert(x.is_a? F)
  x2 = f.x45.xab.b11111111
  assert_equal(F, x2.class)

  c = C.new
  assert_equal("\x12\x34", c.test)  
  assert_equal(String, c.test.class)
end

def test_bitstring
  
  x1 = X.xf0
  x2 = X.x0f
  x3 = x1 | x2
  assert_equal "11111111", x3.bits
  x4 = x3 & x2
  assert_equal x2, x4
  x5 = X.xf0f0f0
  assert_equal "\x0f\x0f\x0f", ~x5

  
end

end
