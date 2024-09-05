class RedisCommandParser
  def parse(stream)
    lines = stream.split("\r\n")
    return nil if lines.empty?

    command_type = lines.shift
    case command_type[0]
    when '*'
      parse_array(command_type, lines)
    else
      raise "Unsupported command type: #{command_type}"
    end
  end

  private

  def parse_array(command_type, lines)
    array_length = command_type[1..-1].to_i
    array = []

    while array.length < array_length && !lines.empty?
      type = lines.shift
      case type[0]
      when '$'
        element_length = type[1..-1].to_i
        element = lines.shift
        raise "Protocol error" unless element && element.bytesize == element_length
        array << element
      else
        raise "Unsupported type: #{type}"
      end
    end

    array
  end
end