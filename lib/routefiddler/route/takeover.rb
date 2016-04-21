module Routefiddler
  # Routefiddler::Takeover
  module Route
    class Takeover < Core
      def takeover
        create_routes(filtered_route_tables, instance_id)

        show_route_tables filtered_route_tables
      end
    end
  end
end
