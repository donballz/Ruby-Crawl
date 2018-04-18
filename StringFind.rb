require 'openssl'

class String

	def find(instr, start=0)
		found = self.index(instr, start)
		return -1 if found == nil
		return found + instr.length()
	end
	
	def each
    	self.split("").each { |i| yield i }
  	end
  	
  	  def encrypt(key)
		cipher = OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt
		cipher.key = key
		s = cipher.update(self) + cipher.final

		s.unpack('H*')[0].upcase
	  end

	  def decrypt(key)
		cipher = OpenSSL::Cipher.new('DES-EDE3-CBC').decrypt
		cipher.key = key
		s = [self].pack("H*").unpack("C*").pack("c*")

		cipher.update(s) + cipher.final
	  end

end
