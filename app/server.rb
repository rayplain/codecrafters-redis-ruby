require "socket"

class YourRedisServer
  def initialize(port)
    @port = port
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
    while (line = client.gets) do
      client.puts string_to_regular_string "PONG" if line.include? "PING"
      if line.include? "ECHO"
        client.gets
        client.puts(string_to_bulk_string(client.gets)) if line.include? "ECHO"
      end
    end
  end

  private
  def string_to_regular_string(string)
    "+#{string}\r\n"
  end

  def string_to_bulk_string(string)
    "$#{string.bytesize}\r\n#{string}\r\n"
  end

  def parse_command_segments(command)
    puts "Splitting the command: #{command}"
    command.split(/\$[0-9]+/).map(&:strip)
  end
end

YourRedisServer.new(6379).start
