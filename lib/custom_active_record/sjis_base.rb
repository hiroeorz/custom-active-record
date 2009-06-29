# -*- coding: utf-8 -*-

module ActiveRecord
  module AttributeMethods #:nodoc:
    module ClassMethods
      private
        def define_write_method(attr_name)
          evaluate_attribute_method attr_name, "def #{attr_name}=(new_value);write_attribute('#{attr_name}', new_value.to_mssql_encode);end", "#{attr_name}="
        end

        def define_read_method(symbol, attr_name, column)
          cast_code = column.type_cast_code('v') if column
          access_code = cast_code ? "(v=@attributes['#{attr_name}']) && #{cast_code}" : "@attributes['#{attr_name}'].to_display_encode"

          unless attr_name.to_s == self.primary_key.to_s
            access_code = access_code.insert(0, "missing_attribute('#{attr_name}', caller) unless @attributes.has_key?('#{attr_name}'); ")
          end
          
          if cache_attribute?(attr_name)
            access_code = "@attributes_cache['#{attr_name}'] ||= (#{access_code})"
          end

          evaluate_attribute_method attr_name, "def #{symbol}; #{access_code}; end"
        end
    end
  end

  class SJISBase < ActiveRecord::Base

    # ClassName.exist?  search all record if exist return true
    # ClassName.exist?(:name => "hanako") search hanako in field name
    # ClassName.exist?(:name => "hanako", :age => 18)

    @@picture_dir = nil

    def self.set_picture_dir(value)
      @@picture_dir = value
    end

    def self.exist?(conditions = nil)
      if conditions.nil?
        return !self.find(:first).nil?
      end

      if conditions.is_a?(String) or conditions.is_a?(Array)
        return !self.find(:first, :conditions => conditions).nil?
      end

      if conditions.is_a?(Hash)
        where = ""
        where_array = []
        first = true

        conditions.each do |column_name, value|
          where << " and " unless first

          if value.is_a?(Array)
            q_array = []

            value.each do |v1|
              q_array.push("?")
            end

            where << " [#{column_name}] in (#{q_array.join(',')})"
            where_array += value
          else
            where << " [#{column_name}] in (?) "
            where_array.push(value)
          end

          first = false
        end

        !self.find(:first, :conditions => [where].concat(where_array)).nil?
      end
    end

    def self.delete(id)
      delete_all([ "#{connection.quote_column_name(primary_key)} IN (?)", id ],
                 :sjis)
    end

    def self.set_table_name(value = nil, &block)
      super(value.to_mssql_encode, &block)
    end

    def self.set_primary_key(value = nil, &block)
      define_attr_method :primary_key, value.to_mssql_encode, &block
    end

    def self.find(*args)
      super(*(args.to_mssql_encode))
    end

    def attributes=(new_attributes, guard_protected_attributes = true)
      return if new_attributes.nil?

      new_attributes.to_mssql_encode.each do |k, v|
        write_attribute(k, v)
      end
    end

    def self.destroy_all(conditions)
      super(conditions.to_mssql_encode)
    end

    def self.delete_all(conditions, encode = :utf8)
      if encode == :utf8
        super(conditions.to_mssql_encode)
      else
        super(conditions)
      end
    end

    def self.update_all(conditions)
      super(conditions.to_mssql_encode)
    end

    def self.calculate(operation, column_name, options = {})
      super(operation, column_name, options.to_mssql_encode)
    end 

    def [](attr_name)
      super(attr_name.to_mssql_encode).to_display_encode
    end

    def []=(attr_name, value)
      super(attr_name.to_mssql_encode, value.to_mssql_encode)
    end

    private

    def str2time(field_name)
      if self[field_name].to_s =~ /\d{8}/
        year = self[field_name][0, 4].to_i
        month = self[field_name][4, 2].to_i
        day = self[field_name][6, 2].to_i
        
        return Time.mktime(year, month, day)    
      end

      return NILTIME.new 
    end
    
    def time2str(time)
      return (" " * 8) if time.nil? or time == ""
      
      return time.year.to_s + 
        format("%02d", time.month) + 
        format("%02d", time.day)
    end
  end
end

class Object
  def to_mssql_encode
    return self
  end

  def to_display_encode
    return self
  end
end

class Array
  def to_mssql_encode
    return self.collect { |a|
      a.to_mssql_encode
    }    
  end

  def to_display_encode
    return self.collect { |a|
      a.to_display_encode
    }    
  end
end

class Hash
  def to_mssql_encode
    new_hash = {}

    self.each do |key, value|
      new_hash[key.to_mssql_encode] = value.to_mssql_encode
    end

    return new_hash
  end

  def to_display_encode
    new_hash = {}

    self.each do |key, value|
      new_hash[key.to_display_encode] = value.to_display_encode
    end

    return new_hash
  end
end

class String
  def to_mssql_encode
    NKF.nkf("-Wsx --cp932", self)
  end

  def to_display_encode
    NKF.nkf("-Swx --cp932", self).strip
  end
end

class NILTIME
  NILTIME_STRING = "-"

  def initialize(*args)
  end

  def year
    return NILTIME_STRING * 4
  end

  def month
    return NILTIME_STRING * 2
  end

  def day
    return NILTIME_STRING * 2
  end
    
  def hour
    return NILTIME_STRING * 2
  end

  def min
    return NILTIME_STRING * 2
  end

  def sec
    return NILTIME_STRING * 2
  end

  def strftime(*args)
    nil
  end
end

