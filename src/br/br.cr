module Br
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  FLAGS           = %w(--dry-run --verbose --version --full-version)
  ARGS            = ARGV - FLAGS
  DRY_RUN         = (ARGV & FLAGS).includes?("--dry-run")
  VERBOSE         = (ARGV & FLAGS).includes?("--verbose")
  VERSION_DISPLAY = (ARGV & FLAGS).includes?("--version")

  EDITOR = ENV["EDITOR"]? || "vim"

  USAGE = <<-U
    br v#{VERSION}
    usage: br [OPTIONS] GLOB [GLOB ...]

    Options:
    --verbose       be more verbose
    --dry-run       print dangerous actions instead of doing them

  U

  class MissingFrom < Exception; end

  class MissingTo < Exception; end

  class NotWritable < Exception; end

  class Frozen < Exception; end

  def self.verbose(thing)
    STDERR.puts(thing) if VERBOSE
  end

  def self.check_version
    if Br::VERSION_DISPLAY
      puts Br::VERSION
      exit 0
    end
  end

  def self.check_no_args
    if Br::ARGS.size == 0
      puts Br::USAGE
      exit 1
    end
  end

  def self.run_cli
    Br::Cli.new.tap_into do
      add_star

      Br.verbose("writing to temp file")
      write_to_temp

      Br.verbose("opening in editor")
      show_editor

      Br.verbose("reading from temp file")
      read_from_temp

      Br.verbose("freezing actions")
      freeze!

      Br.verbose("ensuring that all files can be renamed")
      renamable!

      Br.verbose("renaming!")
      rename!
    end
  end
end
