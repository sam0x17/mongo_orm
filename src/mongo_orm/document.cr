#require "./associations"
require "./callbacks"
require "./fields"
require "./querying"
require "./settings"
require "./collection"
require "./persistence"
require "./error"
require "./validators"
require "./version"
require "./associations"

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

# Mongo::ORM::Document is the base class for your model objects.
class Mongo::ORM::Document
  include Associations
  include Callbacks
  include Fields
  include Settings
  include Collection
  include Persistence
  include Validators

  extend Querying

  @errors = [] of Mongo::ORM::Error

  def errors
    @errors
  end

  macro inherited
    macro finished
      __process_collection
      __process_fields
      __process_querying
      __process_persistence

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
end
