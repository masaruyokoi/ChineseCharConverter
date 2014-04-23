#!/usr/bin/ruby

require 'json'
require 'dbm'
require 'optparse'
require './unihan_reading.rb'

class JsonStore
  def initialize()
    @cantonese = Hash.new
    @mandarin = Hash.new
    @definition = Hash.new
    @japanese = Hash.new
    @hangul = Hash.new
  end

  def store(str, type, value)
    if type == "Cantonese"
      @cantonese[str] = value.split(/\s+/)
    elsif type == "Mandarin"
      @mandarin[str] = value.split(/\s+/)
    elsif type == "Definition"
      @definition[str] = value
    elsif type == "JapaneseOn"
      @japanese[str] ||= {}
      @japanese[str][:on] = value
    elsif type == "JapaneseKun"
      @japanese[str] ||= {}
      @japanese[str][:kun] = value
    elsif type == "Hangul"
      @hangul[str]  = value
    end
  end

  def finish()
    open("reading_cantonese.json", "w") { |io| JSON.dump(@cantonese, io)}
    open("reading_mandarin.json", "w") { |io| JSON.dump(@mandarin, io)}
    open("reading_definition.json", "w") { |io| JSON.dump(@definition, io)}
    open("reading_japanese.json", "w") { |io| JSON.dump(@japanese, io)}
    open("reading_hangul.json", "w") { |io| JSON.dump(@hangul, io)}
  end
end

class TokyoCabinetStorage
  def initialize()
    require 'tokyocabinet'
    @hdb = TokyoCabinet::HDB.new
    @hdb.open('unihan_reading.hdb', TokyoCabinet::HDB::OWRITER|TokyoCabinet::HDB::OCREAT)
    @hdb.put("data_version", "1.00")
  end
  def store(str, type, value)
    t = $reading_sym[type]
    return if t.nil?
    key = str + ":" + t.to_s
    @hdb.put(key, value)
  end
  def finish()
    @hdb.close()
  end
end

class DBMStorage
  def initialize()
    @dbh = DBM.open('unihan_reading', 0666, DBM::NEWDB)
    @dbh["data_version"] = "1.00"
  end

  def store(str, type, value)
    t = $reading_sym[type]
    return if t.nil?
    key = str + ":" + t.to_s
    @dbh[key] = value
  end

  def finish()
    @dbh.close()
  end
end


class StdoutOutput
  def store(str, type, value)
    puts [str,type,value].join("\t")
  end
  def finish()
  end
end

@storage = []

OptionParser.new do |opt|
  opt.on('--json', "output with Json") do 
    @storage.push JsonStore.new()
  end
  opt.on('--tc', "output with TokyoCabinet") do 
    @storage.push TokyoCabinetStorage.new()
  end
  opt.on('--dbm', "output with DBM") do 
    @storage.push DBMStorage.new()
  end
  opt.on('--stdout', "output for stdout") do 
    @storage.push StdoutOutput.new()
  end
end.parse!(ARGV)

if @storage.size == 0
  @storage = [StdoutOutput.new()]
end

#STDIN.each_line do |line|
IO.popen("lzma -dc Unihan_Readings.txt.lzma").each_line do |line|
  next if line[0] == "#"[0]
  line.chomp!
  next if ! line.match(/^U\+([0-9A-F]+)\s+k([a-zA-Z0-9]+)\s+(.+)$/)
  code, type, value = $1, $2, $3
  if code.size < 2 
    STDERR.puts "Skip: #{line}"
    next
  end
  str = [code.hex].pack("U*")
  # call all storage functions
  @storage.each {|f| f.store(str, type, value) }
end

@storage.each{|f| f.finish() }
