module Routefiddler
  # Routefiddler::Update
  module Route
    class Update < Core
      def update
        create_routes(filtered_route_tables, instance_id)

        show_route_tables filtered_route_tables
      end

      def create_routes(route_tables, instance_id)
        route_tables.each do |route_table|
          @ec2.create_route(
            route_table_id: route_table,
            destination_cidr_block: DEFAULT_CIDR_BLOCK,
            instance_id: instance_id
          )
        end
      rescue Aws::EC2::Errors::RouteAlreadyExists
        route_tables.each do |route_table|
          @ec2.replace_route(
            route_table_id: route_table,
            destination_cidr_block: DEFAULT_CIDR_BLOCK,
            instance_id: instance_id
          )
        end
      end

      def show_route_tables(route_tables)
        puts 'Updated the following route tables:'
        route_tables.each do |rt|
          puts "  #{rt}"
        end
        puts
      end
    end
  end
end

