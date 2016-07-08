require 'socket'
require 'logger'

logger = Logger.new('socket.log')
logger.level = Logger::DEBUG

#puts "Process #{Process.pid}"

#system "iptables -P INPUT ACCEPT"
#system "iptables -P OUTPUT ACCEPT"
logger.debug("start")
socket = TCPSocket.new('52.9.13.127', 2000)
logger.debug("socket set")
socket.puts("Hey!")
logger.debug("said Hey!")

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