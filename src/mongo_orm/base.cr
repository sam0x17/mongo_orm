#require "./associations"
require "./callbacks"
require "./fields"
require "./querying"
require "./settings"
require "./collection"
#require "./transactions"
#require "./validators"
require "./version"

struct BSON::ObjectId # ObjectId.inspect should just display id
  def inspect(io)
    io << to_s
  end
end

module DB # needed for fields support
  TYPES = [Nil, String, Bool, Int32, Int64, Float32, Float64, Time, Bytes, BSON::ObjectId]
  {% begin %}
    alias Any = Union({{*TYPES}})
  {% end %}
end

# Mongo::ORM::Base is the base class for your model objects.
class Mongo::ORM::Base
  #include Associations
  include Callbacks
  include Fields
  include Settings
  include Collection
  #include Transactions
  #include Validators

  extend Querying

  macro inherited
    macro finished
      __process_collection
      __process_fields
      __process_querying
      #__process_transactions

      def inspect(io)
        sts = [] of String
        sts << "_id: #{"'#{_id}'" || "nil"}"
        fields.each do |field_name, field_value|
          next if field_name == "_id"
          if field_value.is_a?(Number)
            sts << " #{field_name}: #{field_value}"
          else
            sts << " #{field_name}: #{"'#{field_value}'" || "nil"}"
          end
        end
        io << "#{self.class} {#{sts.join(",")}}"
      end
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

  def self.adapter
    Mongo::ORM::Collection.adapter
  end

  def self.db
    Mongo::ORM::Collection.db
  end
end
