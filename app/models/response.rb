class Response
  VALID_COMMANDS = %w(regular bulk error null_bulk).freeze
  def initialize(command:, type:)
    @command = command
    @type = type
  end
  def encode
    case @type
    when :regular
      "+#{@command}\r\n"
    when :bulk
      "$#{@command.bytesize}\r\n#{@command}\r\n"
    when :error
      "-#{@command}\r\n"
    when :null_bulk
      "$-1\r\n"
    else
      raise ArgumentError, "Invalid response type: #{@type}"
    end
  end

end