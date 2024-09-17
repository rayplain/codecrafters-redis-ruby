require "socket"
require_relative 'services/redis_command_parser'
require_relative 'models/store'
require_relative 'services/command_processor'

class YourRedisServer
  def initialize(port)
    @parser = RedisCommandParser.new
    @port = port
    @buffer = ""
    @store = Store.new
    @command_processor = CommandProcessor.new(@store)
  end

  def start
    # You can use print statements as follows for debugging, they'll be visible when running tests.
    puts("Logs from your program will appear here!")

    # Uncomment this block to pass the first stage
    server = TCPServer.new(@port)

    loop do
      client = server.accept
      Thread.new(client) do |conn|
        handle_client(conn)
      end
    end
  end


  def handle_client(client)
    while (line = client.gets)
      @buffer += line
      if complete_command?(@buffer)
        begin
          parsed_command = @parser.parse(@buffer.strip)
          @command_processor.process_command(client, parsed_command) unless parsed_command.nil?
        rescue => e
          client.puts string_to_error_string("ERR #{e.message}")
        ensure
          @buffer = ""
        end
      end
    end
  end

  private
  attr_accessor :buffer, :parser, :store, :command_processor
  def complete_command?(buffer)
    lines = buffer.split("\r\n")
    return false if lines.length < 3

    expected_array_length = lines[0][1..-1].to_i
    return false if lines.length < expected_array_length * 2 + 1

    true
  end

   def string_to_error_string(string)
    "-#{string}\r\n"
  end
end

YourRedisServer.new(6379).start
