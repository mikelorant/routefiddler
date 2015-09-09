require 'aws-sdk'
require 'httparty'

module Routefiddler
  # Routefiddler::Route
  class Route
    INSTANCE_ID = 'http://169.254.169.254/latest/meta-data/instance-id'
    DEFAULT_CIDR_BLOCK = '0.0.0.0/0'
    ROUTE_TABLE_FILTER_KEY = 'aws:cloudformation:logical-id'
    ROUTE_TABLE_FILTER_VALUE = /^Private.RouteTable/

    def initialize(options = {})
      Routefiddler::Config.new.setup(options)
      @cloudformation = Aws::CloudFormation::Client.new
      @ec2 = Aws::EC2::Client.new
    end

    def update(options = {})
      instance_id = query(INSTANCE_ID) || 'i-e3b0393d'

      vpc_id = vpc_id instance_id
      routes = routes vpc_id
      route_tables = route_tables routes
      filtered_route_tables = filtered_route_tables route_tables

      filtered_route_tables.each do |route_table|
        @ec2.create_route(
          route_table_id: route_table,
          destination_cidr_block: DEFAULT_CIDR_BLOCK,
          instance_id: instance_id
        )
      end

      show_route_tables filtered_route_tables
    end

    private

    def vpc_id(instance_id)
      @ec2.describe_instances(instance_ids: [instance_id]).reservations.first.instances.first.vpc_id
    end

    def routes(vpc_id)
      filter_vpc_id(@ec2.describe_route_tables.route_tables, vpc_id)
    end

    def filter_vpc_id(route_tables, vpc_id)
      route_tables.select { |rt| rt.vpc_id == vpc_id }
    end

    def route_tables(routes)
      rt = routes.select do |route|
        route.tags.any? do |t|
          t.key == ROUTE_TABLE_FILTER_KEY && t.value =~ ROUTE_TABLE_FILTER_VALUE
        end
      end

      rt.map(&:route_table_id)
    end

    def filtered_route_tables(route_tables)
      rt = @ec2.describe_route_tables(route_table_ids: route_tables).route_tables
      missing_default_route(rt).map(&:route_table_id)
    end

    def missing_default_route(route_tables)
      route_tables.reject do |rt|
        rt.routes.any? do |r|
          r.destination_cidr_block == DEFAULT_CIDR_BLOCK && !r.instance_id.nil?
        end
      end
    end

    def show_route_tables(route_tables)
      puts 'Updated the following route tables:'
      route_tables.each do |rt|
        puts "  #{rt}"
      end
      puts
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
