require 'bundler/setup'
require 'test/unit'
require 'rack/test'
require 'json'
require 'nokogiri'
require_relative '../../ServiceOrchestration'
require_relative '../../src/ServicesViewStore'
require_relative '../../src/Transit'
require_relative '../../src/TransitServiceFactory'
require_relative '../../src/Repository/TransitQuoteViewStore'
require_relative '../../src/Repository/TransitServicesViewStore'

class TestTransitNoRoboPaul < Test::Unit::TestCase
  include Rack::Test::Methods

  VIEW_STORE = ENV['VIEW_STORE_CONNECTION_STRING']

  def test_purchase_no_robopaul
    authentication_token = 'test'
    ENV['SERVICE_ORCHESTRATION_AUTH_TOKEN'] = authentication_token
    request = {"auth_token"=>authentication_token, "command"=>{"quoteReference"=> "NOiEKiyK","vlantag"=> "1234","iprange"=> '123.0.0.1/16'}}

    mongo_factory = MongoFactory.new
    quote_repo = mongo_factory.create('quotes-transit', VIEW_STORE)
    
    @pushed_message = nil;
    
    message = {
                    _id:'NOiEKiyK', 
                    type:'transit'
                }

     quote = {
                  "_id"=> 'NOiEKiyK', 
                  "data_centre"=> "Getronics",
                  "transit"=> "Level 3",
                  "capacity"=> "1000Mb",
                  "port_name"=> "CUST=>Manchester_Roller_Derby-JUN-HAL-01-ge-0/0/2",
                  "customer_name"=> "Manual Transit Quote",
                  "customer_asn"=> "789",
                  "type"=> "transit",
                  "company_name"=> "Manchester Roller Derby",
                  "issued_on"=> "01/02/1990",
                  "term"=> "12 months",
                  "new_ports"=> "0",
                  "total"=> "£751"
              }

    quote_repo.save(quote)
    
    notifier = Notifier.new(self)
    
    transit = Transit.new(message_queue:self, notifier:notifier)
    service_orchestration = ServiceOrchestration.new(transit:transit)
      browser = Rack::Test::Session.new(Rack::MockSession.new(service_orchestration))
      browser.post '/purchaseTransit', request.to_json, "CONTENT_TYPE" => "application/json"

    assert_nil(@pushed_message)
  end

  def push(something)
    @pushed_message = something
  end

  def messages
    return FakeClockwork
  end
end

class FakeClockwork
  def self.build(params)
    return FakeMessage
  end
end

class FakeMessage
  def self.deliver
    return FakeResponse
  end
end

class FakeResponse
  def self.success
    return true
  end
  
  def self.message_id
  end
end