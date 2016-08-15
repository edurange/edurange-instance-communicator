#!/usr/bin/env ruby -w

# In this file 'client' refers to instances that are connected
# 'host' refers to EDURange server connections
# 'control' is used for debugging
require "socket"

Instance = Struct.new(:scenarioID, :instanceID, :client)

class Server
  def initialize(instancePort, eduPort, controlPort)
    @server = TCPServer.open(instancePort)
    @host = TCPServer.open(eduPort)
    @control = TCPServer.open(controlPort)
    # @connections contains Instance structs
    @connections = Array.new
    clientThread = Thread.new{run_client}    
    hostThread = Thread.new{run_host}
#    controlThread = Thread.new{run_control}
    rmClientThread = Thread.new{remove_client}
    clientThread.join
    hostThread.join
#    controlThread.join
    rmClientThread.join
  end

  # Accepts instance connections
  def run_client
    loop {
      Thread.start(@server.accept) do |client|
        print("Instance ", client, " is accepted\n")
        clientData = client.gets.split
        puts clientData

        # checks if this instance is already connected
        @connections.each do |other_client|
          if client == other_client
          # CHANGE THIS TO RUN REMOVE CLIENT AND THEN CHECK THIS AGAIN
            client.puts "You're already connected!"
            Thread.kill self
          end
        end

        @connections.push(Instance.new(clientData[0], clientData[1], client))
        client.puts "Connection established"
      end
    }.join
  end

  # Checks if each instance is still connected. Closes socket and removes from @connections if so
  def remove_client
    puts "Start"
    loop {
      sleep 10
      @connections.each do |socket|
        begin
          socket.client.puts "ping"
        rescue Exception => exception
          case exception
          when Errno::EPIPE
            socket.client.close
            # does this next line work?
            @connections.delete(socket)
            puts(socket.client, " disconnected.")
          else
            raise exception
          end
        end
      end
    }
  end

  # Accepts EDURange connections, routes command to appropriate instances, then closes connections
  def run_host
    loop {
      Thread.start(@host.accept) do |host|
        print("EDURange ", host, " is accepted\n")
        while input = host.gets.split
          @connections.each do |client|
            inputCopy = input.clone
            inputCopy.slice!(0,2)
            if client.scenarioID == input[0] and client.instanceID == input[1]
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
        print("Control ", control, " is accepted\n")
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
        puts("hi")
      when "instances"
        @connections.each do |socket|
          prints("index ", @connections.index(socket), ": ")
          puts.socket
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
