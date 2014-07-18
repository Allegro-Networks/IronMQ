require 'bundler/setup'
require 'test/unit'
require 'rack/test'
require 'json'
require 'nokogiri'
require_relative '../../../ServiceOrchestration'
require_relative '../../../src/ServicesViewStore'
require_relative '../../../src/SnapConnect/SnapConnect'

class TestSnapConnectWithNoVLANTag < Test::Unit::TestCase
  include Rack::Test::Methods

  VIEW_STORE = ENV['VIEW_STORE_CONNECTION_STRING']

  EXPECTED_SERVICE = {
  	"_id"=>"z7h21kds",
    "ordered_at"=>"02/06/2014 04:27PM",
  	"type"=>"p2pvlan",
  	"data_centres"=>["Telehouse East", "Global Crossing Preston"], 
  	"customer_asn"=>"12536", 
  	"company_name"=>"Vodafone", 
  	"capacity"=>"100Mb", 
  	"price"=>"£330", 
  	"term"=>"12 months", 
  	"ports"=>[
  		{
  			"port"=>"ge-1/0/2", 
  			"data_centre"=>"Telehouse East", 
  			"size"=>"1Gb", 
  			"configured"=>"false"
  		}, 
  		{
  			"port"=>"ge-1/0/0", 
  			"data_centre"=>"Global Crossing Preston", 
  			"size"=>"1Gb", 
  			"configured"=>"true"
  		}
  	], 
  	"aEndPort"=>{"name"=>"Waiting", "configured"=>""}, 
  	"bEndPort"=>{"name"=>"Waiting", "configured"=>""}, 
  	"status"=>{"bEndStatus"=>"Configuring", "aEndStatus"=>"Configuring"}
  }

  def test_purchase_snapconnect_actions_quote
    mongo_factory = MongoFactory.new
    quote_repo = mongo_factory.create('quotes', VIEW_STORE)
    services_view_store = mongo_factory.create('services-p2pvlan', VIEW_STORE)
    services_view_store.remove({_id:EXPECTED_SERVICE["_id"]})
    
    authentication_token = 'test'
    ENV['SERVICE_ORCHESTRATION_AUTH_TOKEN'] = authentication_token

    request = {"auth_token"=>authentication_token, "command"=>"z7h21kds"}  


    quote = {
              _id: "z7h21kds",
              a_end: {
                data_centre: "Telehouse East",
                port: "1Gb",
                customer_asn: "12536",
                customer_name: "James Jeffries"
              },
              b_end: {
                data_centre: "Global Crossing Preston",
                port: 'ge-1/0/0', 
                customer_asn: "41963"
              },
              connectingCompany: "Allegro Networks",
              company_name: "Vodafone",
              capacity: "100Mb",
              customer_name: "James Jeffries",
              customer_asn: "12536",
              issued_on: "22/05/2014",
              quote_reference: "z7h21kds",
              term: "12 months",
              expires_on: "29/05/2014",
              instigator: {
                userName: "James Jeffries",
                email: "james.jeffries@allegro.net",
                ASN: "12536"
              },
              price_breakdown: {
                total: "£330",
                port_price: "£150",
                service_price: "£180"
              },
              total: "£330",
              status:'accepted',
              whopays: 'both',
              vlan_tag: '765'
            }

    the_device_summary = {
        "_id" => "LAB-THE-01",
        "name" =>"Telehouse East",
        "ports" =>[
          {
            "name" =>"ge-1/0/2",
            "speed" =>"1000mbps",
            "oper_status" =>"down",
            "config" =>"",
            "description" =>"",
            "l2_circuits" =>[],
            "routing_instances" =>[]
          }
        ],
        "routing_instances" =>[],
        "l2_circuits" =>[]
      }

    device_summary_repo = mongo_factory.create('device-summary',ENV['VIEW_STORE_CONNECTION_STRING'])
    device_summary_repo.remove({"_id" =>the_device_summary["_id"]})
    device_summary_repo.save(the_device_summary)
    

    existing_b_end_port = {
			name: "CUST:TEST Money SuperMarket (AS41963)",
			size: "1Gb",
			data_centre: "Global Crossing Preston",
			unit_name: "1244",
			type: "multi",
			port: "ge-1/0/0",
			customer_asn: "41963",
			device: "LAB-PRE-01",
			description: "CUST:TEST Money SuperMarket (AS41963)",
			routing_instances: [
				"1ZnX0nqv"
			],
			l2_circuits: [],
			friendly_name: "(ge-1/0/1) 1Gb with 1 service",
			services: [
				"1ZnX0nqv"
			]
		}

  	ports_repo = mongo_factory.create('ports',ENV['DATA_STORE_CONNECTION_STRING'])
  	ports_repo.save(existing_b_end_port)

    message = {
                    _id:quote[:quote_reference], 
                    type:'point-to-point-vlan'
                }
    quote_repo.remove({})
    quote_repo.save(quote)

    snap_connect = SnapConnect.new(message_queue:self)
    snap_connect.provision(request["command"])
    # service_orchestration = ServiceOrchestration.new(snap_connect:snap_connect)
    # browser = Rack::Test::Session.new(Rack::MockSession.new(service_orchestration))
    # browser.post '/snapconnect', request.to_json, "CONTENT_TYPE" => "application/json"


    assert_equal(quote_repo.find({}).to_a.count, 1)

    saved_service = services_view_store.find("_id" => quote[:quote_reference]).to_a[0]
    assert_equal(EXPECTED_SERVICE["_id"], saved_service["_id"])
    assert_equal(EXPECTED_SERVICE["type"], saved_service["type"])
    assert_equal(EXPECTED_SERVICE["data_centres"], saved_service["data_centres"])
    assert_equal(EXPECTED_SERVICE["customer_asn"], saved_service["customer_asn"])
    assert_equal(EXPECTED_SERVICE["company_name"], saved_service["company_name"])
    assert_equal(EXPECTED_SERVICE["capacity"], saved_service["capacity"])
    assert_equal(EXPECTED_SERVICE["price"], saved_service["price"])
    assert_equal(EXPECTED_SERVICE["term"], saved_service["term"])
    assert_equal(EXPECTED_SERVICE["ports"], saved_service["ports"])
    assert_equal(message, @pushed_message)
  end

  def push(message)
    @pushed_message = message
  end

end
