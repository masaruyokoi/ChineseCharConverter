#encoding: utf-8
require 'dbm'
require 'tokyocabinet'
require 'msgpack'


class ResultModifierBase
  def modify(str)
    return str
  end
end

class ResultModifierCangjieRadical < ResultModifierBase
  @@cangjieTable = %w(
  A 日 B 月 C 金 D 木 E 水 F 火 G 土 H 竹 I 戈 J 十 K 大 L 中 M 一
  N 弓 O 人 P 心 Q 手 R 口 S 尸 T 廿 U 山 V 女 W 田 Y 卜
  )
  @@cangjieKeyRadical = Hash[*@@cangjieTable]

  def modify(str)
    newstr = ""
    str.split(//).each do |c|
      newstr += c
      c_mod = @@cangjieKeyRadical[c]
      newstr += c_mod + " " if c_mod
    end
    newstr.gsub!(/\s+$/, "")
    return newstr
  end

end

class UnihanType
  @@syms = %w(
   Nop
   Mandarin Cantonese Definition Hangul HanyuPinlu HanyuPinyin JapaneseKun
   JapaneseOn Korean Tang Vietnamese XHC1983
   CompatibilityVariant SemanticVariant SimplifiedVariant
   SpecializedSemanticVariant TraditionalVariant ZVariant
   Cangjie CheungBauer CihaiT Fenn FourCornerCode Frequency GradeLevel
   HDZRadBreak HKGlyph Phonetic TotalStrokes
   CangjieRadical
  )
  cnt = 0
  @@str2sym = Hash[*@@syms.map{|s| [s, cnt+=1]}.flatten]
  @resultModifier = nil

  def initialize(type = nil)
    self.setType(type)
  end

  def setType(type)
    @resultModifier = nil
    @sym = nil
    if type.class == String
      @sym = @@str2sym[type]
      raise "unknown Type string #{type}" if @sym.nil?
    elsif type.class == Fixnum
      raise "unknown type id (#{type})" if @@syms[type].nil?
      @sym = type
    end
    if @sym == @@str2sym['CangjieRadical']
      @sym = @@str2sym['Cangjie']
      @resultModifier = ResultModifierCangjieRadical.new
    end
  end

  def getResultModifier
    return @resultModifier
  end
  
  def to_num(type = nil)
    return @sym if type.nil?
    abort if type.class != String
    return @@str2sym[type]
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
    @uht.setType(type)
    @type = @uht.to_num()
    return @type
  end

  def setModifier(modifier)
    return nil if modifier.class != String
    return @modifier = @uht.to_num(modifier + "Variant") || nil
  end


  def lookupEachChar(char, type)
    begin
      v = @db.get(char)
      v = MessagePack.unpack(v)
      res = v[type].force_encoding('utf-8')
      return res
    rescue NoMethodError, TypeError, EOFError
      return nil
    end
  end

  def getByEachChar(char)
    begin
      if @modifier
        c_ = lookupEachChar(char, @modifier)
	char = c_ unless c_.nil?
      end
      c_ = lookupEachChar(char, @type)
      rm = @uht.getResultModifier() 
      return [char, c_] if rm.nil?
      return [char, rm.modify(c_)]
    rescue NoMethodError, TypeError
      return [char, nil]
    end
  end

  def getByString(str)
    return str.split(//).map{|ch| self.getByEachChar(ch) + [ch] }
  end
end



