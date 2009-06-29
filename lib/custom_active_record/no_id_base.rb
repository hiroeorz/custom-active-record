# -*- coding: utf-8 -*-

require "custom_active_record/sjis_base"

module ActiveRecord
  class NOIDBase < ActiveRecord::SJISBase

    def id
      read_attribute(self.class.primary_key)
    end
    
    def id=(value)
      write_attribute(self.class.primary_key, value.to_mssql_encode)
    end

    def initialize(attr = nil)
      attr_sjis = attr.to_mssql_encode

      super(attr)
      
      unless attr.nil?
        write_attribute(self.class.primary_key,
                        attr_sjis[self.class.primary_key])
      end

      count = self.class.count(:conditions => 
                               ["[#{self.class.primary_key.to_display_encode}] = ? ",
                                attr_sjis[self.class.primary_key]])
      @new_record = count.zero?
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
end

class Hash
  def to_mssql_encode
    new_hash = {}

    self.each do |key, value|
      new_hash[key.to_mssql_encode] = value.to_mssql_encode
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
