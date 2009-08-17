require 'lib/bitstring'

# Including this method allows you magically create hex and binary
# constants like `x2345` or `b0101_1111` out of thin air.  Being granted
# these nearly god like powers is a bit of a Faustian bargain as it
# comes at the price of being able to:
# 
# * use `method_missing` for yourself * (there are probably more
# drawback I can't think of at the moment)
# 
# In case you REALLY need to use `method_missing`, you can define it in
# a superclass, or you can call it `__method_missing` (with two leading
# underscores) instead. (Or you can think of less cludgy way to handle
# this a give me a patch.

module X

def method_missing m, *args
  if (args.length == 0) && (val = ::X._get_val(m))
    if self.is_a? String
      new_class = self.class # same as the old class
      new_class.new(self + ( new_class.new(val) ))
      # consider: more cases, either the module gets included
      # for laziness as a quick string builder, or it itself
      # is an extension of String. In that case, .x2394242 
      # shouldn't return a String, but a new instance of 
      # itself 
    else
       String.new(val) 
    end
  else
    if respond_to? :__method_missing
      __method_missing m, *args
    else
      super
    end
  end
end

class << self

  def method_missing m, *args
    # we'll handle two (three) cases:
    # .xabef01AF ...
    # (.o0123345671 ...)
    # .b01010101_01010101
    # underscores in the value are ignored, as are repititions
    # of the base id, e.g. .x31x32x33 is equivalent to .x313233
    # and .x31_32_33
    if (args.length == 0) && (val = _get_val(m))
      X.new val
    else
      super
    end
  end
  
  # not sure if this is the right behaviour:
  # if _get_val can handle thrb -e value because it doesn't consist
  # of the proper characters, e.g. xabcdefgh, it returns nil.
  # Otoh, if we determine that the value contains only valid chars, but
  # the parameter doesn't have the correct number of chars, e.g. `xabc`,
  # an exception is raised...
  def _get_val m
    str = m.to_s.gsub /_/,""
    return nil unless str =~ /^[xXoObB]/
    case str
    when /^[xX]([0-9a-fA-FxX]*)$/
      str.gsub!(/[xX]/,"")
      raise "incorrect length (str.length) for x#{str}" unless str.length%2 == 0
      [str].pack("H*")
    when /^[bB]([01bB])*$/      
      str.gsub!(/[bB]/,"")
      raise "incorrect length (str.length) for b#{str}" unless str.length%8 == 0
      [str].pack("B*")
    else
      return nil
    end
  end

end

  class X < Bitstring
    include ::X 
  end # class


end #module

  

#X::X.dingdong :a, :b, :c
#X::X.dingdong 

#puts X::X._get_val("b0011_1000__0011_0001")
#a= X::X.x3132
#puts a
#puts a.b0011_1000__0011_0001.x313233343536
#puts X::X.x32.x31.x33
