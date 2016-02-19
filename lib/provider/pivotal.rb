module TaskMapper::Provider
  module PivotalAccessor

    def pivotal_client
      Thread.current['TaskMapper::Provider::PivotalAccessor.pivotal']
    end

    def pivotal_client=(pivotal_client)
      Thread.current['TaskMapper::Provider::PivotalAccessor.pivotal'] = pivotal_client
    end

  end


  # This is the Pivotal Tracker Provider for taskmapper
  module Pivotal
    include TaskMapper::Provider::Base

    def self.new(auth = {})
      TaskMapper.new(:pivotal, auth)
    end
    
    def authorize(auth = {})
      @authentication ||= TaskMapper::Authenticator.new(auth)
      auth = @authentication
      
      self.pivotal_client = TrackerApi::Client.new(token: auth.access_token)
      begin
        self.pivotal_client.me
        @valid_auth = true
      rescue
        @valid_auth = false
      end
    end

    def valid?
      @valid_auth
    end

    def pivotal_client
      Thread.current['TaskMapper::Provider::PivotalAccessor.pivotal']
    end

    def pivotal_client=(pivotal_client)
      Thread.current['TaskMapper::Provider::PivotalAccessor.pivotal'] = pivotal_client
    end
    
  end
end
