require 'rubygems'
require 'dm-core'
require 'dm-types'
require 'pathname'
require 'uuidtools'
require Pathname(__FILE__).dirname + 'lib/ssbe_adapter'

DataMapper.setup(:default, :adapter => :ssbe, :service_descriptor_uri => 'http://core.ssbe.localhost/service_descriptors')

class Client
  include DataMapper::Resource
  set_service_type  :kernel
  set_resource_name "AllClients"
  set_parser        DataMapper::Adapters::SsbeAdapter::SSJParser.new

  property :name,       String
  property :href,       URI, :key => true
  property :id,         UUID
  property :longname,   String
  property :active,     Boolean

end

clients = Client.all
puts clients.inspect

client = Client.get(clients.first.href)
puts client.inspect

