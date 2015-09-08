require 'aws-sdk'

module Routefiddler
  # Routefiddler::Route
  class Route
    def initialize(options = {})
      Routefiddler::Config.new.setup(options)
      @ec2 = Aws::EC2::Client.new
    end

    def update(options = {})
      puts options
    end
  end
end
