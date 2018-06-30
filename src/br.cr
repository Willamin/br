require "file_utils"
require "tempfile"

class Object
  def tap_into
    with self yield
  end
end

module Br
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  FLAGS   = %w(--dry-run --verbose)
  ARGS    = ARGV - FLAGS
  DRY_RUN = (ARGV & FLAGS).includes?("--dry-run")
  VERBOSE = (ARGV & FLAGS).includes?("--verbose")

  EDITOR = ENV["EDITOR"]? || "vim"

  def self.verbose(thing)
    STDERR.puts(thing) if VERBOSE
  end

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
      else
        Br.verbose(self)
      end

      from.try do |from|
        to.try do |to|
          FileUtils.mv(from, to)
        end
      end
    end
  end

  class Cli
    @globs = [] of String
    @renames = [] of Br::RenameAction
    @temp : Tempfile

    def initialize
      @globs = Br::ARGS
      @temp = Tempfile.new("br")
    end

    def add_star
      @globs = @globs.map do |dir|
        if Dir.exists?(dir)
          File.join(dir, "*")
        else
          dir
        end
      end
    end

    def write_to_temp
      file = File.open(@temp.path, mode: "a")

      Dir.glob(@globs) do |dir|
        file.puts(dir)
        ra = Br::RenameAction.new
        ra.from = dir
        @renames << ra
      end

      file.close
    end

    def show_editor
      `#{EDITOR} #{@temp.path}`
    end

    def read_from_temp
      File.read_lines(@temp.path).each_with_index do |line, index|
        @renames[index].to = line
      end
    end

    def rename!
      @renames.each do |ra|
        ra.rename!
      end
    end
  end
end

Br::Cli.new.tap_into do
  add_star

  Br.verbose("writing to temp file")
  write_to_temp

  Br.verbose("opening in editor")
  show_editor

  Br.verbose("reading from temp file")
  read_from_temp

  Br.verbose("renaming!")
  rename!
end
