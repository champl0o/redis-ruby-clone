require 'socket'

class Server
  def initialize
    server = TCPServer.new 2000

    puts "Server started at: #{ Time.now }"

    loop do
      # with threads
      Thread.start(server.accept) do |client|
        client.puts "Hello !"
        client.puts "Time is #{Time.now}"
        client.close
      end
    end
  end
end

Server.new