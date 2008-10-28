class Configuration
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :unique => :model
  property :model_class, String
  property :type, String
  
  has n, :options, :class_name => 'ConfigurationOption'
end