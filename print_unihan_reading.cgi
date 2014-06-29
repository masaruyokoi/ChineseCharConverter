#!/usr/bin/ruby
#encoding: utf-8

require './include.rb'
require 'cgi'

@urg = UnihanReadingGetter.new

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
  
  puts "Content-Type: text/plain; charset=utf-8"
  puts ""
  
  txt.split(//).each do |char|
    char = CGI.escapeHTML(char).gsub(/\n/, "<br/>\n")

    if char.size != 1
      STDOUT.write char
      next
    end

    conv = @urg.getByEachChar(char)
    if conv.nil? || conv[1].nil?
      STDOUT.write char
    else
      STDOUT.write "<ruby><rb>#{char}</rb><rt>#{conv[1].gsub(/\s+/, '<br/>')}</rt></ruby>"
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
  
  
  #puts "200 OK"
  puts "Content-Type: text/plain; charset=utf-8"
  puts ""
  res = Hash.new

  txt.split(//).uniq.each do |char|
    res[char] =  @urg.getByEachChar(char)
  end
  puts JSON.generate(res)
end

## main
@cgi = CGI.new(:accept_charset => "UTF-8")
if false && @cgi.request_method != 'POST'
  @cgi.out('status' => 'METHOD_NOT_ALLOWED') {"need to be POST method"}
  exit(2)
end

t = @urg.setType(@cgi['type'])
if t.nil?
  @cgi.out('status' => 'NOT_FOUND', 'Content-Type' => 'text/plain') {
    "type (#{@cgi['type']}) is undefined or incorrect."
  }
  exit(3)
end

modifier = @cgi['modifier']
unless modifier.nil? and modifier != 'none'
  m = @urg.setType(@cgi['modifier'])
  if m.nil?
    @cgi.out('status' => 'NOT_FOUND', 'Content-Type' => 'text/plain') {
      "modifier (#{@cgi['modifier']}) is undefined or incorrect."
    }
    exit(3)
  end
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



