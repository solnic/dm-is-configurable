module DataMapper
  module Types
    
    class Option < DataMapper::Type
      primitive String
      size 128
      
      def self.dump(value, property = nil)
        return nil if value.nil?
        value = value.to_s
        if value == 'false'
          '0'
        elsif value == 'true'
          '1'
        else
          value
        end
      end
    end
    
  end
end