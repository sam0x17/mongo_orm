module Mongo::ORM::ExtendedBSON
  macro included
    macro inherited
      @_extended_bson = BSON.new
    end
  end

  macro method_missing(call)
    method_name = {{call.name.id.stringify}}
    explicit_mode = false
    if method_name.ends_with? "!"
      method_name = method_name.chomp("!")
      explicit_mode = true
    end
    method_name_trimmed = method_name[0..(method_name.size - 2)] if method_name.ends_with?("=")
    if method_name_trimmed && {{call.args.size}} == 1
      if @_extended_bson.has_key?(method_name_trimmed)
        set_extended_value(method_name_trimmed, {{call.args.first}})
      else
        @_extended_bson[method_name_trimmed] = {{call.args.first}}
      end
      return @_extended_bson[method_name_trimmed]
    elsif {{call.args.size}} == 0 && @_extended_bson.has_key?(method_name)
      return @_extended_bson[method_name]
    end
    raise "undefined method #{method_name} for #{self.class.name}" if explicit_mode
    nil
  end

  # a BSON object containing attributes on this document not
  # included in the model schema
  def extended_bson
    @_extended_bson
  end

  def set_extended_value(key, value)
    bson = BSON.new
    @_extended_bson.each_pair do |_key, _value|
      next if _key == key
      bson[_key] = value
    end
    bson[key] = value
    @_extended_bson = bson
  end
end
