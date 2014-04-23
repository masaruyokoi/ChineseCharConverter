#!/usr/bin/ruby
#encoding: utf-8

require './unihan_reading.rb'
require 'cgi'


# Usage:
#  mode=[html|json]
#    html: return the html text with <ruby>
#    json: return the key:value of text:reading
#  type=[Cantonese|Mandarin]
#  txt=<Converting text>
#

def output_text(type)
  txt = @cgi['txt']
  if txt.nil? || txt.size == 0
    @cgi.out('status' => 'NOT_FOUND') { "key 'txt' is empty" }
    exit(4)
  end
  
  urg = UnihanReadingGetter.new
  
  #CGI.http_header("status" => 'OK')
  puts "200 OK"
  puts "Content-Type: text/plain; charset=utf-8"
  puts ""
  
  txt.split(//).each do |char|
    conv = urg.getByEachChar(char, type)
    unless conv.nil?
      STDOUT.write "<ruby><rb>#{char}</rb><rt>#{conv.gsub(/\s+/, '<br/>')}</rt></ruby>"
    else
      STDOUT.write char
    end
  end
end


def output_json(type)
  require 'json'
  txt = @cgi['txt']
  if txt.nil? || txt.size == 0
    @cgi.out('status' => 'NOT_FOUND') { "key 'txt' is empty"}
    exit(4)
  end
  
  urg = UnihanReadingGetter.new
  
  puts "200 OK"
  puts "Content-Type: text/plain; charset=utf-8"
  puts ""
  res = Hash.new

  txt.split(//).uniq.each do |char|
    res[char] =  urg.getByEachChar(char, type)
  end
  puts JSON.generate(res)
end

## main
@cgi = CGI.new(:accept_charset => "UTF-8")
if false && @cgi.request_method != 'POST'
  @cgi.out('status' => 'METHOD_NOT_ALLOWED') {"need to be POST method"}
  exit(2)
end

type = $reading_sym[ @cgi['type'] ]
if type.nil?
  @cgi.out('status' => 'NOT_FOUND', 'Content-Type' => 'text/plain') {
    "type (#{@cgi['type']}) is undefined or incorrect."
  }
  exit(3)
end


case @cgi['mode']
when 'html'
  output_text(type)
when 'json'
  output_json(type)
else
  @cgi.out('status' => 'NOT_FOUND'){ 'mode not found';}
  exit(3)
end



