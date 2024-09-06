require "socket"
require_relative 'services/redis_command_parser'
require_relative 'models/store'

class YourRedisServer
  def initialize(port)
    @parser = RedisCommandParser.new
    @port = port
    @buffer = ""
    @store = Store.new
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
          process_command(client, parsed_command) unless parsed_command.nil?
        rescue => e
          client.puts string_to_error_string("ERR #{e.message}")
        ensure
          @buffer = ""
        end
      end
    end
  end

  private
  attr_accessor :buffer, :parser, :store
  def complete_command?(buffer)
    lines = buffer.split("\r\n")
    return false if lines.length < 3

    expected_array_length = lines[0][1..-1].to_i
    return false if lines.length < expected_array_length * 2 + 1

    true
  end
  def string_to_regular_string(string)
    "+#{string}\r\n"
  end

  def string_to_bulk_string(string)
    "$#{string.bytesize}\r\n#{string}\r\n"
  end

  def string_to_error_string(string)
    "-#{string}\r\n"
  end

  def string_to_null_bulk_string
    "$-1\r\n"
  end

  def handle_set(client, command)
    key = command[1]
    value = command[2]

    if command.size == 3
      response = @store.set(key, value)
    elsif command.size == 5 && command[3].downcase == "px"
      expiry = command[4].to_i
      response = @store.set(key, value, expiry)
    else
      client.puts string_to_error_string("ERR wrong number of arguments for 'SET' command")
      return
    end

    client.puts string_to_regular_string(response)
  end

  def handle_get(client, command)
    if command.size == 2
      value = @store.get(command[1])
      if value
        client.puts string_to_bulk_string(value)
      else
        client.puts string_to_null_bulk_string
      end
    else
      client.puts string_to_error_string("ERR wrong number of arguments for 'GET' command")
    end
  end

  def handle_del(client, command)
    if command.size == 2
      result = @store.del(command[1])
      client.puts ":#{result}\r\n"
    else
      client.puts string_to_error_string("ERR wrong number of arguments for 'DEL' command")
    end
  end

  def process_command(client, command)
    case command.first
    when "PING"
      client.puts string_to_regular_string("PONG")
    when "ECHO"
      client.puts string_to_bulk_string(command[1])
    when "SET"
      handle_set(client, command)
    when "GET"
      handle_get(client, command)
    when "DEL"
      handle_del(client, command)
    else
      client.puts string_to_error_string("ERR unknown command")
    end
  end
end

YourRedisServer.new(6379).start
