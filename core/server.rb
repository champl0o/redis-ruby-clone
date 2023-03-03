require 'socket'

class Server
  COMMANDS = [
    'GET',
    'SET',
  ]

  def initialize
    @data_store = {}

    server = TCPServer.new 2000
    puts "Server started at: #{ Time.now }"

    loop do
      client = server.accept
      puts "New client connected: #{ client }"

      client_command_with_args = client.gets
      puts client_command_with_args
      if client_command_with_args && client_command_with_args.strip.length > 0
        response = handle_client_command(client_command_with_args)
        client.puts response
      else
        puts "Empty message received from client: #{ client }"
      end

      client.close
    end
  end

  private

  def handle_client_command(client_command_with_args)
    command_parts = client_command_with_args.split
    command = command_parts[0]
    args = command_parts[1..-1]

    if COMMANDS.include?(command)
      case command
      when 'GET'
        return "(error) ERR wrong number of arguments for '#{ command }' command" unless args.length == 1
        
        key = args[0]
        @data_store.fetch(key, "(nil)")
      when 'SET'
        return "(error) ERR wrong number of arguments for '#{ command }' command" unless args.length == 2

        key = args[0]
        value = args[1]
        @data_store[key] = value
        "OK"
      end
    else
      formatted_args = args.map { |arg| "`#{ arg }`," }.join(" ")
      "(error) ERR unknown command: #{ command }, with args beginning with: #{ formatted_args }"
    end
  end
end

Server.new