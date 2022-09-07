class BenInteger < Struct.new(:value); end
class BenString < Struct.new(:length, :value); end
class BenList < Struct.new(:elements); end
class BenDict < Struct.new(:elements); end

class InvalidTokenError < StandardError
  def initialize(msg)
    super msg
  end
end

def parseAll(str)
  tokens = []
  until str == ""
    str,tok = parse(str)
    tokens << tok
  end

  return tokens
end

def parse(str)
  tok = nil
  case 
  when isNumber(str)
    str, tok = parseNumber(str)
  when isByteString(str)
    str,tok = parseByteString(str)
  when isList(str)
    str,tok = parseList(str)
  when isDict(str)
    str,tok = parseDict(str)
  else
    raise InvalidTokenError.new("Could not parse the following #{str}")
  end

  return str,tok
end


def isNumber(str)
  str[0] == "i"
end

def isByteString(str)
  str =~ /^\d+/
end

def isList(str)
  str[0] == "l"
end

def isDict(str)
  str[0] == "d"
end

def parseNumber(str)
  i = 1
  number = ""
  until str[i] == "e"
    number += str[i]
    i+=1
  end

  begin 
    number = Integer(number)
  rescue
    throw new InvalidTokenError "Could not parse #{number} as an Integer"
  end

  return [str[i+1,str.length-1], BenInteger.new(number)]
end

def parseByteString(str)
  length = getByteStringLength(str).to_i
  bytestring = ""
  str = str[length.to_s.length+1..]
  bytestring = str[0,length]
  
  return [str[length..],BenString.new(length,bytestring)]
end

def parseList(str)
  str, tokens = parseEnumerable(str)
  return [str, BenList.new(tokens)]
end

def parseDict(str)
  str, tokens = parseEnumerable(str)
  return [str, BenDict.new(tokens)]
end

def parseEnumerable(str)
  tokens = []
  str = str[1..]
  until str[0] == "e"
    str,tok = parse(str)
    tokens << tok
  end

  return [str[1..],tokens]
end

def getByteStringLength(str)
  match = str.match /^(\d+):/
  if match.nil?
    throw new InvalidTokenError "Invalid Bytestring length"
  else
    return match[1]
  end
end

p parseAll(File.read("bentest.txt"))