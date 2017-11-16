module Mongo::ORM::Collection
  macro included
    macro inherited
      PRIMARY = {name: _id, type: BSON::ObjectId}
    end
  end

  @@adapter = Mongo::ORM::Adapter.new
  def self.adapter
    @@adapter
  end

  def self.db
    @@adapter.database
  end

  # specify the collection name to use otherwise it will use the model's name
  macro collection_name(name)
    {% SETTINGS[:collection_name] = name.id %}
  end

  macro __process_collection
    {% name_space = @type.name.gsub(/::/, "_").downcase.id %}
    {% collection_name = SETTINGS[:collection_name] || name_space + "s" %}
    {% primary_name = PRIMARY[:name] %}
    {% primary_type = PRIMARY[:type] %}

    # Collection Name
    @@collection_name = "{{collection_name}}"
    @@primary_name = "{{primary_name}}"
    @@collection : Mongo::Collection = Mongo::ORM::Collection.db[@@collection_name]

    # make accessible to outside classes
    def self.collection_name
      @@collection_name
    end
    def self.primary_name
      @@primary_name
    end
    def self.collection
      @@collection
    end

    def self.adapter
      Mongo::ORM::Collection.adapter
    end

    def self.db
      Mongo::ORM::Collection.db
    end

    def _id=(value : String)
      self._id = BSON::ObjectId.new value
    end

    def id
      _id
    end

    def id=(value : String | Nil | BSON::ObjectId)
      self._id = value
    end

    # Create the primary key
    property {{primary_name}} : Union({{primary_type.id}} | Nil)
  end
end
