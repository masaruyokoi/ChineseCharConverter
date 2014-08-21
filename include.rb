#encoding: utf-8
require 'dbm'
require 'tokyocabinet'
require 'msgpack'


class UnihanType
  @@syms = %w(
   Nop
   Mandarin Cantonese Definition Hangul HanyuPinlu HanyuPinyin JapaneseKun
   JapaneseOn Korean Tang Vietnamese XHC1983
   CompatibilityVariant SemanticVariant SimplifiedVariant
   SpecializedSemanticVariant TraditionalVariant ZVariant
   Cangjie CheungBauer CihaiT Fenn FourCornerCode Frequency GradeLevel
   HDZRadBreak HKGlyph Phonetic TotalStrokes
  )
  cnt = 0
  @@str2sym = Hash[*@@syms.map{|s| [s, cnt+=1]}.flatten]

  def initialize(type = nil)
    self.setType(type)
  end

  def setType(type)
    @sym = nil
    if type.class == String
      @sym = @@str2sym[type]
      raise "unknown Type string #{type}" if @sym.nil?
    elsif type.class == Fixnum
      raise "unknown type id (#{type})" if @@syms[type].nil?
      @sym = type
    end
  end
  
  
  def to_num(type = nil)
    return @sym if type.nil?
    abort if type.class != String
    return val = @@str2sym[type]
  end

  def to_str(type = nil)
    return @@syms[@sym] if type.nil?
    abort if type.class != Fixnum
    return @@syms[sym]
  end
end

class UnihanReadingGetter
  def initialize()
    #@db = DBM.open('unihan_reading', 0, DBM::READER)
    @db = TokyoCabinet::HDB.new()
    @db.open('unihan.hdb', TokyoCabinet::HDB::OREADER) || abort("cannot open unihan.db")
    @uht = UnihanType.new
  end

  def setType(type)
    return @type = @uht.to_num(type)
  end

  def setModifier(modifier)
    return nil if modifier.class != String
    return @modifier = @uht.to_num(modifier + "Variant") || nil
  end

  def lookupEachChar(char, type)
    begin
      v = @db.get(char)
      v = MessagePack.unpack(v)
      return v[type].force_encoding('utf-8')
    rescue NoMethodError, TypeError
      return nil
    end
  end

  def getByEachChar(char)
    begin
      if @modifier
        c_ = lookupEachChar(char, @modifier)
	#puts "modifier: #{char} -> \"#{c_}\""
	char = c_ unless c_.nil?
      end
      c_ = lookupEachChar(char, @type)
      return [char, c_]
    rescue NoMethodError, TypeError
      return [char, nil]
    end
  end

  def getByString(str)
    return str.split(//).map{|ch| self.getByEachChar(ch) + [ch] }
  end
end


