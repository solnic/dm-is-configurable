require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe ConfigurationOption do
  
    before :all do
      ConfigurationOption.auto_migrate!
    end
    
    it 'should be created' do
      configuration_option = ConfigurationOption.new(:configuration_id => 1, :configurable_id => 1, :value => true)
      configuration_option.save.should be(true)
    end
    
  end
end