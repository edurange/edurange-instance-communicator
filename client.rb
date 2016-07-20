#!/usr/bin/env ruby -w
require "socket"
class Client
  def initialize(server, scenarioID, instanceID)
    @server = server
    @scenarioID = scenarioID
    @instanceID = instanceID
    @directive = nil
    listen
    @directive.join
  end

  def listen

    @server.puts("#{@scenarioID} #{@instanceID}")
    @directive = Thread.new do
      while line = @server.gets.split
        puts "??"
        #puts(line)
        command(line)
      end
    end
  end

  def command(input)
    # input = line.split
    case input[0]
    when "useradd"
      create_user(input[1], input[2])
    when "puts"
      puts(input[1..-1])
    else
    end
  end

  def send_message(message)
    puts(message)
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
end


#puts "Process #{Process.pid}"

#system "iptables -P INPUT ACCEPT"
#system "iptables -P OUTPUT ACCEPT"

socket = TCPSocket.new('52.204.237.209', 3100)
Client.new( socket, ARGV[0], ARGV[1])
#socket.puts("Hey!")



