class BSON
  def []=(key, value : Mongo::ORM::EmbeddedDocument)
    self[key] = value.to_bson
  end
end

module Mongo::ORM::EmbeddedBSON
  macro extended
    macro __process_embedded_bson

      def self.from_bson(bson : BSON)
        model = \{{@type.name.id}}.new
        fields = {} of String => Bool
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
        bson.each_key do |key|
          next if fields.has_key?(key)
          model.set_extended_value(key, bson[key])
        end
        model
      end

      def to_bson
        bson = BSON.new
        \{% for name, type in FIELDS %}
          bson["\{{name}}"] = \{{name.id}}.as(Union(\{{type.id}} | Nil))
        \{% end %}
        extended_bson.each_key do |key|
          bson[key] = extended_bson[key] unless bson.has_key?(key)
        end
        bson
      end
    end
  end
end
