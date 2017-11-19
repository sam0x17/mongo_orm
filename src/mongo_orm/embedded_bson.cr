class BSON
  def []=(key, value : Mongo::ORM::EmbeddedDocument)
    self[key] = value.to_bson
  end
end

module Mongo::ORM::EmbeddedBson
  macro extended
    macro __process_embedded_bson

      def self.from_bson(bson)
        model = \{{@type.name.id}}.new
        \{% for name, type in FIELDS %}
          model.\{{name.id}} = bson["\{{name}}"].as(Union(\{{type.id}} | Nil))
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
