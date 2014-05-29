#encoding: utf-8
require 'dbm'


class UnihanType
  @@syms = %w(
   Nop
   Mandarin Cantonese Definition Hangul HanyuPinlu HanyuPinyin JapaneseKun
   JapaneseOn Korean Tang Vietnamese XHC1983
   CompatibilityVariant SemanticVariant SimplifiedVariant
   SpecializedSemanticVariant TraditionalVariant ZVariant)
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
    require 'tokyocabinet'
    #@db = DBM.open('unihan_reading', 0, DBM::READER)
    @db = TokyoCabinet::HDB.new()
    @db.open('unihan.hdb', TokyoCabinet::HDB::OREADER) || abort
  end

  def getByEachChar(char, type)
    v = @db.get(char)
    return nil if v.nil?
    v = msgpack::unpack(v)
    return nil if v.nil?
    v = v[type]
    return v.force_encoding('utf-8')
  end

  def getByString(str, type)
    return str.split(//).map{|ch| [ch, self.getByEachChar(ch, type)]}
  end
end


