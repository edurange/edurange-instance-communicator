require 'socket'

puts "Process #{Process.pid}"
server = TCPServer.open(2000)

system "iptables -P INPUT ACCEPT"
system "iptables -P OUTPUT ACCEPT"

loop do
	Thread.start(server.accept) do |socket|
		print(socket, " is accepted\n") 
		while line = socket.gets
			puts line
		end
	end
