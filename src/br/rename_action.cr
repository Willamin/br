class Br::RenameAction
  @from : String?
  @to : String?
  @from_frozen : String = ""
  @to_frozen : String = ""
  @frozen : Bool = false

  {% for key in ["from", "to"] %}
      def {{key.id}} : String
        if @frozen
          return @{{key.id}}_frozen
        else
          @{{key.id}}.try { |x| return x }
        end

        raise Missing{{key.capitalize.id}}.new
      end

      def {{key.id}}=(new_{{key.id}})
        if @frozen
          raise Frozen.new
        else
          @{{key.id}} = new_{{key.id}}
        end
      end
    {% end %}

  def to_s(io)
    if to.blank?
      io << "#{from} will be deleted"
    else
      io << "#{from} -> #{to}"
    end
  end

  def renamable!
    if to == from
      return
    end

    if File.writable?(to)
      STDERR.puts("destination `#{to}` not writable")
      raise NotWritable.new
    end
  end

  def rename!
    if DRY_RUN
      puts self
      return
    else
      Br.verbose(self)
    end

    if to.blank?
      File.delete(from)
    else
      File.rename(from, to)
    end
  end

  def freeze
    if @from.nil?
      raise MissingFrom.new
    end

    if @to.nil?
      raise MissingTo.new
    end

    @from.try { |f| @from_frozen = f }
    @to.try { |t| @to_frozen = t }
    @frozen = true
    self
  end
end
