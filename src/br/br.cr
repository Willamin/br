module Br
  FLAGS           = %w(--dry-run --verbose --version)
  ARGS            = ARGV - FLAGS
  DRY_RUN         = (ARGV & FLAGS).includes?("--dry-run")
  VERBOSE         = (ARGV & FLAGS).includes?("--verbose")
  VERSION_DISPLAY = (ARGV & FLAGS).includes?("--version")

  EDITOR = ENV["EDITOR"]? || "vim"

  class MissingFrom < Exception; end

  class MissingTo < Exception; end

  class NotWritable < Exception; end

  class Frozen < Exception; end

  def self.verbose(thing)
    STDERR.puts(thing) if VERBOSE
  end
end
