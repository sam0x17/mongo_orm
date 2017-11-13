module Granite::ORM::Associations
  # define getter and setter for parent relationship
  macro belongs_to(model_name)
    field {{model_name.id}}_id : Int64

    # retrieve the parent relationship
    def {{model_name.id}}
      if parent = {{model_name.id.camelcase}}.find {{model_name.id}}_id
        parent
      else
        {{model_name.id.camelcase}}.new
      end
    end

    # set the parent relationship
    def {{model_name.id}}=(parent)
      @{{model_name.id}}_id = parent.id
    end
  end

  macro has_many(children_collection)
    def {{children_collection.id}}
      {% children_class = children_collection.id[0...-1].camelcase %}
      {% name_space = @type.name.gsub(/::/, "_").downcase.id %}
      {% collection_name = SETTINGS[:collection_name] || name_space + "s" %}
      return [] of {{children_class}} unless id
      foreign_key = "{{children_collection.id}}.{{collection_name[0...-1]}}_id"
      query = "WHERE #{foreign_key} = ?"
      {{children_class}}.all(query, id)
    end
  end

  # define getter for related children
  macro has_many(children_collection, through)
    def {{children_collection.id}}
      {% children_class = children_collection.id[0...-1].camelcase %}
      {% name_space = @type.name.gsub(/::/, "_").downcase.id %}
      {% collection_name = SETTINGS[:collection_name] || name_space + "s" %}
      return [] of {{children_class}} unless id
      query = "JOIN {{through.id}} ON {{through.id}}.{{children_collection.id[0...-1]}}_id = {{children_collection.id}}.id "
      query = query + "WHERE {{through.id}}.{{collection_name[0...-1]}}_id = ?"
      {{children_class}}.all(query, id)
    end
  end
end
