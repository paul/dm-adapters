require 'rubygems'
require 'resourceful'
require 'rexml/document'
gem 'dm-core', '>=0.9.4'

require 'pathname'

module DataMapper
  module Adapters

    class HttpAdapter < AbstractAdapter
      attr_reader :http

      def initialize(name, uri_or_options)
        super

        @http = Resourceful::HttpAccessor.new
        @http.cache_manager = Resourceful::InMemoryCacheManager.new
        @http.logger = Resourceful::StdOutLogger.new
      end
    end

    class ActiveResourceAdapter < HttpAdapter
      MIME_TYPE = 'application/xml'

      def initialize(name, uri_or_options)
        super

        @site_uri = uri_or_options[:site]
      end

      def read_many(query)
        unless query.model.collection_resource
          collection_uri = @site_uri + query.model.storage_name(query.repository.name)
          query.model.collection_resource = @http.resource(collection_uri, :accept => MIME_TYPE)
        end

        doc = REXML::Document.new(query.model.collection_resource.get.body)

        Collection.new(query) do |collection|
          doc.elements.each('people/person') do |item|
            collection.load(
              query.fields.map { |prop| item.elements[prop.field.to_s.gsub('_', '-')].text }
            )
          end
        end     
      end

      def read_one(query)
        uri = query.model.collection_resource.uri + '/' + query.conditions.first[2].to_s

        resource = @http.resource(uri, :accept => MIME_TYPE)

        doc = REXML::Document.new(resource.get.body)

        query.model.load(query.fields.map { |prop| doc.root.elements[prop.field.to_s.gsub('_', '-')].text }, query)
      end

      require 'pp'
      require 'active_support'
      def create(resources)
        resources.each do |resource|   
          doc =  resource.attributes.to_xml({:root => Extlib::Inflection.underscore(resource.model.to_s)})

          result = resource.model.collection_resource.post(doc, :content_type => MIME_TYPE)
          if result.was_successful?
            resource.model.key(resource.model.repository.name).first.set!(resource, result.header['Location'].first.split('/').last)
          end
        end
        1
      end

      def update(attributes, query)
        doc = attributes.to_xml({:root => query.model.to_s.downcase})

        uri = query.model.collection_resource.uri + '/' + query.conditions.first[2].to_s
        resource = @http.resource(uri, :accept => MIME_TYPE)
        result = resource.put(doc, :content_type => MIME_TYPE)
      end

      def delete(query)

      end

    end

  end

  module Model
    attr_accessor :collection_resource

  end
end

