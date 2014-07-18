@run_options = {verbose: Rake.application.options.trace}

task :default => [:ruby_dependencies, :test, :git]

task :ruby_dependencies do
	sh 'bundle install --path gems'
end

task :test do
	# Dir.glob('./test/*.rb').each do |test|
	# 	rake_sh 'ruby '+ test
	# end
end

task :watch => :ruby_dependencies do 
	sh "bundle exec filewatcher *.rb -r '.' 'clear ; rake test'"
end

task :git => :ruby_dependencies do 
	require 'bundler/setup'
	require 'git_repository'
	message = ENV['m']
	raise 'no commit message specified' if message.nil?
	git = GitRepository.new
	git.pull
	git.add({:options => '-A'})
	git.commit(message: message )
	git.push
end

def rake_sh(command)
	puts "RUNNING #{command}"
	sh command, @run_options
end