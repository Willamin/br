require "./spec_helper"
require "file_utils"

record TestFile, filename : String, contents : String

def setup(&block : -> Array(TestFile))
  t = Tempfile.dirname
  spec_dir = File.join(t, "br_spec")
  if Dir.exists?(spec_dir)
    FileUtils.rm_r(spec_dir)
  end
  FileUtils.mkdir(spec_dir)

  (yield).each do |testfile|
    f = File.open(File.join(spec_dir, testfile.filename), mode: "w")
    f.puts(testfile.contents)
    f.close
  end

  spec_dir
end

def br
  "EDITOR=#{__DIR__}/tac bin/br"
end

describe Br do
  test "that files are renamed" do
    dir = setup do
      [
        TestFile.new("foo", "originally foo"),
        TestFile.new("bar", "originally bar"),
        TestFile.new("baz", "originally baz"),
      ]
    end

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

  test "that files can be deleted" do
    dir = setup do
      [
        TestFile.new("foo", "originally foo"),
        TestFile.new("delete-me", "should be deleted"),
      ]
    end
    `#{br} #{dir}`

    assert File.read("#{dir}/foo-updated") == "originally foo\n"
    assert !File.exists?("#{dir}/delete-me")
  end
end
