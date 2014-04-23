#!/usr/bin/ruby

#@chars = Hash.new

STDIN.each_line do |line|
  next if line[0] == "#"[0]
  line.chomp!
  next if ! line.match(/^U\+([0-9A-F]+)\s+k([a-zA-Z0-9]+)\s+U\+([a-zA-Z0-9]+)/)
  code, type, value = $1, $2, $3
  if code.size < 2  || value.size < 2
    STDERR.puts "Skip: #{line}"
    next
  end
  str = [code.hex].pack("U*")
  val = [value.hex].pack("U*")
  puts [str, type, val].join("\t")
end

