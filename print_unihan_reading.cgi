#!/usr/bin/ruby
#encoding: utf-8

require './include.rb'
require 'fcgi'

@urg = UnihanReadingGetter.new

# Usage:
#  mode=[html|json]
#    html|htmlruby: return the html text with <ruby>
#    htmlbrackets: return the html text with brackets
#    json: return the key:value of text:reading
#  type=[Cantonese|Mandarin|Cangjie]
#  txt=<Converting text>
#  modifier=[Simplified|Traditional|none]
#

def output_text(opts={})
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
    elsif opts[:brackets] == true
      STDOUT.write "#{conv[0]} (#{conv[1]}) "
    else
      STDOUT.write "<ruby><rb>#{conv[0]}</rb><rt>#{conv[1].gsub(/\s+/, '<br/>')} </rt></ruby> "
    end
  end
end


def output_json()
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

#@cgi = CGI.new(:accept_charset => "UTF-8")
FCGI.each_cgi do |cgi|
  @cgi = cgi
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
unless modifier.nil? || modifier == 'none'
  m = @urg.setModifier(modifier)
  if m.nil?
    @cgi.out('status' => 'NOT_FOUND', 'Content-Type' => 'text/plain') {
      "modifier (#{modifier}) is undefined or incorrect."
    }
    exit(3)
  end
end



case @cgi['mode']
when 'html', 'htmlruby'
  output_text()
when 'htmlbrackets'
  output_text(:brackets => true)
when 'json'
  output_json()
else
  @cgi.out('status' => 'NOT_FOUND'){ 'mode not found';}
  exit(3)
end

puts ""


end
