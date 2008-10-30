require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  
  describe 'DataMapper::Is::Configurable' do
    
    before :all do
      [Configuration, ConfigurationOption].each { |m| m.auto_migrate! }
      
      class Item
        include DataMapper::Resource
        property :id, Serial
        is :configurable, :with => {
          :one   => { :default => 'something' }, 
          :two   => { :default => true }, 
          :three => { :default => false }
        }
        auto_migrate!
        setup_configuration
      end
      
      class ItemTwo
        include DataMapper::Resource
        property :id, Serial
        is :configurable, :with => {
          :one => { :default => nil }, 
          :two => { :default => false },
          :two => { :default => false }
        }
        auto_migrate!
        setup_configuration
      end
      
      @item = Item.create
      @item_two = ItemTwo.create
    end
    
    after :each do
      @item.options.destroy!
      @item_two.options.destroy!
    end
    
    it 'should set a default type' do
      Item.configuration_options[:one][:type].should eql(:string)
      Item.configuration_options[:two][:type].should eql(:boolean)
    end
    
    it 'should provide a way to add dynamically a new set of options' do
      Item.setup_configuration({
        :four => { :type => :integer, :default => 100 }
      })
      item = Item.new
      item.configuration[:four].should eql(100)
      item.configuration[:four] = 10
      item.configuration[:four].should eql(10)
    end
    
    describe 'Default values' do
      
      it 'should return default values' do
        @item.configuration[:one].should eql('something')
        @item.configuration[:two].should be(true)
        @item.configuration[:three].should be(false)
      end
      
      it 'should restore a default value' do
        count = ConfigurationOption.all.size
        @item.configuration[:one] = 'anything'
        @item.configuration[:one] = 'something'
        @item.configuration[:one].should eql('something')
        ConfigurationOption.all.size.should eql(count)
      end
      
    end
    
    describe 'Setting custom values' do
    
      it 'should create an option for the resource with FalseClass as the value' do
        @item.configuration[:two] = false
        @item.configuration[:two].should be(false)
      end

      it 'should create an option for the resource with 1 as the value' do
        @item.configuration[:two] = 1
        @item.configuration[:two].should be(true)
      end

      it 'should create an option for the resource with 0 as the value' do
        @item.configuration[:two] = 0
        @item.configuration[:two].should be(false)
      end

      it 'should create an option for the resource with String as the value' do
        @item.configuration[:one] = 'oh hai'
        @item.configuration[:one].should eql('oh hai')
      end

      it 'should update an existing option' do
        @item.configuration[:two] = true
        @item.configuration[:two] = false
        @item.configuration[:two].should be(false)
      end
      
      it 'should update all options using a bulk update' do
        new_options = {
          :one   => 'anything',
          :two   => false,
          :three => true
        }
        @item.configuration = new_options
        (@item.configuration.all == new_options).should be(true)
      end
    
    end
    
    describe 'Getting custom values' do
    
      it 'should return all options' do
        @item.configuration[:one]   = '1'
        @item.configuration[:two]   = '0'
        @item.configuration[:three] = '1'

        all = @item.configuration.all
        all[:two]  = '1'
        all[:two]  = false
        all[:four] = true
      end

      it 'should return a boolean value using method_missing' do
        @item.configuration[:two] = true
        @item.configuration.two?.should be(true)
      end
      
    end
    
    describe 'Scoped configuration options' do
      
      before :all do
        @item.configuration[:one] = 'item'
        @item_two.configuration[:one] = 'item two'
      end
      
      it 'should return different values for different model classes' do
        @item.configuration[:one].should eql('item')
        @item_two.configuration[:one].should eql('item two')
      end
      
    end
    
  end
  
end
