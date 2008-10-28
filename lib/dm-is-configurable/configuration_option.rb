class ConfigurationOption
  include DataMapper::Resource
  
  property :configuration_id,  Integer, :key => true
  property :configurable_id,   Integer, :key => true
  property :value,             DataMapper::Types::Option, :nullable => false
  
  belongs_to :configuration
  
  def name
    self.configuration.name
  end
end