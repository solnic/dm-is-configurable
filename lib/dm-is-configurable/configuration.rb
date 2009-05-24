class Configuration
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :type, String
  property :default, DataMapper::Types::Option
  property :model_class, String

  validates_is_unique :name, :scope => [:model_class]
  
  has n, :options, :model => ConfigurationOption
end