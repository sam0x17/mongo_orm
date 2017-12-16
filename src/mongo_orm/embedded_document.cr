require "./embedded_fields"
require "./associations"
require "./embedded_bson"
require "./extended_bson"

class Mongo::ORM::EmbeddedDocument
  include EmbeddedFields
  include Associations
  include ExtendedBSON
  extend EmbeddedBSON

  def equals?(val : Document)
    self.to_h.to_s == val.to_h.to_s
  end

  macro inherited
    macro finished
      __process_embedded_fields
      __process_embedded_bson
      def inspect(io)
        sts = [] of String
        fields.each do |field_name, field_value|
          sts << " #{field_name}: #{field_value.nil? ? "nil" : field_value.inspect}"
        end
        io << "#{self.class} {#{sts.join(",")}}"
      end
    end
  end
end
