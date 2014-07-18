require 'bundler/setup'
require 'test/unit'
require 'rack/test'
require 'json'
require 'nokogiri'
require_relative '../../ServiceOrchestration'
require_relative '../../src/Port'

class TestProvisionPort < Test::Unit::TestCase
  include Rack::Test::Methods

  def create(repository_type,connection_string="")
  	if repository_type == 'ports'  		
      return @mongo_ports
    end
  end

  def test_purchase_service_actions_quote
    authentication_token = 'test'
    ENV['SERVICE_ORCHESTRATION_AUTH_TOKEN'] = authentication_token
    
    message = {
					"_id" => "CUST:Power_Internet_Ltd.-JUN-TCR-01-ge-0/0/1",
					"name" => "CUST:Power_Internet_Ltd.-JUN-TCR-01-ge-0/0/1",
					"size" => "1Gb",
					"data_centre" => "Telecity Reynolds House (IFL)",
					"port" => "ge-0/0/1",
					"customer_asn" => "8689",
					"device" => 'JUN-TCR-01',
					"remaining_capacity" => "0Mb",
					"configured" => "18/10/2013 12:27"
				}
    request = {"auth_token"=>authentication_token, "command"=>message	}  

    @mongo_ports = MongoWrapper.new('connection string','ports',FakeMongo)
    
    ports_repository = PortsRepository.new(mongo_factory:self)

    port = Port.new(ports_repository)
    service_orchestration = ServiceOrchestration.new(port:port)
      browser = Rack::Test::Session.new(Rack::MockSession.new(service_orchestration))
      browser.post '/provisionPort', request.to_json, "CONTENT_TYPE" => "application/json"

    saved_port = ports_repository.all_ports;
    assert_equal(message, saved_port)
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
  	if(@repo_type == 'ports')   
      @entry = entry
    end
  end

  def find(key)
  	return @entry
  end
end



