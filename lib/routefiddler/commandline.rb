require 'thor'

module Routefiddler
  # Routefilter::Commandline
  class Commandline < Thor
    package_name 'RouteFiddler'
    map ['-v', '--version'] => :version

    class_option :instance_id, type: :string,  aliases: '-i', desc: 'Optional instance id.'
    class_option :role_arn,    type: :string,  aliases: '-a', desc: 'Optional role arn.'
    class_option :region,      type: :string,  aliases: '-r', desc: 'Optional region.'

    desc 'version', 'Print the version and exit.'
    def version
      puts Routefiddler::VERSION
    end

    desc 'update', 'Updated routing tables that do not have a default route.'
    def update
      Routefiddler::Route::Update.new(options).update
    end

    desc 'takeover', 'Takeover routing tables default route.'
    def takeover
      Routefiddler::Route::Takeover.new(options).takeover
    end

    desc 'find', 'Find routing tables that can be managed.'
    method_option :short,    type: :boolean,  aliases: '-s', desc: 'Short output.'
    def find
      Routefiddler::Route::Find.new(options).find
    end

    desc 'peer', 'Create cross account peering connection.'
    method_option :vpc_id,        require: true, type: :string,  aliases: '-v', desc: 'Requester VPC ID.'
    method_option :peer_vpc_id,   require: true, type: :string,  aliases: '-p', desc: 'Peer VPC ID.'
    method_option :peer_owner_id, require: true, type: :string,  aliases: '-o', desc: 'AWS account ID of peer VPC.'
    method_option :description,   require: true, type: :string,  aliases: '-d', desc: 'Peer connection descriptipn.'
    method_option :peer_role_arn,                type: :string,  aliases: '-l', desc: 'Optional peer role arn.'
    def peer
      Routefiddler::Peer::Create.new(options).create
    end
  end
end
