# command_processor.rb

class CommandProcessor
  def initialize(store)
    @store = store
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

  private

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
end