require 'socket'

class Server
  COMMANDS = [
    'GET',
    'SET',
  ]

  def initialize
    @clients = []
    @data_store = {}

    server = TCPServer.new 2000
    puts "Server started at: #{ Time.now }"

    loop do
      result = IO.select(@clients + [server])
      result[0].each do |socket|
        if socket.is_a?(TCPServer)
          @clients << server.accept
        elsif socket.is_a?(TCPSocket)
          client_command_with_args = socket.read_nonblock(256, exception: false)

          if client_command_with_args.nil?
            puts "Found a client at eof, closing and removing"
            @clients.delete(socket)
          elsif client_command_with_args == :wait_readable
            next
          elsif client_command_with_args.strip.empty?
            puts "Empty request received from #{ socket }"
          else
            puts "Received command: #{ client_command_with_args } from #{ socket }"

            response = handle_client_command(client_command_with_args)
            socket.puts response
          end
        else
          raise "Unknown socket type: #{ socket }"
        end
      end
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