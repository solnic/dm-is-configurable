require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe Configuration do
  
    before :all do
      Configuration.auto_migrate!
    end
    
    it 'should be created' do
      configuration = Configuration.new(:name => 'CanHasCheezburger')
      configuration.save.should be(true)
    end
    
  end
end