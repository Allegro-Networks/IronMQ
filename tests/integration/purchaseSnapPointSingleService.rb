require 'bundler/setup'
require 'test/unit'
require 'rack/test'
require 'json'
require 'nokogiri'
require_relative '../../ServiceOrchestration'
require_relative '../../src/ServicesViewStore'

class TestSinglePoint < Test::Unit::TestCase
  include Rack::Test::Methods

  def create(repository_type,connection_string="")
    if repository_type == 'quotes'
      return @mongo_quotes
    end
    if repository_type == 'services'
      return @mongo_services
    end
  end

  def test_purchase_service_actions_quote
    authentication_token = 'test'
    ENV['SERVICE_ORCHESTRATION_AUTH_TOKEN'] = authentication_token
    @loaded_config = []
    @label = 4
    request = {"auth_token"=>authentication_token, "command"=>"LRiEKiyK"}  

    @mongo_quotes = MongoWrapper.new('connection string','quotes',FakeMongo)
    @mongo_services = MongoWrapper.new('connection string','services',FakeMongo)
    
    message = {
                    _id:'LRiEKiyK', 
                    type:'point-to-point'
                }

    quote_repository = QuoteViewStore.new(self)
    services_view_store = ServicesViewStore.new(self)
    service_factory = ServiceFactory.new
    ports_repository = PortsRepository.new(mongo_factory:self)

    singlePointToPoint = SinglePointToPoint.new(quote_repository, services_view_store, service_factory, self, ports_repository)

    singlePointToPoint.action("LRiEKiyK")

    service_orchestration = ServiceOrchestration.new(single_point_to_point:singlePointToPoint)
    browser = Rack::Test::Session.new(Rack::MockSession.new(service_orchestration))
    browser.post '/purchaseSnapPointSingleService', request.to_json, "CONTENT_TYPE" => "application/json"

    saved_service = services_view_store.find('LRiEKiyK');

    assert_equal('LRiEKiyK', saved_service[:_id])
    assert_equal(message, @pushed_message)
  end

  def push(something)
    @pushed_message = something
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
    if(@repo_type == 'services')      
      @entry = entry
    end
  end

  def find(key)
    if(@repo_type == 'services')
      return [@entry]
    end
    if(@repo_type == 'quotes')      
       quote = [{ 
              "_id"=> 'LRiEKiyK', 
              "a_end"=> "Telehouse North", 
              "b_end"=> "Alphadex", 
              "capacity"=> "500Mb", 
              "port_size"=> "1Gb", 
              "customer_name"=> "Dave Heath", 
              "customer_asn"=> "12536",
              "customer_telephone"=> "999", 
              "company_name"=> "Laterooms.com", 
              "issuer_name"=> "Al Egro", 
              "issued_on"=> "15/08/2013", 
              "expires_on"=> "14/09/2013",
              "quote_reference"=> "LRiEKiyK", 
              "term"=> "12 months", 
              "new_ports" => "2",
              "ports"=> [{"name" => 'new', "size"=> '1Gb', 'data_centre'=>'Telehouse North'}, {"name" => 'new', "size"=> '1Gb', 'data_centre'=>'Alphadex'}], 
              "total"=> "£675" 
            }]
      return quote
    end
  end
end



