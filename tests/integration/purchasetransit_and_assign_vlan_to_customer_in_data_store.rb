require 'bundler/setup'
require 'test/unit'
require 'rack/test'
require 'json'
require 'nokogiri'
require_relative '../../ServiceOrchestration'
require_relative('../../src/Repository/MongoFactory')

class TestTransit < Test::Unit::TestCase
  include Rack::Test::Methods

  VIEW_STORE = ENV['VIEW_STORE_CONNECTION_STRING']
  DATA_STORE = ENV['DATA_STORE_CONNECTION_STRING']

  def test_purchase_transit_assigns_vlan_view_store
    mongo_factory = MongoFactory.new
    quote_repo = mongo_factory.create('quotes-transit', VIEW_STORE)
    services_view_store = mongo_factory.create('services-transit', VIEW_STORE)
    transit_vlan_tags_data_store = mongo_factory.create('transit-vlantags', VIEW_STORE)

    authentication_token = 'test'
    ENV['SERVICE_ORCHESTRATION_AUTH_TOKEN'] = authentication_token
    expected_assigned_vlan_tag = '520'
    service_reference ='ZRiEKiyK'
    request = {"auth_token"=>authentication_token, "command"=>service_reference}  

    quote = {
                  "_id"=> 'ZRiEKiyK', 
                  "data_centre"=> "Getronics",
                  "transit"=> "Level 3",
                  "capacity"=> "1000Mb",
                  "port_name"=> "CUST=>Manchester_Roller_Derby-JUN-HAL-01-ge-0/0/2",
                  "customer_name"=> "Manual Transit Quote",
                  "customer_asn"=> "789",
                  "type"=> "transit",
                  "vlan_tag"=> '520',
                  "company_name"=> "Manchester Roller Derby",
                  "issued_on"=> "01/02/1990",
                  "term"=> "12 months",
                  "new_ports"=> "0",
                  "total"=> "Â£751"
              }

    vlan = {ProviderName:'Level 3', VlanTag:'520', ASN:''}

    transit_vlan_tags_data_store.save(vlan)

    quote_repo.save(quote)

    transit = Transit.new(message_queue:self)
    service_orchestration = ServiceOrchestration.new(transit:transit)
      browser = Rack::Test::Session.new(Rack::MockSession.new(service_orchestration))
      browser.post '/purchaseTransit', request.to_json, "CONTENT_TYPE" => "application/json"

    saved_service = services_view_store.find("_id" => service_reference).to_a[0]

    transit_provider = saved_service["transit_port"]["provider"]

    vlans = transit_vlan_tags_data_store.find("service_reference" => service_reference)
    
    assigned_vlan_in_data_store = vlans.to_a[0]

    assert_equal(vlans.count, 1)

    assert_equal(expected_assigned_vlan_tag, assigned_vlan_in_data_store["VlanTag"])
    assert_equal(service_reference, assigned_vlan_in_data_store["service_reference"])
    assert_equal(service_reference, assigned_vlan_in_data_store["_id"])
    assert_equal(saved_service["customer_asn"], assigned_vlan_in_data_store["ASN"])
  end

  def push(something)
    @pushed_message = something
  end

end

