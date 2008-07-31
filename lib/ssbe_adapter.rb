require 'rubygems'
require 'resourceful'
require 'json'
gem 'dm-core', '>=0.9.3'

require 'pathname'
require Pathname(__FILE__).dirname + 'resourceful/ssbe_authenticator'
require Pathname(__FILE__).dirname + 'dm-types/uuid'

module DataMapper
  module Adapters

    class HttpAdapter < AbstractAdapter
      attr_reader :http

      def initialize(name, uri_or_options)
        super

        @http = Resourceful::HttpAccessor.new
      end
    end

    class SsbeAdapter < HttpAdapter

      def initialize(name, uri_or_options)
        super

        http.cache_manager = Resourceful::InMemoryCacheManager.new
        http.logger = Resourceful::StdOutLogger.new
        http.auth_manager.add_auth_handler Resourceful::SSBEAuthenticator.new('dev', 'dev')

        service_descriptor_uri = uri_or_options[:service_descriptor_uri]
        @service_descriptor = @http.resource(service_descriptor_uri).get.body
        @service_descriptor = JSON.parse(@service_descriptor)
      end

      def read_many(query)
        model         = query.model
        puts "Model:", query.inspect
        service_type  = model.service_type
        resource_name = model.resource_name
        parser        = model.parser

        unless model.resource
          resource_descriptor_uri = @service_descriptor["items"].find { |i| i["service_type"] == service_type }["href"]
          resource_descriptor = JSON.parse(@http.resource(resource_descriptor_uri).get.body)

          resource_uri = resource_descriptor["resources"].find { |i| i["name"] == resource_name }["href"]
          model.resource = @http.resource(resource_uri, :accept => parser.mime_type)
        end

        doc = parser.deserialize(model.resource.get.body)

        Collection.new(query) do |collection|
          doc['items'].each do |item|
            collection.load(
              query.fields.map { |prop| item[prop.field.to_s] }
            )
          end
        end     
      end

      def read_one(query)
        uri = query.conditions.first[2]
        parser = query.model.parser

        resource = @http.resource(uri, :accept => parser.mime_type)

        doc = parser.deserialize(resource.get.body)

        query.model.load(query.fields.map { |prop| doc[prop.field.to_s] }, query)
      end


      class Parser

        def self.mime_type(mime_type)
          @@mime_type = mime_type
        end

        def mime_type
          @@mime_type
        end

      end

      class SSJParser < Parser
        mime_type 'application/vnd.absolute-performance.sysshep+json'

        def deserialize(body)
          JSON.parse(body)
        end

      end

    end


  end

  module Model
    attr_reader :service_type, :resource_name, :parser
    attr_accessor :resource

    def set_service_type(uri_or_type)
      @service_type = case uri_or_type
                      when String then uri_or_type
                      when :kernel
                        'http://systemshepherd.com/services/kernel'
                      else
                        raise "Unknown service type"
                      end
    end

    def set_resource_name(name)
      @resource_name = name
    end

    def set_parser(parser)
      @parser = parser
    end

  end
  
end

