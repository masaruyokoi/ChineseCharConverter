#encoding: utf-8
require 'dbm'

$reading_sym = {
  'Definiation' => 1,
  'Mandarin' => 2,
  'Cantonese' => 3,
  'JapaneseOn' => 4,
  'JapaneseKun' => 5
}
class UnihanSymbol
  def initialize(type = nil)
    @sym = nil
    self.set(type)
  end
  def set(type)
    if type.class == String
      @sym = $reading_sym[type]
    elsif type.class == Fixnum
      @sym = type
    end
  end
  def to_s
    return @sym
  end
end

class UnihanReadingGetter
  def initialize()
    require 'tokyocabinet'
    #@db = DBM.open('unihan_reading', 0, DBM::READER)
    @db = TokyoCabinet::HDB.new()
    @db.open('unihan_reading.hdb', TokyoCabinet::HDB::OREADER) || abort
  end

  def getByEachChar(char, type)
    k = char + ":" + type.to_s
    v = @db.get(k)
    return nil if v.nil?
    return v.force_encoding('utf-8')
  end

  def getByString(str, type)
    return str.split(//).map{|ch| [ch, self.getByEachChar(ch, type)]}
  end
end


