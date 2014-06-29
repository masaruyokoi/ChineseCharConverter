#!/usr/bin/ruby
# encoding: utf-8
require './include.rb'
require 'optparse'


uht = UnihanType.new
@mode = :text

urg = UnihanReadingGetter.new

urg.setType('Cantonese')
OptionParser.new do |opt|
  opt.on('-c', '--cantonese', 'Get Reading in Cantonese') do
    urg.setType('Cantonese')
  end
  opt.on('-m', '--mandarin', 'Get Reading in Mandarin') do
    urg.setType('Mandarin')
  end
  opt.on('-s', '--simplified', 'Modify to simplified Chinese') do
    urg.setModifier('Simplified')
  end
  opt.on('-t', '--traditional', 'Modify to Traditional Chinese') do
    urg.setModifier('Traditional')
  end
  opt.on('--html-ruby', 'With HTML ruby tag') do
    @mode = :html_ruby
  end
end.parse!(ARGV)

STDIN.each_line do |l|
  puts "txt: " + l
  urg.getByString(l).each do |v|
    if @mode == :text
      puts "#{v[2]} : (#{v[0]}:#{v[1]}) "
    elsif @mode == :html_ruby
      if v[1].nil?
	STDOUT.write v[0]
      else
        STDOUT.write "<ruby><rb>#{v[0]}</rb><rt>#{v[1]}</rt></ruby>"
      end
    end
  end
end

