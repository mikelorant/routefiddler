require 'thor'

module Routefiddler
  # Routefilter::Commandline
  class Commandline < Thor
    package_name 'RouteFiddler'
    map ['-v', '--version'] => :version

    desc 'version', 'Print the version and exit.'

    def version
      puts Routefiddler::VERSION
    end

    desc 'update [key=value ...]', 'Filter options'
    method_option :role_arn, type: :string,  aliases: '-a', desc: 'Optional role arn.'
    method_option :region,   type: :string,  aliases: '-r', desc: 'Optional region.'

    def update
      Routefiddler::Route.new(options).update(options)
    end
  end
end
