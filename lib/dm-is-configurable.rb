# Needed to import datamapper and other gems
require 'rubygems'
require 'pathname'

# Add all external dependencies for the plugin here
gem 'dm-core', '=0.9.7'
require 'dm-core'

# Require plugin-files
require Pathname(__FILE__).dirname.expand_path / 'dm-is-configurable' / 'is' / 'configurable.rb'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-configurable' / 'types' / 'option'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-configurable' / 'configuration_option'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-configurable' / 'configuration'

# Include the plugin in Resource
module DataMapper
  module Resource
    module ClassMethods
      include DataMapper::Is::Configurable
    end # module ClassMethods
  end # module Resource
end # module DataMapper
