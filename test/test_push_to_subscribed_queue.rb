require 'test/unit'
require_relative('../src/SubscribedMessageQueue')

class TestPop < Test::Unit::TestCase
	def test_environment_is_set_up
		assert_not_nil(ENV['IRON_MQ_TOKEN'])
		assert_not_nil(ENV['IRON_MQ_PROJECT_ID'])
		assert_not_nil(ENV['IRON_MQ_HOST'])
	end
	def test_pop
		# queue_name = "friday_test_for_reals"
		 words = "Gemma has done it mofo #{DateTime.now}"

		# message_queue = SubscribedMessageQueue.new(queue_name)

		# #message_queue.push(words)
		puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< #{words}"
	end
end