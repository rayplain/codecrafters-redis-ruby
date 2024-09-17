# command_processor.rb

class CommandProcessor
  VALID_COMMANDS = %w(PING ECHO SET GET DEL).freeze

  def initialize(store)
    @store = store
  end

  def process_command(client, command)
    command_name = command.first.upcase

    if VALID_COMMANDS.include?(command_name)
      method_name = "handle_#{command_name.downcase}"
      send(method_name, client, command)
    else
      client.puts string_to_error_string("ERR unknown command")
    end
  end

  private

  def handle_ping(client, _command)
    client.puts string_to_regular_string("PONG")
  end

  def handle_echo(client, command)
    client.puts string_to_bulk_string(command[1])
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

  #TODO: Create a ResponseClass that can handle the formatting
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