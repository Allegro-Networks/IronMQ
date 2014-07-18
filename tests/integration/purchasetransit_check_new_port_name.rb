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

    request = {"auth_token"=>authentication_token, 
      "command"=>{"quoteReference"=> "DePLyJOA","vlantag"=> "1234","iprange"=> '123.0.0.1/16'}}

    message = {
                    _id:'DePLyJOA', 
                    type:'transit'
                }

    quote = {
              "_id"=> "DePLyJOA",
              "quote_reference"=> "DePLyJOA",
              "type"=> "transit",
              "issued_on"=> "17/12/2013",
              "expires_on"=> "24/12/2013",
              "customer_name"=> "Allegro Test Account",
              "customer_asn"=> "12536",
              "customer_telephone"=> "0161 123456",
              "company_name"=> "Allegro Networks Limited",
              "transit"=> "Level 3 (THN London Bearer)",
              "port_name"=> "1Gb",
              "port"=> {
                "name"=> "new",
                "size"=> "1Gb",
                "data_centre"=> "Telecity Kilburn"
              },
              "cdr"=> "200Mb",
              "capacity"=> "200Mb",
              "data_centre"=> "Telecity Kilburn",
              "term"=> "12 months",
              "new_ports"=> 1,
              "total"=> "£150.00"
            }

    quote_repo.save(quote)

    transit = Transit.new(message_queue:self)
    
    service_orchestration = ServiceOrchestration.new(transit:transit)
      browser = Rack::Test::Session.new(Rack::MockSession.new(service_orchestration))
      browser.post '/purchaseTransit', request.to_json, "CONTENT_TYPE" => "application/json"

    saved_service = services_view_store.find("_id"=>'DePLyJOA').to_a[0];
    assert_equal('DePLyJOA', saved_service["_id"])
    assert_equal('1234', saved_service["vlan_tag"])
    assert_equal('123.0.0.1/16', saved_service["ip_range"])
    assert_equal('new 1Gb', saved_service["customer_port"]["name"])
  end

  def push(something)
    @pushed_message = something
  end
end