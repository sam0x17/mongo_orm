class Object
  def from_bson(val)
    nil
  end
end

module Mongo::ORM::Querying
  macro extended
    macro __process_querying
      \{% primary_name = PRIMARY[:name] %}
      \{% primary_type = PRIMARY[:type] %}

      def self.from_bson(bson : BSON)
        model = \{{@type.name.id}}.new
        model._id = bson["_id"].as(BSON::ObjectId) if bson["_id"]?
        fields = {} of String => Bool
        \{% for name, type in SPECIAL_FIELDS %}
          fields["\{{name.id}}"] = true
          model.\{{name.id}} = [] of \{{type.id}}
          if bson.has_key?("\{{name}}")
            bson["\{{name}}"].not_nil!.as(BSON).each do |item|
              loaded = \{{type.id}}.from_bson(item.value)
              model.\{{name.id}} << loaded unless loaded.nil?
            end
          else
            raise "missing bson key: \{{name}}"
          end
        \{% end %}
        \{% for name, type in FIELDS %}
          fields["\{{name.id}}"] = true
          if \{{type.id}}.is_a? Mongo::ORM::EmbeddedDocument.class
            model.\{{name.id}} = \{{type.id}}.from_bson(bson["\{{name}}"])
          else
            model.\{{name.id}} = bson["\{{name}}"].as(Union(\{{type.id}} | Nil))
          end
          \{% if type.id == Time %}
            model.\{{name.id}} = model.\{{name.id}}.not_nil!.to_utc if model.\{{name.id}}
          \{% end %}
        \{% end %}
        \{% if SETTINGS[:timestamps] %}
          model.created_at = bson["created_at"].as(Union(Time | Nil)) if bson["created_at"]?
          model.updated_at = bson["updated_at"].as(Union(Time | Nil)) if bson["updated_at"]?
          model.created_at = model.created_at.not_nil!.to_utc if model.created_at
          model.updated_at = model.updated_at.not_nil!.to_utc if model.updated_at
        \{% end %}
        bson.each_key do |key|
          next if fields.has_key?(key)
          model.set_extended_value(key, bson[key])
        end
        model
      end

      def to_bson
        bson = BSON.new
        bson["_id"] = self._id  if self._id != nil
        \{% for name, type in FIELDS %}
          bson["\{{name}}"] = \{{name.id}}.as(Union(\{{type.id}} | Nil))
        \{% end %}
        \{% for name, type in SPECIAL_FIELDS %}
          \{% arr = "arr_#{name.id}" %}
          \{% appender = "appender_#{name.id}" %}
          \{{arr.id}} : BSON = BSON.new
          \{{appender.id}} : BSON::ArrayAppender = BSON::ArrayAppender.new(\{{arr.id}})
          if self.\{{name.id}} != nil
            self.\{{name}}.each do |item|
              \{{appender.id}} << item.to_bson if item
            end
          end
          bson["\{{name}}"] = \{{arr.id}}
        \{% end %}
        \{% if SETTINGS[:timestamps] %}
          bson["created_at"] = created_at.as(Union(Time | Nil))
          bson["updated_at"] = updated_at.as(Union(Time | Nil))
        \{% end %}
        extended_bson.each_key do |key|
          bson[key] = extended_bson[key] unless bson.has_key?(key)
        end
        bson
      end
    end
  end

  def clear
    begin
      collection.drop
    rescue
    end
  end

  def all(query = BSON.new, skip = 0, limit = 0, batch_size = 0, flags = LibMongoC::QueryFlags::NONE, prefs = nil)
    rows = [] of self
    collection.find(query, BSON.new, flags, skip, limit, batch_size, prefs).each do |doc|
      rows << from_bson(doc) if doc
    end
    rows
  end

  def all_batches(query = BSON.new, batch_size = 100)
    collection.find(query, BSON.new, LibMongoC::QueryFlags::NONE, 0, 0, batch_size, nil).each do |doc|
      yield from_bson(doc)
    end
  end

  def first(query = BSON.new)
    all(query, 0, 1).first?
  end

  def find(value)
    return find_by(@@primary_name.to_s, value)
  end

  # find_by using symbol for field name.
  def find_by(field : Symbol, value)
    field = :_id if field == :id
    find_by(field.to_s, value)  # find_by using symbol for field name.
  end

  # find_by returns the first row found where the field maches the value
  def find_by(field : String, value)
    row = nil
    collection.find({ field => value }, BSON.new, LibMongoC::QueryFlags::NONE, 0, 1) do |doc|
      row = from_bson(doc)
    end
    row
  end

  def create(**args)
    create(args.to_h)
  end

  def create(args : Hash(Symbol | String, DB::Any))
    instance = new
    instance.set_attributes(args)
    instance.save
    instance
  end
end
