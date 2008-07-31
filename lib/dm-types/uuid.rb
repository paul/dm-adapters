require 'rubygems'
require 'uuidtools'

module DataMapper
  module Types
    class UUID < DataMapper::Type
      primitive String

      def self.load(value, property)
        ::UUID.parse(value)
      end

      def self.dump(value, property)
        return nil if value.nil?
        value.to_s
      end

      def self.typecast(value, property)
        value.kind_of?(::UUID) ? value : load(value.to_s, property)
      end
    end
  end
end


