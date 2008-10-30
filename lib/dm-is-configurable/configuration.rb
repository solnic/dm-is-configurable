class Configuration
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :unique => :model
  property :type, String
  property :default, DataMapper::Types::Option
  property :model_class, String
  
  has n, :options, :class_name => 'ConfigurationOption'
end