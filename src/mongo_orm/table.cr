module Mongo::ORM::Table
  macro included
    macro inherited
      PRIMARY = {name: _id, type: String}
    end
  end

  @@adapter = Mongo::ORM::Adapter.new
  def self.adapter
    @@adapter
  end

  # specify the table name to use otherwise it will use the model's name
  macro table_name(name)
    {% SETTINGS[:table_name] = name.id %}
  end

  macro __process_table
    {% name_space = @type.name.gsub(/::/, "_").downcase.id %}
    {% table_name = SETTINGS[:table_name] || name_space + "s" %}
    {% primary_name = PRIMARY[:name] %}
    {% primary_type = PRIMARY[:type] %}

    # Table Name
    @@table_name = "{{table_name}}"
    @@primary_name = "{{primary_name}}"

    # make accessible to outside classes
    def self.table_name
      @@table_name
    end
    def self.primary_name
      @@primary_name
    end

    # Create the primary key
    property {{primary_name}} : Union({{primary_type.id}} | Nil)
  end
end
