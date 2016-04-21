require 'aws-sdk'
require 'httparty'
require 'memoist'

module Routefiddler
  # Routefiddler::Route
  class Core
    extend Memoist

    INSTANCE_ID = 'http://169.254.169.254/latest/meta-data/instance-id'
    DEFAULT_CIDR_BLOCK = '0.0.0.0/0'
    ROUTE_TABLE_FILTER_KEY = 'aws:cloudformation:logical-id'
    ROUTE_TABLE_FILTER_VALUE = /^Private.RouteTable/

    attr_reader :options

    def initialize(options = {})
      Routefiddler::Config.new.setup(options)
      @cloudformation = Aws::CloudFormation::Client.new
      @ec2 = Aws::EC2::Client.new

      Routefiddler::Config.new.setup(options, 'peer')
      @ec2_peer =  Aws::EC2::Client.new

      @options = options
    end

    private

    def instance_id
      options[:instance_id] || query(INSTANCE_ID)
    end
    memoize :instance_id

    def vpc_id
      @ec2.describe_instances(instance_ids: [instance_id]).reservations.first.instances.first.vpc_id
    end
    memoize :vpc_id

    def routes
      filter_vpc_id(@ec2.describe_route_tables.route_tables, vpc_id)
    end
    memoize :routes

    def filter_vpc_id(route_tables, vpc_id)
      route_tables.select { |rt| rt.vpc_id == vpc_id }
    end

    def route_tables
      rt = routes.select do |route|
        route.tags.any? do |t|
          t.key == ROUTE_TABLE_FILTER_KEY && t.value =~ ROUTE_TABLE_FILTER_VALUE
        end
      end

      rt.map(&:route_table_id)
    end
    memoize :route_tables

    def find_subnets(route_tables)
      find_route_tables(route_tables).map(&:associations).flatten.map(&:subnet_id)
    end

    def find_route_tables(route_tables)
      @ec2.describe_route_tables(route_table_ids: route_tables).route_tables
    end

    def find_cidr(subnets)
      @ec2.describe_subnets(subnet_ids: subnets).subnets.map(&:cidr_block)
    end

    def filtered_route_tables
      rt = find_route_tables route_tables
      missing_default_route(rt).map(&:route_table_id)
    end
    memoize :filtered_route_tables

    def missing_default_route(route_tables)
      route_tables.reject do |rt|
        rt.routes.any? do |r|
          r.destination_cidr_block == DEFAULT_CIDR_BLOCK && !r.instance_id.nil?
        end
      end
    end

    def query(url)
      Timeout.timeout(2) do
        response = HTTParty.get(url)

        fail Response::Code::Error if response.code != 200

        response.body
      end
    rescue Timeout::Error, Response::Code::Error
      option = convert_symbols metadata_name url
      puts "Unable to determine #{option}."
      nil
    end

    def metadata_name(url)
      url.split('/')[-1]
    end

    def convert_symbols(string)
      string.gsub(/-|_/, ' ')
    end
  end
end

class ResponseCodeError < StandardError
end
