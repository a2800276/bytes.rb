
class Bitstring < String
  
  # Bitwise AND
  def & other
    _go :&, other
  end
  
  # Bitwise OR 
  def | other
    _go :|, other
  end
 
  # Bitwise XOR
  def ^ other
    _go :^, other
  end 

  # ===Internal.
  # This function executes the bitwise functions
  def go mes, other
    check(other)
    b = Bitstring.new
    0.upto(length-1) {|i|
      b.concat(self[i].send(mes, other[i]))
    }
    b
  end
  
  # One's complement, each bit is flipped.
  def ~@
    b = Bitstring.new
    each_byte { |byte|
      b.concat [~byte].pack("C")
    }
    b
  end
  
  # Shift the String +num+ (bit) positions to the left.
  # (to the right, in case +num+ is negative)
  def << num
    if num < 0 
      self.>> -num
    end

    bytes_to_shift = num / 8
    bits_to_shift  = num % 8 
    
    new_string = Bitstring.new("\x00"*length)
    carry = 0x00
    (length-1).downto(0) {|i|
      new_b         = (self[i] << bits_to_shift)
      new_string[i] = (new_b & 0xff)
      new_string[i] = (new_string[i] | carry)
      carry         = (new_b >> 8) 
    }

    new_string.concat "\x00"*bytes_to_shift
    Bitstring.new(new_string[-length, length])
  end

  # Shift the String +num+ (bit) positions to the right.
  # (to the left, in case +num+ is negative)
  def >> num
    if num < 0
      self.<< -num
    end

    bytes_to_shift = num / 8
    bits_to_shift  = num % 8

    new_string = Bitstring.new
    mask  = 0xff >> (8-bits_to_shift)
    carry = 0

    0.upto(length-1) {|i|
      new_string.concat(self[i] >> bits_to_shift)
      new_string[i] = new_string[i] | carry
      carry = (self[i] & mask) << (8-bits_to_shift)
    }
    new_string.insert(0, "\x00" * bytes_to_shift)
    Bitstring.new(new_string[0, length])
  end
  
  # Start counting at 0, left to right.
  # Determine the +i+th bit of this String, starts counting
  # at 0. MSB is bit 0.
  #
  # ===Example
  #   b = Bitstring.new("\xF0\xF0") 
  #   b.bit(0)    # => 1
  #   b.bit(4)    # => 0
  #   b.bit(8)    # => 1
  #   b.bit(15)   # => 0
  #   b.bit(16)   # => RuntimeError: Out of range
  
  def bit i
    byte = i/8
    mask = 0x80 >> (i%8)
    raise "Out of range" if byte > length-1
    
    (self[byte] & mask) == mask ? 1 : 0 
  end

  # Iterates over each bit in the String, passing 0 or 1
  # to the supplied block.
  def each_bit 
    0.upto(length*8) {|i|
      yield bit(i)
    }
  end
  
  # Returns a bit representation of the String.
  #
  # === Example
  #
  #   b = Bitstring.new("\xF0\xF0") 
  #   b.bits    # => "1111000011110000"
  def bits 
    str = ""
    self.each_byte{|byte|
      str << ("%08b"%byte)
    }
    str
  end

  def to_i base=:literal
    return super unless base == :literal
    i = 0
    0.upto(length-1){|n|
      i <<= 8
      i |=  self[n]
    }
    return i

  end
  
  def inspect
    str = "\""
    self.each_byte {|b|
      str << ("\\x%02x" % b)
    }
    str << "\""
  end

  def check other
    raise "wrong class" unless other.is_a? String
    raise "incorrect length" unless other.length == self.length
  end
end

if $0 == __FILE__
  b = Bitstring.new("\x31"*8)
  puts b
  puts ~(~b)
  puts (b & ~b)

  b2= b << 1
  puts b.bits
  puts b2.bits
  b2= b << 8
  puts b2.bits
  b2= b << 15
  puts b2.bits
  b2= b << 16
  puts b2.bits
  b2= b2 >> 16
  puts b2.bits
  
  b.each_bit {|bit|
    puts bit
  }

  b3 = Bitstring.new("\xFF")
  puts "--#{b3.to_i}"
  b3 = Bitstring.new("\x01\x00")
  puts "--#{b3.to_i}"

  b3 = Bitstring.new("\x01\x00"*20)
  puts b2.to_i

  puts b2.inspect
end
