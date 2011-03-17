# -*- mode:ruby; coding:utf-8 -*-
require "rubygems"
require "bundler/setup"
require 'em-websocket'
require 'sinatra'
require 'thin'
require 'uri'
require 'open-uri'
require 'yaml'
require 'logger'
require 'json'

$log = Logger.new(STDOUT)

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

config_path = File.expand_path('../config/websocket.yml',
                               File.dirname(__FILE__))
puts "load from: #{config_path}"
WsConfig = YAML.load_file config_path
$log.info WsConfig.inspect

def rails_root
  URI("http#{WsConfig['use_rails_ssl'] ? 's' : ''}://#{WsConfig['roots']}")
end

def api(path, params = {}, &f)
  url = rails_root
  url += path
  url += "?" + params.map{|k,v| "#{k}=#{v}" }.join('&')

  $log.info url.to_s
  open(url.to_s) do|io|
    f[JSON.parse(io.read)]
  end
end

EventMachine.run do
  $rooms = Hash.new {|hash, key|
    hash[key] = []
  }
  $users = Hash.new{|hash,key| hash[key] = [] }

  EventMachine::WebSocket.start(:host => '0.0.0.0',
                                :port => WsConfig['websocketPort']) do |ws|
    ws.onopen do
      $log.info "on open: #{ws.request.inspect}"
      query = ws.request['Query']
      path  = URI(ws.request['Path'].gsub("//","/")).path
      p path
      case path
      when '/'
        $rooms[ query['room'] ] << ws
      when '/user'
        api("/api/v1/user", {:api_key => query['api_key'] }) do|json|
          $users[ json['id'] ] << ws
        end
      end
    end

    ws.onclose do
      $log.info "on close: #{ws.request['Query'].inspect}"
      room =  ws.request['Query']['room']
      $rooms[room].delete ws
      $users.each do|xs|
        xs.reject! do|item|
          item == ws
        end
      end
    end
  end

  class App < Sinatra::Base
    get '/message/:event/:id' do
      event = params[:event]
      id    = params[:id]
      room  = params[:room]
      case event
      when 'create', 'update'
        api("/api/v1/message/#{id}.json"){|content|
          json = {
            "event"   => "#{event}",
            "content" => content
          }.to_json

          # dispatch to room watcher
          $rooms[room].each do|ws|
            begin
              ws.send json
            rescue => e
              $log.error e.inspect
            end
          end

          # dispatch to user watcher
          content['watchers'].each do|user|
            $users[ user['id'] ].each do|ws|
              begin
                ws.send json
              rescue => e
                $log.error e.inspect
              end
            end
          end
        }
      when 'delete'
        json = <<JSON
          {
            "event" : "#{event}",
            "content" : { id : #{id} }
          }
JSON

        puts json
        $rooms[room].each do|ws|
          begin
            ws.send json
          rescue => e
            $log.error e.inspect
          end
        end
      end
      "ok"
    end
  end
  App.run! :port => WsConfig['httpPort']
end
