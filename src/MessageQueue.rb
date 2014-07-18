require 'bundler/setup'
require 'iron_mq'
require 'json'

class MessageQueue
	def initialize(queue_name)
		token = ENV['IRON_MQ_TOKEN']
		project_id = ENV['IRON_MQ_PROJECT_ID']
		host = ENV['IRON_MQ_HOST']

		@ironmq = IronMQ::Client.new(token: token, project_id: project_id, host: host)
		
		@queue = @ironmq.queue(queue_name)
	end
	def push(message)
		@queue.post(message)	
	end

	def subscribe(end_point)
		@queue.add_subscriber({:url => end_point})
	end

	def unsubscribe(end_point)
		queue.remove_subscriber({url: end_point})
	end

	def pop
		msg = @queue.get()
		 
		msg.delete 

		return msg.body
	end
end