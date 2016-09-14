#!/usr/bin/env ruby -w

# In this file 'client' refers to instances that are connected
# 'host' refers to EDURange server connections
# 'control' is used for debugging
require "socket"
require "logger"

$logger = Logger.new('ComServer_logfile.log', 'weekly')
$logger.level = Logger::INFO

Instance = Struct.new(:client, :instanceID, :userName, :name)

class Server
  def initialize(instancePort, eduPort, controlPort)
    @server = TCPServer.open(instancePort)
    @host = TCPServer.open(eduPort)
    @control = TCPServer.open(controlPort)
    # @connections contains Instance structs
    @connections = Array.new
    clientThread = Thread.new{run_client}    
    hostThread = Thread.new{run_host}
    controlThread = Thread.new{run_control}
    rmClientThread = Thread.new{remove_client}
    clientThread.join
    hostThread.join
    controlThread.join
    rmClientThread.join
  end

  def log(*args)
    msg = "#{args.join('')}"
    print(msg)
    $logger.info(msg)
  end

  # Accepts instance connections
  def run_client
    log("Communication server booted.\n")
    loop {
      Thread.start(@server.accept) do |client|
        log("Instance ", client, " is accepted\n")
        clientData = client.gets.split
        puts clientData

        # checks if this instance is already connected
        @connections.each do |other_client|
          if client == other_client
            client.puts "You're already connected!"
            Thread.kill self
          end
        end

        @connections.push(Instance.new(client, clientData[0], clientData[1], clientData[2]))
        client.puts "Connection established"
      end
    }.join
  end

  # Checks if each instance is still connected. Closes socket and removes from @connections if so
  def remove_client
    loop {
      sleep 60
      @connections.each do |socket|
        begin
          socket.client.puts("ping")
        rescue Exception => exception
          case exception
            when Errno::EPIPE
              socket.client.close
              @connections.delete(socket)
              puts(socket.client, " disconnected.")
            else puts(exception)
          end
        end
      end
    }
  end

  # Accepts EDURange connections, routes command to appropriate instances, then closes connections
  def run_host
    loop {
      Thread.start(@host.accept) do |host|
        log("EDURange ", host, " is accepted\n")
        while input = host.gets.split
          @connections.each do |client|
            inputCopy = input.clone
            inputCopy.slice!(0,1)
            if client.instanceID == input[0]
              puts("Client match")
              string = inputCopy.join(" ")
              client.client.puts(string)
            end
          end
        end
      end
    }.join
  end

  # Accepts controller connections, and sends them to cntr_commands
  def run_control
    loop {
      Thread.start(@control.accept) do |control|
        log("Control ", control, " is accepted\n")
        control.puts("Controller connected. Enter 'help' for command list.")
        ctrl_commands(control)
      end
    }.join    
  end

  def ctrl_commands(control)
    loop {
      input = control.gets.downcase.chomp
      case input
      when "help", "h", "-h"
        control.puts("hi")
      when "instances"
        @connections.each do |socket|
          control.print("index ", @connections.index(socket), ": ")
          control.puts(socket)
        end
      when "exit"
        break
      else
        control.puts("Command not understood. Enter 'help' for command list.")
      end      
    }
    control.close
  end
end


puts "Process #{Process.pid}"
Server.new(3100, 3200, 3170)
