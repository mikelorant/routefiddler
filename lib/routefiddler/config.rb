require 'aws-sdk'

module Routefiddler
  # Routefiddler::Config
  class Config
    REGION = 'ap-southeast-2'

    def setup(options = {}, role_session_name=nil)
      @options = options
      @role_session_name = role_session_name

      Aws.config.replace(config)
    end

    private

    def config
      config = { region: REGION }

      case @role_session_name
      when 'peer'
        config.merge!(credentials: role_credentials(@options[:peer_role_arn])) if @options[:peer_role_arn]
      else
        config.merge!(credentials: role_credentials(@options[:role_arn])) if @options[:role_arn]
      end

      config
    end

    def role_credentials(role_arn)
      Aws::AssumeRoleCredentials.new(
        client: Aws::STS::Client.new(region: REGION),
        role_arn: role_arn,
        role_session_name: @role_session_name || 'default'
      )
    end
  end
end
