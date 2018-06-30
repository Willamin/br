require "file_utils"
require "tempfile"

module Br
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  FLAGS   = %w(--dry-run --verbose)
  ARGS    = ARGV - FLAGS
  DRY_RUN = (ARGV & FLAGS).includes?("--dry-run")
  VERBOSE = (ARGV & FLAGS).includes?("--verbose")

  class RenameAction
    property from : String?
    property to : String?

    def to_s(io)
      io << "#{from} -> #{to}"
    end

    def rename!
      if DRY_RUN
        puts self
        return
      elsif VERBOSE
        STDERR.puts self
      end

      from.try do |from|
        to.try do |to|
          FileUtils.mv(from, to)
        end
      end
    end
  end

  def self.add_star(globs)
    globs.map do |dir|
      if Dir.exists?(dir)
        File.join(dir, "*")
      else
        dir
      end
    end
  end
end

globs = Br::ARGS
globs = Br.add_star(globs)

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
