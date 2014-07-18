require 'bundler/setup'
require 'test/unit'
require 'rack/test'
require 'json'
require 'nokogiri'
require_relative '../../ServiceOrchestration'
require_relative '../../src/Peering/Peering'

class TestPurchasePeering < Test::Unit::TestCase
  include Rack::Test::Methods

  VIEW_STORE = ENV['VIEW_STORE_CONNECTION_STRING']
  DATA_STORE = ENV['DATA_STORE_CONNECTION_STRING']

  def test_purchase_peering_sends_message_to_robopaul
    mongo_factory = MongoFactory.new
    quote_repo = mongo_factory.create('quotes-peering', VIEW_STORE)
    services_view_store = mongo_factory.create('services-peering', VIEW_STORE)
    peering_vlan_store = mongo_factory.create('peering-vlans', VIEW_STORE)
    peering_vlan_data_store = mongo_factory.create('peering-vlans', DATA_STORE)
    
    authentication_token = 'test'
    ENV['SERVICE_ORCHESTRATION_AUTH_TOKEN'] = authentication_token

    quote = {
            "_id" => "ZRiEKiyK",
            "quote_reference" => "ZRiEKiyK",
            "type" => 'snappeering',
            "peering_partner" => 'LINX (Global Switch 1, London)',
            "vlan_tag" => '1234',
            "customer_asn" => '41963',
            "customer_name" => 'Manual Peering Quote',
            "company_name" => 'Money SuperMarket',
            "issued_on" => '31/03/2014, 10:27',
            "term" => '9999 months',
            "total" => '£9999',
            "new_ports" => 0,
            "data_centre" => 'Halifax',
            "port_name" => "ge-1/0/0",
            "port_address" => 'CUST:Money SuperMarket (AS789)'
        }
        
    existing_peering_vlan_view = {
        "_id" => quote["peering_partner"],
        "available_tags" => [
            { "tag" => quote["vlan_tag"] }
        ]
    }


    existing_peering_vlan_data = { 
        vlan_tag: quote["vlan_tag"], 
        asn: "", 
        service_reference: "", 
        partner_name: quote["peering_partner"]
    }

    peering_vlan_data_store.save(existing_peering_vlan_data)

    peering_vlan_store.save(existing_peering_vlan_view)
    
    request = {"auth_token"=>authentication_token, "command"=>"ZRiEKiyK"}  

    message = {
                    _id:'ZRiEKiyK', 
                    type:'peering'
                }

    

    assert_equal(quote_repo.find({}).to_a.count, 0)
    quote_repo.save(quote)

    peering = Peering.new(message_queue:self)
    
    service_orchestration = ServiceOrchestration.new(peering:peering)
    browser = Rack::Test::Session.new(Rack::MockSession.new(service_orchestration))
    browser.post '/purchasePeering', request.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal(message, @pushed_message)
  end

  def push(something)
    @pushed_message = something
  end

end
