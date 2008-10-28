= dm-is-configurable

THIS IS A WORK-IN-PROGRESS!

The plugin allows you to add configuration to your models. 

Example usage:

require 'dm-is-configurable'

class Kitteh
  include DataMapper::Resource

  property :id, Serial
  property :name, String

  is :configurable, 
    :cheezburger_limit, :be_cute => :boolean
end

# create configuration options for kittehs
Kitteh.auto_migrate!
Kitteh.setup_configuration

cute_one = Kitteh.new(:name => 'Cute Kitteh')
ugly_one = Kitteh.new(:name => 'Ugly Kitteh')

# provides convenient configuration writers...
cute_one.configuration[:be_cute] = true
cute_one.configuration[:cheezburger_limit] = 10

ugly_one.configuration = {
  :be_cute => false,
  :cheezburger_limit => 100
}

# ...and convenient configuration readers
cute_one.configuration.be_cute? # => true
ugly_one.configuration.be_cute? # => false

cute_one.configuration.cheezburger_limit # => 10
ugly_one.configuration.cheezburger_limit # => 100