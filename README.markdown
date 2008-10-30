# dm-is-configurable

## Disclaimer

THIS IS A WORK-IN-PROGRESS!

The plugin allows you to add configuration to your models. 

## Example usage:

    require 'dm-is-configurable'

    class Kitteh
      include DataMapper::Resource

      property :id, Serial
      property :name, String

      is :configurable, :with => { 
        :cheezburger_limit => { :default => 10 }, 
        :be_cute =>           { :default => true }
      }
    end

    # create configuration options for kittehs
    Kitteh.auto_migrate!
    Kitteh.setup_configuration

    cute_one = Kitteh.create(:name => 'Cute Kitteh')
    ugly_one = Kitteh.create(:name => 'Ugly Kitteh')

    # support default values:
    puts cute_one.configuration.be_cute?   # => true
    puts cute_one.configuration[:be_cute]  # => true
    puts cute_one.configuration[:cheezburger_limit] # => 10

    # provides convenient configuration writers:
    ugly_one.configuration[:be_cute] = false
    ugly_one.configuration[:cheezburger_limit] = 100

    puts ugly_one.configuration.be_cute? # => false
    puts ugly_one.configuration[:cheezburger_limit] # => 100

    # or with a bulk assignment:
    ugly_one.configuration = {
      :be_cute => true,
      :cheezburger_limit => 10
    }

    puts ugly_one.configuration.be_cute? # => true
    puts ugly_one.configuration[:cheezburger_limit] # => 10