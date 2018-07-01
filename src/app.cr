require "tempfile"
require "./br/*"

module Br
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
end

if Br::VERSION_DISPLAY
  puts Br::VERSION
  exit 0
end

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
