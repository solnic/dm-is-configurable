module DataMapper
  module Is
    module Configurable
      
      VALID_TYPES = [:boolean, :string, :integer, :float]
  
      class InvalidConfigurationOptions < StandardError
        def initialize(who, errors)
          super("Class '#{who}' has invalid types for the following options: #{errors.map{|v,k| "#{v} => #{k}"}.join(', ')}")
        end
      end
      
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

      def is_configurable(options={})
        extend  DataMapper::Is::Configurable::ClassMethods
        include DataMapper::Is::Configurable::InstanceMethods
        
        has n, :options, :class_name => 'ConfigurationOption', :child_key => [:configurable_id]
        
        unless options[:with].nil?
          self.configuration_options = options[:with]
          self.validate_configuration_options
        end
      end
      
      module ClassMethods
        attr_accessor :configuration_options
        
        def setup_configuration
          self.configuration_options.each do |name, properties|
            Configuration.create(
              :name => name, 
              :type => properties[:type] == :string ? nil : properties[:type], 
              :default => properties[:default],
              :model_class => self
            )
          end
        end
        
        def validate_configuration_options
          errors = {}
          
          self.configuration_options.each do |name, properties|
            unless Configurable::VALID_TYPES.include?(properties[:type])
              errors[name] = properties[:type]
            end
          end
          
          raise InvalidConfigurationOptions.new(self, errors) if errors.keys.size > 0
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
          if (value = DataMapper::Types::Option.dump(value.to_s)) != configuration.default
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
          end
          option
        end
        
        def options_get(name)
          configuration, option = fetch_configuration_option(name)
          option_value = option.nil? ? configuration.default : option.value
          case configuration.type
          when 'boolean'
            option_value == '1'
          when 'integer'
            option_value.to_i
          when 'float'
            option_value.to_f
          else
            option_value
          end
        end
        
        private
        
        def fetch_configuration_option(name)
          # TODO: this should be fetched using one query!
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
          @configurable.class.configuration_options.keys.each{ |name| options[name] = @configurable.options_get(name) }
          options
        end
        
        def [](name)
          @configurable.options_get(name)
        end
        
        def []=(name, value)
          @configurable.options_set(name, value)
        end
        
        def method_missing(method_name, *args)
          if @configurable.class.configuration_options.keys.include?((option_name = method_name.to_s.gsub(/\?$/, '').to_sym))
            self[option_name]
          else
            super(method_name, *args)
          end
        end
      end # ConfigurationProxy

    end # Configurable
  end # Is
end # DataMapper
