module DataMapper
  module Is
    module Configurable
      
      VALID_TYPES = [:boolean, :string, :fixnum, :float]
  
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
        
        has n, :options, :model => ConfigurationOption, :child_key => [:configurable_id]
        
        unless options[:with].nil?
          self.configuration_options = options[:with]
          self.prepare_configuration_options
          self.validate_configuration_options
        end
      end
      
      module ClassMethods
        attr_accessor :configuration_options
        
        def setup_configuration(options={})
          unless Configuration.storage_exists? || ConfigurationOption.storage_exists?
            [Configuration, ConfigurationOption].each { |m| m.auto_migrate! }
          end
          
          self.configuration_options.merge!(options) if options
          self.prepare_configuration_options
          self.configuration_options.each do |name, properties|
            conf_properties = { :name => name, 
                :type => properties[:type], 
                :default => properties[:default],
                :model_class => self }
            if configuration = Configuration.first(:name => name, :model_class => self)
              configuration.update(conf_properties)
            else
              Configuration.create(conf_properties)
            end
          end
        end
        
        def prepare_configuration_options
          self.configuration_options.each do |name, properties|
            if properties[:type].nil?
              default_class = properties[:default].class.to_s
              self.configuration_options[name][:type] = default_class == 'NilClass' ? 
                :string : default_class =~ /FalseClass|TrueClass/ ?
                  :boolean : default_class.downcase.to_sym
            end
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
          do_update = DataMapper::Types::Option.dump(value.to_s) != configuration.default
          if do_update && option.nil?
            params = {:configuration_id => configuration.id, :value => value}
            if new?
              option = self.options.new(params)
            else
              option = ConfigurationOption.create(params.merge!(:configurable_id => id))
            end
          elsif !option.nil?
            if do_update
              option.update(:value => value)
            else
              option.destroy
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
          when 'fixnum'
            option_value.to_i
          when 'float'
            option_value.to_f
          else
            option_value
          end
        end
        
        private
        
        def fetch_configuration_option(name)
          configuration = Configuration.first(:name => name, :model_class => self.class.to_s)
          unless new?
            option = configuration.options.first(:configurable_id => id)
          else
            option = self.options.detect { |o| o if o.configuration_id == configuration.id }
          end
          [configuration, option]
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
