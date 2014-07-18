require 'bundler/setup'
require 'test/unit'
require 'rack/test'
require 'json'
require 'nokogiri'
require_relative '../../ServiceOrchestration'
require_relative '../../src/ServicesViewStore'
require_relative '../../src/P2pVlanServiceFactory'
require_relative '../../src/Repository/P2PVlanQuoteViewStore'
require_relative '../../src/Repository/PortsRepository'
require_relative '../../src/Repository/DeviceSummaryRepository'

class TestP2PVLANService < Test::Unit::TestCase
  include Rack::Test::Methods

  def create(repository_type,connection_string="")
    if repository_type == 'quotes-p2pvlan'
      return @mongo_quotes
    end
    if repository_type == 'services-p2pvlan'
      return @mongo_services
    end
    if repository_type == 'ports'
      return @mongo_ports
    end
    if repository_type == 'device-summary'
      return @mongo_device_summary
    end
  end

  expected_service = {
    _id: "xyLn47pn",
    ordered_at: "23/04/2014 09:33AM",
    type: "p2pvlan",
    vlan_tag: "101",
    data_centres: [
      "Telehouse North",
      "Alphadex"
    ],
    customer_asn: "12536",
    company_name: "Test Name",
    capacity: "1000Mb",
    price: "£150",
    term: "12 months",
    new_ports: 1,
    ports: [
      {
        configured: "true",
        port: "ge-0/0/1",
        size: "1",
        data_centre: "Telehouse North"
      },
      {
        configured: "false",
        port: "ge-0/0/2",
        size: "1",
        data_centre: "Alphadex"
      }
    ],
    aEndPort: {
      name: "Waiting",
      configured: ""
    },
    bEndPort: {
      name: "Waiting",
      configured: ""
    },
    status: {
      bEndStatus: "Configuring",
      aEndStatus: "Configuring"
    }
  }

  def test_purchase_service_actions_quote
    authentication_token = 'test'
    ENV['SERVICE_ORCHESTRATION_AUTH_TOKEN'] = authentication_token
    @loaded_config = []
    @label = 4
    request = {"auth_token"=>authentication_token, "command"=>"ZRiEKiyK"}  

    @mongo_quotes = MongoWrapper.new('connection string','quotes-p2pvlan',FakeMongo)
    @mongo_services = MongoWrapper.new('connection string','services-p2pvlan',FakeMongo)
    @mongo_ports = MongoWrapper.new('connection string','ports',FakeMongo)
    @mongo_device_summary = MongoWrapper.new('connection string','device-summary',FakeMongo)
    
    message = {
                  _id:'ZRiEKiyK', 
                  type:'point-to-point-vlan'
              }

    quote_repository = P2PVlanQuoteViewStore.new(self)
    services_view_store = P2PVlanServicesViewStore.new(self)
    ports_repository = PortsRepository.new(mongo_factory:self)
    device_summary_repo = DeviceSummaryRepository.new(mongo_factory:self)
    service_factory = P2pVlanServiceFactory.new(ports_repo:ports_repository, device_summary_repo:device_summary_repo)

    pointToPointVlan = PointToPointVlan.new(quote_repository, services_view_store, service_factory, self, ports_repository)

    pointToPointVlan.action(message[:_id])

    saved_service = services_view_store.find('ZRiEKiyK')
    assert_equal('ge-0/0/1', saved_service[:ports][0][:port])
    assert_equal('1Gb', saved_service[:ports][0][:size])
    assert_equal('Telehouse North', saved_service[:ports][0][:data_centre])
    assert_equal('true', saved_service[:ports][0][:configured])
    assert_equal('ge-0/0/2', saved_service[:ports][1][:port])
    assert_equal('1Gb', saved_service[:ports][1][:size])
    assert_equal('Alphadex', saved_service[:ports][1][:data_centre])
    assert_equal('false', saved_service[:ports][1][:configured])
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
    if(@repo_type == 'services-p2pvlan')      
      @entry = entry
    end
  end

  def find(key)
    if(@repo_type == 'services-p2pvlan')
      return [@entry]
    end
    if(@repo_type == 'quotes-p2pvlan')      
       quote = [{ 
              "_id"=> 'ZRiEKiyK', 
              "a_end"=> "Telehouse North", 
              "b_end"=> "Alphadex", 
              "capacity"=> "500Mb", 
              "port_size"=> "1Gb", 
              "vlan_tag" => '210',
              "customer_name"=> "Dave Heath", 
              "customer_asn"=> "12536",
              "customer_telephone"=> "999", 
              "company_name"=> "Laterooms.com", 
              "issuer_name"=> "Al Egro", 
              "issued_on"=> "15/08/2013", 
              "expires_on"=> "14/09/2013",
              "quote_reference"=> "ZRiEKiyK", 
              "term"=> "12 months", 
              "new_ports" => "1",
              "ports"=> [
                          {
                            "name" => "CUST:Manchester_Roller Derby-JUN-BEN-01-ge-0/0/1"
                          }, 
                          {
                            'name' => 'new', 
                            'size'=> '1Gb', 
                            'data_centre'=>'Alphadex'
                          }
                        ], 
              "total"=> "£675" 
            }]
      return quote
    end
    if(@repo_type == 'ports')
      return [{
        "name" => "CUST:Manchester_Roller Derby-JUN-BEN-01-ge-0/0/1",
        "size" => "1Gb",
        "data_centre" => "Telehouse North",
        "unit_name" => "2",
        "type" => "multi",
        "port" => "ge-0/0/1",
        "customer_asn" => "12536",
        "device" => "LAB-THN-01",
        "description" => "CUST:Manchester_Roller Derby-JUN-BEN-01-ge-0/0/1",
        "routing_instances" => [
          "XDk0o9xa"
        ],
        "l2_circuits" => [],
        "friendly_name" => "(ge-0/0/1) 1Gb with 1 service",
        "services" => [
          "XDk0o9xa"
        ]
      }]
    end
    if(@repo_type == 'device-summary')
      return [{
        "_id" => "LAB-ALP-01",
        "name" =>"Alphadex",
        "ports" =>[
          {
            "name" =>"ge-0/0/2",
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
      }]
    end
  end
end



