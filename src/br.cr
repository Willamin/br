require "file_utils"
require "tempfile"

module Br
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
  VERBOSE = false

  class RenameAction
    property from : String?
    property to : String?

    def rename!
      STDERR.puts "#{from} -> #{to}" if VERBOSE
      from.try do |from|
        to.try do |to|
          FileUtils.mv(from, to)
        end
      end
    end
  end
end

globs = ARGV

globs = globs.map do |dir|
  if Dir.exists?(dir)
    File.join(dir, "*")
  else
    dir
  end
end

renames = [] of Br::RenameAction

temp = Tempfile.new("br")
file = File.open(temp.path, mode: "a")

Dir.glob(globs) do |dir|
  file.puts(dir)
  ra = Br::RenameAction.new
  ra.from = dir
  renames << ra
end

file.close

command = ENV["EDITOR"]? || "vim"

`#{command} #{temp.path}`

File.read_lines(temp.path).each_with_index do |line, index|
  renames[index].to = line
end

renames.each do |ra|
  ra.rename!
end
