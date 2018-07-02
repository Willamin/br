require "./spec_helper"
require "file_utils"

def setup
  t = Tempfile.dirname
  spec_dir = File.join(t, "br_spec")
  if Dir.exists?(spec_dir)
    FileUtils.rm_r(spec_dir)
  end
  FileUtils.mkdir(spec_dir)
  %w[foo bar baz].each do |name|
    f = File.open(File.join(spec_dir, name), mode: "w")
    f.puts("originally #{name}")
    f.close
  end

  spec_dir
end

def br
  "EDITOR=#{__DIR__}/tac bin/br"
end

describe Br do
  test "that files are renamed" do
    dir = setup

    `#{br} #{dir}`

    %w[foo bar baz].each do |name|
      assert File.read("#{dir}/#{name}-updated") == "originally #{name}\n"
    end
  end

  test "that version is returned" do
    output = `#{br} --version`.strip
    assert output == Br::VERSION
  end

  test "that that usage is shown when no args are given" do
    output = `#{br}`.strip
    assert output == Br::USAGE.strip
  end
end
