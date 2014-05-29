#!/usr/bin/ruby

require 'json'
require 'dbm'
require 'optparse'
require './include.rb'


class UnihanReadingDb
  def initialize()
    @chars = {}
    @type = UnihanType.new
  end

  def store2db
    require 'tokyocabinet'
    @hdb = TokyoCabinet::HDB.new
    @hdb.open('unihan.hdb', TokyoCabinet::HDB::OWRITER|TokyoCabinet::HDB::OCREAT)
    @hdb.put("data_version", "2.00")

    @chars.each do |char, charval|
      #@hdb.put(char, charval.to_msgpack)
      jstr = JSON.generate(charval)
      @hdb.put(char, jstr)

    end
    @hdb.close()
  end

  def _set(key, type, val)
    @type.setType(type)
    typeid = @type.to_num
    @chars[key] ||= {}
    unless @chars[key][typeid].nil?
      STDERR.puts "#{char}:#{type} is already registered" 
      return
    end
    @chars[key][typeid] = val
  end

  def setReading(key, type, val)
    self._set(key, type, val)
  end

  def setVariant(key,type,val)
    self._set(key, type, val)
  end

  def finalize
    t_mandarin = @type.to_num('Mandarin')
    t_cantonese = @type.to_num('Cantonese')
    t_zvar = @type.to_num('ZVariant')
    t_tvar = @type.to_num('TraditionalVariant')
    t_svar = @type.to_num('SimplifiedVariant')
    # fill cantonese unknown reading
    @chars.each do |char, charval|
      next unless charval[t_cantonese].nil? 
      [t_zvar, t_tvar, t_svar].each do |variant|
	begin
          nextchar = charval[variant]
	  nextval = @chars[nextchar][t_cantonese]
	  next if nextval.nil?
	  # debug
	  STDERR.puts "fill cantonese char=#{char} variant=#{variant} nextchar=#{nextchar} nextval=#{nextval}"
	  charval[t_cantonese] = nextval
	  break
	rescue NoMethodError
	  next
	end
      end
    end
  end
end

urdb = UnihanReadingDb.new

IO.popen("lzma -dc data/Unihan_Readings.txt.lzma").each_line do |line|
  next if line[0] == "#"[0]
  line.chomp!
  next if ! line.match(/^U\+([0-9A-F]+)\s+k([a-zA-Z0-9]+)\s+(.+)$/)
  code, type, value = $1, $2, $3
  if code.size < 2 
    STDERR.puts "Skip: #{line}"
    next
  end
  key = [code.hex].pack("U*")
  urdb.setReading(key, type, value)
end

IO.popen("lzma -dc data/Unihan_Variants.txt.lzma").each_line do |line|
  next if ! line.match(/^U\+([0-9A-F]+)\s+k([a-zA-Z0-9]+)\s+U\+([a-zA-Z0-9]+)/) 
  k, t, v = [$1.hex].pack("U*"), $2, [$3.hex].pack("U*")
  next if k.nil? or v.nil?
  urdb.setVariant(k, t, v)
end
urdb.finalize
urdb.store2db

