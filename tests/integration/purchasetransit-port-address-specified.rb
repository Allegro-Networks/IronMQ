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

class TestTransitWithPortAddress < Test::Unit::TestCase
  include Rack::Test::Methods

  VIEW_STORE = ENV['VIEW_STORE_CONNECTION_STRING']

  def test_purchase_transit_actions_quote
    mongo_factory = MongoFactory.new
    quote_repo = mongo_factory.create('quotes-transit', VIEW_STORE)
    services_view_store = mongo_factory.create('services-transit', VIEW_STORE)
    
    authentication_token = 'test'
    ENV['SERVICE_ORCHESTRATION_AUTH_TOKEN'] = authentication_token

    request = {"auth_token"=>authentication_token, "command"=>"ZRiEKiyK"}  

    message = {
                    _id:'ZRiEKiyK', 
                    type:'transit'
                }

    quote = {
              "_id"=> 'ZRiEKiyK', 
              "data_centre"=> "Getronics",
              "transit"=> "Level 3",
              "capacity"=> "1000Mb",
              "port_name"=> "new 10Gb",
              "port_address"=> "xe-0/0/1",
              "customer_name"=> "Manual Transit Quote",
              "customer_asn"=> "789",
              "type"=> "transit",
              "vlan_tag"=> '520',
              "company_name"=> "Manchester Roller Derby",
              "issued_on"=> "01/02/1990",
              "term"=> "12 months",
              "new_ports"=> "0",
              "total"=> "£751"
          }

    assert_equal(quote_repo.find({}).to_a.count, 0)
    quote_repo.save(quote)

    transit = Transit.new(message_queue:self)
    
    service_orchestration = ServiceOrchestration.new(transit:transit)
      browser = Rack::Test::Session.new(Rack::MockSession.new(service_orchestration))
      browser.post '/purchaseTransit', request.to_json, "CONTENT_TYPE" => "application/json"


    assert_equal(quote_repo.find({}).to_a.count, 1)

    saved_service = services_view_store.find("_id" => 'ZRiEKiyK').to_a[0]
    assert_equal('ZRiEKiyK', saved_service["_id"])
    assert_equal('520', saved_service["vlan_tag"])
    assert_equal('new 10Gb', saved_service["customer_port"]["name"])
    assert_equal('xe-0/0/1', saved_service["customer_port"]["address"])
    assert_equal(message, @pushed_message)
  end

  def push(something)
    @pushed_message = something
  end

end
