require 'socket'

puts "Process #{Process.pid}"
server = TCPServer.open(2000)

system "iptables -P INPUT ACCEPT"
system "iptables -P OUTPUT ACCEPT"

def actions(line)
	command = line.split
	if command[0] == 'useradd'
		create_user(command[1], command[2])
	end
end


def create_user(us,pw)
 pwd = pw.crypt("$5$a1")
        result = system("useradd -m -p '#{ pwd }' #{ us } -s /bin/bash")
        if result
                puts "#{ us } created!"
            else
                puts "#{ us } failed!"
        end
end




loop do
	Thread.start(server.accept) do |socket|
		print(socket, " is accepted\n") 
		while line = socket.gets
			actions(line)
		end
		print(socket, " is gone\n") 
		socket.close
	end
end


