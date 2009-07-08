# -*- coding: utf-8 -*-

class FlexibleNameBase < ActiveRecord::Base

  def self.find(*args)

  end

  def create
    raise "not supported update query"
  end

  def update
    raise "not supported update query"
  end

  def save
    raise "not supported update query"
  end

end
