module ActiveRecord
  class PluralsPKeysBase < ActiveRecord::Base

    @@primary_key_list = {}


    def self.set_primary_key_list(*keys)
      @@primary_key_list[self] = keys
    end

    def self.find_from_ids(ids, options)
      if ids.kind_of?(Array) and ids.length == 1
        ids = ids[0]
      end

      expects_array = ids.first.kind_of?(Array)
      
      unless expects_array
        ids = [ids]
      end
      
      where = ""
      
      ids.each_with_index do |id_element, id_i|
        if id_i.zero?
          where << "(" 
        else
          where << ") or ("
        end
        
        primary_key_list.each_with_index do |key, i|
          value = id_element[i]
          
          where << " and " unless i.zero?
          where << "#{key} = #{quote_value(value)}"
          
        end
      end
      
      where << ")"
      
      find_mode = expects_array ? :all : :first
      
      self.find(find_mode, :conditions => where,
                :order => primary_key_list.join(","))    
    end
    
    def destroy
      raise "not supported method"
    end

    private

    def self.primary_key_list
      return @@primary_key_list[self]
    end

    def primary_key_list
      return @@primary_key_list[self.class]
    end

    def update
      where = ""
      first = true

      primary_key_list.each do |key|
        value = read_attribute(key)

        where << " and " unless first
        where << "#{key} = #{quote_value(value)}"
        first = false
      end

      connection.update(
        "UPDATE #{self.class.table_name} " +
        "SET #{quoted_comma_pair_list(connection, 
                                      attributes_with_quotes(false))} " +
                        "WHERE #{where}",
        "#{self.class.name} Update")
    end
  end
end
