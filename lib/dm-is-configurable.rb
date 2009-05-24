# Needed to import datamapper and other gems
require 'rubygems'
require 'pathname'

# Add all external dependencies for the plugin here
gem 'dm-core', '>=0.10'
gem 'dm-validations', '>=0.10'

require 'dm-core'
require 'dm-validations'

# Require plugin-files
require Pathname(__FILE__).dirname.expand_path / 'dm-is-configurable' / 'is' / 'configurable.rb'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-configurable' / 'types' / 'option'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-configurable' / 'configuration_option'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-configurable' / 'configuration'

# Include the plugin in Resource
module DataMapper
  module Model
    include DataMapper::Is::Configurable
  end # module Model
end # module DataMapper
