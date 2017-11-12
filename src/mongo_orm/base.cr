#require "./associations"
#require "./callbacks"
#require "./fields"
#require "./querying"
require "./settings"
#require "./table"
#require "./transactions"
#require "./validators"
require "./version"

module DB # needed for fields support
  TYPES = [Nil, String, Bool, Int32, Int64, Float32, Float64, Time, Bytes]
  {% begin %}
    alias Any = Union({{*TYPES}})
  {% end %}
end

# Mongo::ORM::Base is the base class for your model objects.
class Mongo::ORM::Base
  #include Associations
  #include Callbacks
  #include Fields
  include Settings
  #include Table
  #include Transactions
  #include Validators

  #extend Querying

  macro inherited
    macro finished
      #__process_table
      #__process_fields
      #__process_querying
      #__process_transactions
    end
  end

  def initialize(**args : Object)
    set_attributes(args.to_h)
  end

  def initialize(args : Hash(Symbol | String, String | JSON::Type))
    set_attributes(args)
  end

  def initialize
  end
end
