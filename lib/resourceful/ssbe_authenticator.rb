module Resourceful

  class SSBEAuthenticator
    require 'httpauth'
    require 'addressable/uri'


    attr_reader :username, :password, :realm, :domain, :challenge

    def initialize(username, password)
      @username, @password = username, password
      @realm = 'SystemShepherd'
      @domain = nil
    end

    def update_credentials(challenge_response)
      @domain = Addressable::URI.parse(challenge_response.uri).host
      @challenge = HTTPAuth::Digest::Challenge.from_header(challenge_response.header['WWW-Authenticate'].first)
    end

    def valid_for?(challenge_response)
      return false unless challenge_header = challenge_response.header['WWW-Authenticate']
      begin
        challenge = HTTPAuth::Digest::Challenge.from_header(challenge_header.first)
      rescue HTTPAuth::UnwellformedHeader
        return false
      end
      challenge.realm == @realm
    end

    def can_handle?(request)
      Addressable::URI.parse(request.uri).host == @domain
    end

    def add_credentials_to(request)
      request.header['Authorization'] = credentials_for(request)
    end

    def credentials_for(request)
      HTTPAuth::Digest::Credentials.from_challenge(@challenge, 
                                                   :username => @username,
                                                   :password => @password,
                                                   :method   => request.method.to_s.upcase,
                                                   :uri      => Addressable::URI.parse(request.uri).path).to_header
    end

  end

end

