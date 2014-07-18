require 'bundler/setup'
require 'test/unit'
require 'rack/test'
require 'json'
require 'nokogiri'
require_relative '../../ServiceOrchestration'
require_relative '../../src/Repository/TransitPortsRepository'
require_relative '../../src/Repository/TransitProvidersRepository'
require_relative '../../src/TransitPort'

class TestEndPoint < Test::Unit::TestCase
	def test_endpoint
		authentication_token = 'test'
	    ENV['SERVICE_ORCHESTRATION_AUTH_TOKEN'] = authentication_token
	    
	    message = {
						"size" => "10Gb",
	          "data_centre" => "Telecity Reynolds House (IFL)",
	          "port" => "xe-0/0/5",
	          "customer_asn" => "1234",
	          "device" => 'JUN-TCR-01',
	          "transit_provider" => "LINX London"
					}
	    request = {"auth_token"=>authentication_token, "command"=>message	} 

	    @seen_it = false

		service_orchestration = ServiceOrchestration.new(transit_port:self)
		browser = Rack::Test::Session.new(Rack::MockSession.new(service_orchestration))
		browser.post '/provisionTransitPort', request.to_json, "CONTENT_TYPE" => "application/json"
   	
   		assert_equal(@seen_it, true)
   	end

   	def provision(hello)
   		@seen_it = true
   	end
end

class TestProvisionTransitPort < Test::Unit::TestCase
  include Rack::Test::Methods

  def create(repository_type,connection_string="")
  	if repository_type == 'ports-transit'  		
      return @mongo_transit_ports
    end
    if repository_type == 'transit-providers'
      return @mongo_transit_providers
    end
  end

  def test_purchase_service_actions_quote
    authentication_token = 'test'
    ENV['SERVICE_ORCHESTRATION_AUTH_TOKEN'] = authentication_token
    
    message = {
					"size" => "10Gb",
          "data_centre" => "Telecity Reynolds House (IFL)",
          "port" => "xe-0/0/5",
          "customer_asn" => "1234",
          "device" => 'JUN-TCR-01',
          "transit_provider" => "LINX London"
				}
    request = {"auth_token"=>authentication_token, "command"=>message	}  

    @mongo_transit_ports = MongoWrapper.new('connection string','ports-transit',FakeMongo)
    @mongo_transit_providers = MongoWrapper.new('connection string','transit-providers',FakeMongo)
    
    transit_ports_repository = TransitPortsRepository.new(self)
    transit_providers_repository = TransitProvidersRepository.new(self)

    transit_port = TransitPort.new(transit_ports_repository, transit_providers_repository)
    transit_port.provision(message)

    saved_transit_port = transit_ports_repository.all_ports;
    assert_equal(message, saved_transit_port[0])
    saved_transit_provider = @mongo_transit_providers.find('_id' => "LINX London").to_a[0]
    assert_equal(saved_transit_provider['_id'], message["transit_provider"])
  end
end


class FakeMongo
  def self.from_uri(connection_string)
  	return FakeConnection.new
  end
end

class FakeConnection
  def db(db_name)
    return FakeDatabase.new()
  end
end

class FakeDatabase
  def collection(collection_name)
    return FakeCollection.new(collection_name)
  end
end

class FakeCollection
  def initialize(repo_type)   
    @repo_type = repo_type
  end

  def update(newEntry, oldEntry)
  end

  def insert(entry)
  	if(@repo_type == 'ports-transit')   
      @entry = entry
    end
    if(@repo_type == 'transit-providers')
      @entry = entry
    end
  end

  def find(key)
  	return [@entry]
  end
end



