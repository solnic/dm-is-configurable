module DataMapper
  module Types
    
    class Option < DataMapper::Type
      primitive String
      size 128
      
      def self.dump(value, property = nil)
        return nil if value.nil?
        if value == 'false'
          '0'
        elsif value == 'true'
          '1'
        else
          value.to_s
        end
      end
    end
    
  end
end