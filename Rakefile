require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: run unit tests.'
task :default => :spec

desc "Run all tests"
task :test => :spec

desc "Verify Resourceful against it's specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << 'lib'
  t.pattern = 'spec/**/*_spec.rb'
end

begin
  gem 'yard', '>=0.2.3'
  require 'yard'
  desc 'Generate documentation for dm-abstract_rest_adapter.'
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb', 'README']
  end
rescue Exception
  # install YARD to generate documentation
end

desc 'Removes all temporary files'
task :clean

##############################################################################
# Packaging & Installation
##############################################################################

DM_ABSTRACT_REST_ADAPTER_VERSION = "0.0.1"

windows = (PLATFORM =~ /win32|cygwin/) rescue nil

SUDO = windows ? "" : "sudo"

task :'dm-abstract_rest_adapter' => [:clean, :rdoc, :package]

spec = Gem::Specification.new do |s|
  s.name         = "dm-abstract_rest_adapter"
  s.version      = DM_ABSTRACT_REST_ADAPTER_VERSION
  s.platform     = Gem::Platform::RUBY
  s.author       = "Paul Sadauskas"
  s.email        = "psadauskas@gmail.com"
  s.homepage     = "https://github.com/paul/dm-abstract_rest_adapter/tree/master"
  s.summary      = "A generic DataMapper adapter for talking to ReST-based web servers."
  s.description  = s.summary
  s.rubyforge_project = 'dm-abstract_rest_adapter'
  s.require_path = "lib"
  s.files        = %w( MIT-LICENSE README.markdown Rakefile ) + Dir["{spec,lib}/**/*"]

  # rdoc
  s.has_rdoc         = false

  # Dependencies
  s.add_dependency "dm-abstract_rest_adapter"
  s.add_dependency "rspec"

  s.required_ruby_version = ">= 1.8.6"
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc "Run :package and install the resulting .gem"
task :install => :package do
  sh %{#{SUDO} gem install --local pkg/dm-abstract_rest_adapter-#{DM_ABSTRACT_REST_ADAPTER_VERSION}.gem --no-rdoc --no-ri}
end

desc "Run :clean and uninstall the .gem"
task :uninstall => :clean do
  sh %{#{SUDO} gem uninstall dm-abstract_rest_adapter}
end

