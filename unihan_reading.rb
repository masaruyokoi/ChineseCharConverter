#encoding: utf-8
require 'dbm'

$reading_sym = {
  'Definiation' => 1,
  'Mandarin' => 2,
  'Cantonese' => 3,
  'JapaneseOn' => 4,
  'JapaneseKun' => 5
}

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


