#!/usr/bin/env cashrun

require "yaml"
require "llvm"

class CurrentVersionMissing < Exception; end

class FutureVersionMissing < Exception; end

class BackwardsBump < Exception; end

class NothingToDo < Exception; end

class ReleaseTool
  DESCRIPTION = <<-DESC
    release-tool v1.0.0
    by Will Lewis

      This tool is used to do the following:
        1. bump the version in shards.yml as needed
        2. commit the bumped version
        3. tag the commit
        4. push the code and tags to origin
        5. build the binary in release mode
        6. package the binary in an archive
        7. output a summary of what happened
    DESC

  property future : String?
  property current : String?

  def check_future
    if future.nil?
      raise FutureVersionMissing.new
    end
  end

  def check_current
    if current.nil?
      raise CurrentVersionMissing.new
    end
  end

  def check_direction
    if (future || "") < (current || "")
      raise BackwardsBump.new
    end

    if (future || "") == (current || "")
      raise NothingToDo.new
    end
  end

  def self.release
    puts DESCRIPTION + "\n\n"
    ReleaseTool.new.release
  end

  def self.bye(thing)
    STDERR.puts(thing)
    STDERR.puts
    exit 1
  end

  def release
    @future = ARGV[0]?
    check_future

    shard_yml = File.read("shard.yml")

    @current = YAML.parse(shard_yml)["version"]?.try(&.to_s)
    check_current

    check_direction

    line_with_version =
      shard_yml.lines
        .map_with_index { |v, i| {i, v} }
        .select(&.[1].starts_with?("version:"))
        .map(&.[0])
        .[0]

    file = File.open("shard.yml", mode: "w")
    shard_yml.lines.each_with_index do |line, index|
      if index == line_with_version
        file.puts("version: #{@future}")
      else
        file.puts(line)
      end
    end
    file.close

    `git add shard.yml`
    `git commit -m "Prepare for v#{future}"`
    `git tag v#{future} -m v#{future}`
    `git push origin`
    `git push origin --tags`

    `shards build --release --no-debug`
    binary_name = YAML.parse(shard_yml)["targets"].as_h.keys[0]
    archive_name = "br-#{future}-#{LLVM.default_target_triple}.tar.gz"
    `cd bin && tar czf #{archive_name} #{binary_name}`
    `mkdir -p release && mv #{archive_name} release`
    #


  rescue FutureVersionMissing
    ReleaseTool.bye("You must provide a version to bump.")
  rescue CurrentVersionMissing
    ReleaseTool.bye("shard.yml is missing a version.")
  rescue BackwardsBump
    ReleaseTool.bye("You can't rollback a version with this tool.")
  rescue NothingToDo
    ReleaseTool.bye("You're already on that version.")
  end
end

ReleaseTool.release
