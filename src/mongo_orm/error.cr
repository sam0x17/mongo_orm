class Mongo::ORM::Error < Exception
  property field : Symbol
  property raw_message : String

  def initialize(@field, @raw_message)
    if @field == :base
      super(@raw_message)
    else
      super("#{@field.to_s.capitalize} #{@raw_message}")
    end
  end
end
