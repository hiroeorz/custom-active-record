# -*- coding: utf-8 -*-

require "custom_active_record/sjis_base"

module ActiveRecord
  class PluralsPKeysSJISBase < ActiveRecord::SJISBase

    @@primary_key_list = {}

    def self.set_primary_key_list(*keys)
      @@primary_key_list[self] = keys.to_mssql_encode
    end

    def destroy
      unless new_record?
        where = ""
        first = true
        
        primary_key_list.each do |key|
          value = read_attribute(key)
          
          where << " and " unless first
          where << " [#{key}] = #{quote_value(value)}"
          first = false
        end

        connection.delete <<-end_sql, "#{self.class.name} Destroy"
            DELETE FROM #{self.class.table_name}
            WHERE #{where}
          end_sql
      end
      
      freeze
    end

    private

    def primary_key_list
      return @@primary_key_list[self.class]
    end

    def update
      where = ""
      first = true

      primary_key_list.each do |key|
        value = read_attribute(key)

        where << " and " unless first
        where << "[#{key}] = #{quote_value(value)}"
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
