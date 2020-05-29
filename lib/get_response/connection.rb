require 'net/http'

module GetResponse

  # Simple class that simulates connection to service
  class Connection
    API_URI = "http://api2.getresponse.com/"

    attr_reader :api_key

    def initialize(api_key)
      @api_key = api_key
      @request_id_prefix = "#{Time.now.to_i}-#{rand(1_000_000_000)}"
      @request_number = -1
    end


    # Test connection with API.
    #
    # returns:: Boolean
    def ping
      result = self.send_request("ping")
      return result["errors"].nil?
    end


    # Get basic info about your account.
    #
    # returns:: GetResponse::Account
    def account
      resp = self.send_request("get_account_info")
      GetResponse::Account.new(resp["result"], self)
    end


    # Method returns proxy to execute all campaign related operations.
    #
    # returns:: GetResponse::CampaignProxy
    def campaigns
      @campaign_proxy ||= GetResponse::CampaignProxy.new(self)
    end


    # Method returns proxy to execute all contact related operations.
    #
    # returns:: GetResponse::ContactProxy
    def contacts
      @contact_proxy ||= GetResponse::ContactProxy.new(self)
    end


    # Method returns proxy to execute all message related operations.
    #
    # returns:: GetResponse::MessageProxy
    def messages
      @message_proxy ||= GetResponse::MessageProxy.new(self)
    end


    # Method returnx proxy to execute all confirmation body related operations.
    #
    # @return [ConfirmationBodyProxy]
    def confirmation_bodies
      @confirmation_body_proxy ||= GetResponse::ConfirmationBodyProxy.new(self)
    end


    # Method returnx proxy to execute all confirmation subject related operations.
    #
    # @return [ConfirmationSubjectProxy]
    def confirmation_subjects
      @confirmation_subject_proxy ||= GetResponse::ConfirmationSubjectProxy.new(self)
    end


    # Send request to JSON-RPC service.
    #
    # method::  String
    #
    # params::  Hash
    def send_request(method, params = {})
      request_params = {
        :id => request_id,
        :method => method,
        :params => [@api_key, params]
      }.to_json

      uri = URI.parse(self.class::API_URI)

      if use_proxy?
        proxy_uri = URI.parse(ENV.fetch('HTTP_PROXY'))
        proxy_host = proxy_uri.host
        proxy_port = proxy_uri.port
      else
        proxy_host = nil
        proxy_port = nil
      end

      resp = Net::HTTP.start(uri.host, uri.port, proxy_host, proxy_port) do |conn|
        conn.post(uri.path, request_params)
      end
      raise GetResponseError.new("API key verification failed") if resp.code.to_i == 403
      raise GetResponseError.new("204 No content response received which signifies interpreting request as notification") if resp.code.to_i == 204
      response = JSON.parse(resp.body)
      raise GetResponse::GetResponseError.new(response["error"]) if response["error"]
      response
    end


    # Method return proxy to execute all links related operations.
    #
    # @return [LinksProxy]
    def links
      @links_proxy ||= LinksProxy.new(self)
    end


    protected

    def use_proxy?
      !ENV.fetch('HTTP_PROXY', nil).nil?
    end

    def build_conditions(conditions)
      conditions.inject({}) do |hash, cond|
        if cond[0].respond_to?(:evaluate)
          hash.merge!(cond[0].evaluate(cond[1]))
        else
          if cond[1].instance_of?(Hash)
            hash.merge!(cond[0] => build_conditions(cond[1]))
          else
            hash.merge!(cond[0] => cond[1])
          end
        end
        hash
      end
    end

    def request_id
      @request_number += 1
      return [@request_id_prefix, @request_number].join("-")
    end

  end

end
