class BaseForm
  include ActiveModel::Model
  include Attributes

  def validate!
    super
  rescue => e
    raise AppValidationError.new(e)
  end

  def to_s
    "#{self.class.name}<#{self.attributes.map{|x| "#{x}=#{send(x)}"}.join(', ')}>"
  end
end
