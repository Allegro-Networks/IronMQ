require 'bundler/setup'
require 'json'
require 'sinatra'
require_relative './src/MessageQueue'
configure { set :server, :puma }

QUEUE_NAME = 'friday_test_for_reals'

post '/bob' do 
	message_queue = MessageQueue.new(QUEUE_NAME)
	
	puts ">>>>>>>>>>>>>>>>>>>>>>#{message_queue.pop}"
end

get '/' do
  "Hello World #{params[:name]}".strip
end