module Routefiddler
  module Peer
  # Routefiddler::Update
    class Create < Core
      def create
        @tags = [
          {
            key: 'Creator',
            value: 'RouteFiddler'
          }
        ]

        create_vpc_peering_connection
        accept_vpc_peering_connection
        tag_vpc_peering_connections
      end

      def create_vpc_peering_connection
        @vpc_peering_connection = @ec2.create_vpc_peering_connection(
          vpc_id: @options[:vpc_id],
          peer_vpc_id: @options[:peer_vpc_id],
          peer_owner_id: @options[:peer_owner_id],
        ).vpc_peering_connection
      end

      def accept_vpc_peering_connection
        @vpc_accept_peering_connection = @ec2_peer.accept_vpc_peering_connection(
          vpc_peering_connection_id: @vpc_peering_connection.vpc_peering_connection_id
        ).vpc_peering_connection
      end

      def tag_vpc_peering_connections
        create_tags(@ec2, @vpc_peering_connection.vpc_peering_connection_id, options[:description])
        create_tags(@ec2_peer, @vpc_accept_peering_connection.vpc_peering_connection_id, switch(options[:description]))
      end

      def create_tags(resource, vpc_peering_connection_id, name=nil)
        tags = @tags.clone
        tags.push(
          key: 'Name',
          value: name
        ) if name

        resource.create_tags(
          resources: [vpc_peering_connection_id],
          tags: tags
        )
      end

      def show_result
        puts vpc_accept_peering_connection.status.code
      end

      def switch(text)
        if text.include? ' to '
          text.split(' to ').reverse.join(' to ')
        else
          text
        end
      end
    end
  end
end
