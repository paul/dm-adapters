require 'rubygems'
require 'dm-core'
require 'dm-types'
require 'pathname'
require Pathname(__FILE__).dirname + 'lib/active_resource_adapter'

DataMapper.setup(:default, :adapter => :active_resource, :site => "http://localhost:3000/")

class Person
  include DataMapper::Resource

  property :id,         Integer, :key => true
  property :name,       String
  property :created_at, DateTime
  property :updated_at, DateTime

end

people = Person.all
puts people.inspect

person = Person.get(1)
puts person.inspect

new_person = Person.new(:name => 'Eric')
new_person.save
puts new_person.inspect

new_person.name = "Erik"
new_person.save
puts new_person.inspect


