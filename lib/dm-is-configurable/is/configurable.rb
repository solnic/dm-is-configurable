module DataMapper
  module Is
    module Configurable
      
      VALID_TYPES = [:boolean, :string, :fixnum, :float]
  
      class InvalidConfigurationOptions < StandardError
        def initialize(who, errors)
          super("Class '#{who}' has invalid types for the following options: #{errors.map{|v,k| "#{v} => #{k}"}.join(', ')}")
        end
      end

      class ConfigurationNotFound < StandardError; end
      
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
          prepare_configuration_options
          validate_configuration_options
        end
      end
      
      module ClassMethods
        attr_accessor :configuration_options
        attr_reader :configuration_cache
        
        def setup_configuration(options={})
          unless Configuration.storage_exists? || ConfigurationOption.storage_exists?
            [Configuration, ConfigurationOption].each { |m| m.auto_migrate! }
          end

          @configuration_cache ||= {}
          
          configuration_options.merge!(options) if options
          prepare_configuration_options
          configuration_options.each do |name, properties|
            conf_properties = { :name => name,
                :type => properties[:type], 
                :default => DataMapper::Types::Option.dump(properties[:default]),
                :model_class => self }
            if configuration = Configuration.first(:name => "#{name}", :model_class => "#{self}")
              configuration.update(conf_properties)
            else
              configuration = Configuration.create(conf_properties)
            end

            @configuration_cache[configuration.name.to_sym] = configuration
          end
        end
        
        def prepare_configuration_options
          configuration_options.each do |name, value|
            options = value.is_a?(Hash) ? value : { :default => value }
            
            if options[:type].nil?
              default_class = options[:default].class.to_s
              options[:type] = default_class == 'NilClass' ?
                :string : default_class =~ /FalseClass|TrueClass/ ?
                  :boolean : default_class.downcase.to_sym
            end

            configuration_options[name] = options
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
          conf, option = fetch_configuration_option(name)
          do_update = value != DataMapper::Types::Option.dump(conf.default)
          if do_update && option.nil?
            params = {:configuration_id => conf.id, :value => value}
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
          conf, option = fetch_configuration_option(name)
          option_value = option ? option.value : conf.default
          case conf.type
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
          conf = fetch_configuration(name)
          unless new?
            option = ConfigurationOption.get(conf.id, id)
          else
            option = self.options.detect { |o| o if o.configuration_id == conf.id }
          end
          [conf, option]
        end

        def fetch_configuration(name)
          conf = self.class.configuration_cache[name.to_sym] || Configuration.first(
            :model_class => "#{self.class}", :name => "#{name}")
          unless conf
            raise ConfigurationNotFound.new("Model #{self.class} has no configuration called '#{name}'")
          end
          conf
        end
        
      end # InstanceMethods
      
      class ConfigurationProxy
        def initialize(configurable)
          @configurable = configurable
        end
        
        def all
          options = {}
          @configurable.class.configuration_options.keys.each{
            |name| options[name] = @configurable.options_get(name) }
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
