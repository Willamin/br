require "tempfile"

class Br::Cli
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

    Dir.glob(@globs)
      .sort
      .each do |dir|
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

  def freeze!
    @renames =
      @renames.map do |ra|
        ra.freeze
      end
  end

  def renamable!
    @renames.each do |ra|
      ra.renamable!
    end
  end

  def rename!
    @renames.each do |ra|
      ra.rename!
    end
  end
end
