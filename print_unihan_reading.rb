#!/usr/bin/ruby
# encoding: utf-8
require './unihan_reading'
require 'optparse'


@type = $reading_sym['Cantonese']
@mode = :text
OptionParser.new do |opt|
  opt.on('-c', '--cantonese', 'Get Reading in Cantonese') do
    @type = $reading_sym['Cantonese']
  end
  opt.on('-m', '--mandarin', 'Get Reading in Mandarin') do
    @type = $reading_sym['Mandarin']
  end
  opt.on('--html-ruby', 'With HTML ruby tag') do
    @mode = :html_ruby
  end
end.parse!(ARGV)

urg = UnihanReadingGetter.new

STDIN.each_line do |l|
  urg.getByString(l, @type).each do |v|
    if @mode == :text
      puts "#{v[0]} : #{v[1]}"
    elsif @mode == :html_ruby
      if v[1].nil?
	STDOUT.write v[0]
      else
        STDOUT.write "<ruby><rb>#{v[0]}</rb><rt>#{v[1]}</rt></ruby>"
      end
    end
  end
end

