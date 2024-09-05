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
    client = server.accept

    loop do
      request = client.gets
      if request.start_with?("*1") && client.gets == "$4\r\n" && client.gets.chomp == "PING"
        client.puts string_to_regular_string "PONG"
      else
        client.puts string_to_regular_string "Unknown Command"
      end
    end
  end

  private
  def string_to_regular_string(string)
    "+#{string}\r\n"
  end
end

YourRedisServer.new(6379).start
