require 'aws-sdk'

module Routefiddler
  # Routefiddler::Config
  class Config
    REGION = 'ap-southeast-2'

    def setup(options = {})
      Aws.config.update(config(options))
    end

    private

    def config(options = {})
      config = { region: REGION }
      config.merge!(credentials: role_credentials(options[:role_arn])) if options[:role_arn]
      config
    end

    def role_credentials(role_arn)
      Aws::AssumeRoleCredentials.new(
        client: Aws::STS::Client.new(region: REGION),
        role_arn: role_arn,
        role_session_name: 'session'
      )
    end
  end
end
