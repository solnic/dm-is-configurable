module DataMapper
  module Is
    module Configurable

      ##
      # fired when your plugin gets included into Resource
      #
      def self.included(base)
        
      end

      ##
      # Methods that should be included in DataMapper::Model.
      # Normally this should just be your generator, so that the namespace
      # does not get cluttered. ClassMethods and InstanceMethods gets added
      # in the specific resources when you fire is :configurable
      ##

      def is_configurable(*args)
        self.cattr_accessor(:configuration_options)
        self.configuration_options = {}
        
        args.each { |a| a.is_a?(Hash) ? 
          self.configuration_options.merge!(a) : self.configuration_options[a] = nil 
        }
        
        has n, :options, :class_name => 'ConfigurationOption', :child_key => [:configurable_id]
        
        extend  DataMapper::Is::Configurable::ClassMethods
        include DataMapper::Is::Configurable::InstanceMethods
      end
      
      module ClassMethods
        
        def setup_configuration
          self.configuration_options.each do |name, type|
            Configuration.create(:name => name, :model_class => self, :type => type)
          end
        end
        
      end # ClassMethods

      module InstanceMethods
        
        def configuration
          @configuration_proxy ||= ConfigurationProxy.new(self)
        end
        
        def configuration=(options)
          options.each {|v, k| options_set(v, k)}
        end
        
        def options_set(name, value)
          configuration, option = fetch_configuration_option(name)
          if option.nil?
            params = {:configuration_id => configuration.id, :value => value}
            if new_record?
              option = self.options.build(params)
            else
              option = ConfigurationOption.create(params.merge!(:configurable_id => id))
            end
          else
            option.update_attributes(:value => value)
          end
          option
        end
        
        def options_get(name)
          configuration, option = fetch_configuration_option(name)
          option.nil? ? nil : configuration.type == 'boolean' ? 
            option.value == '1' : option.value
        end
        
        private
        
        def fetch_configuration_option(name)
          configuration = Configuration.first(:name => name, :model_class => self.class.to_s)
          [configuration, configuration.options.first(:configurable_id => id)]
        end
        
      end # InstanceMethods
      
      class ConfigurationProxy
        def initialize(configurable)
          @configurable = configurable
        end
        
        def all
          options = {}
          @configurable.options.map{ |o| options[o.name] = o.value }
          options
        end
        
        def [](name)
          @configurable.options_get(name)
        end
        
        def []=(name, value)
          @configurable.options_set(name, value)
        end
        
        def method_missing(method_name, *args)
          if @configurable.configuration_options.keys.include?((option_name = method_name.to_s.gsub(/\?$/, '').to_sym))
            self[option_name]
          else
            super(method_name, *args)
          end
        end
      end # ConfigurationProxy

    end # Configurable
  end # Is
end # DataMapper
