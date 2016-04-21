module Routefiddler
  # Routefiddler::Find
  module Route
    class Find < Core
      def find
        subnets = find_subnets route_tables
        cidr = find_cidr subnets

        show_cidr cidr
      rescue Aws::EC2::Errors::InvalidInstanceIDNotFound
        puts "Unable to find instance id: #{instance_id}"
        exit 1
      end

      def show_cidr(cidr)
        if options[:short]
          puts cidr.join("\n")

          return
        end

        puts 'Subnets managed:'
        cidr.each do |c|
          puts "  #{c}"
        end
        puts
      end
    end
  end
end
