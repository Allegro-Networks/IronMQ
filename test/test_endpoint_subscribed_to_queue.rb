require 'bundler/setup'
require 'test/unit'
require 'rack/test'
require_relative('../MessageQueueEndpoint')
require_relative('../src/MessageQueue')


class TestMessageQueueEndPoint < Test::Unit::TestCase
	def test_pop
		queue_name = "friday_test_for_reals"
		words = "What is going on? #{DateTime.now}"

		message_queue = MessageQueue.new(queue_name)

		request = {:message=>'poke'}

	    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
		message_queue.push(words)
		browser.post '/bob', request.to_json, "CONTENT_TYPE" => "application/json"
		puts "<<<<<<<<<<<<<<<<<<<<< #{words}"
	end
end

ENV['RACK_ENV'] = 'test'
class HelloWorldTest < Test::Unit::TestCase

	def test_it_says_hello_world
		browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
		browser.get '/'
		assert browser.last_response.ok?
		assert_equal 'Hello World', browser.last_response.body
	end

	def test_it_says_hello_to_a_person
		browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
		browser.get '/', :name => 'Simon'
		assert browser.last_response.body.include?('Simon')
	end
end