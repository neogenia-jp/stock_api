module Attributes
  extend ActiveSupport::Concern

  def initialize(params = {})
    super(attributes.map {|e| [e, params[e]] }.to_h) if params
  end

  def attributes
    self.class.attributes
  end

  def to_h
    {}.tap{ |h| attributes.map{ |attr| h[attr] = send(attr) } }
  end

  module ClassMethods
    def inherited(subclass)
      subclass.attributes = attributes.dup
    end

    def attributes
      @attributes || []
    end

    def attributes=(attrs)
      @attributes = attrs
    end

    def define_attributes(*attrs)
      attrs.each do |attr|
        attr_accessor attr
      end
      self.attributes += attrs.dup
    end
  end
end

