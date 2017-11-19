class BSON
  def []=(key, value : Mongo::ORM::EmbeddedDocument)
    self[key] = value.to_bson
  end
end

module Mongo::ORM::EmbeddedBson
  macro extended
    macro __process_embedded_bson

      def self.from_bson(bson : BSON)
        model = \{{@type.name.id}}.new
        \{% for name, type in FIELDS %}
          if \{{type.id}}.is_a? Mongo::ORM::EmbeddedDocument.class
            model.\{{name.id}} = \{{type.id}}.from_bson(bson["\{{name}}"])
          else
            model.\{{name.id}} = bson["\{{name}}"].as(Union(\{{type.id}} | Nil))
          end
        \{% end %}
        model
      end

      def to_bson
        bson = BSON.new
        \{% for name, type in FIELDS %}
          bson["\{{name}}"] = \{{name.id}}.as(Union(\{{type.id}} | Nil))
        \{% end %}
        bson
      end
    end
  end
end
