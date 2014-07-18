require 'test/unit'
require_relative('../src/MessageQueue')

class TestPop < Test::Unit::TestCase
	def test_environment_is_set_up
		assert_not_nil(ENV['IRON_MQ_TOKEN'])
		assert_not_nil(ENV['IRON_MQ_PROJECT_ID'])
		assert_not_nil(ENV['IRON_MQ_HOST'])
	end
	def test_pop

		queue_name = "my_queue"
		words = "hi #{DateTime.now}"

		message_queue = MessageQueue.new(queue_name)

		message_queue.push(words)

		assert_equal(words, message_queue.pop)
	end
end