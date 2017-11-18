require "./embedded_fields"
require "./associations"
class Mongo::ORM::EmbeddedDocument
  include EmbeddedFields
  include Associations

  macro inherited
    macro finished
      __process_embedded_fields

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
