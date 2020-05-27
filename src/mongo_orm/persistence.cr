module Mongo::ORM::Persistence
  macro __process_persistence

    @updated_at : Time | Nil
    @created_at : Time | Nil

    # The save method will check to see if the primary exists yet. If it does it
    # will call the update method, otherwise it will call the create method.
    # This will update the timestamps apropriately.
    def save
      begin
        __run_before_save
        if _id
          __run_before_update
          @updated_at = Time.utc
          @@collection.save(self)
          __run_after_update
        else
          __run_before_create
          @created_at = Time.utc
          @updated_at = Time.utc
          self._id = BSON::ObjectId.new
          @@collection.save(self)
          __run_after_create
        end
        __run_after_save
        return true
      rescue ex
        if message = ex.message
          puts "Save Exception:"
          puts "  Message: '#{message}'"
          puts "  Object: #{self.inspect}"
          @errors << Mongo::ORM::Error.new(:base, message)
        end
        return false
      end
    end

    def save!
      return if save
      raise @errors.last
    end

    def destroy!
      return if destroy
      raise @errors.last
    end

    # Destroy will remove this from the database.
    def destroy
      raise "cannot destroy an unsaved document!" unless self._id
      begin
        __run_before_destroy
        @@collection.remove({"_id" => self._id})
        __run_after_destroy
        return true
      rescue ex
        if message = ex.message
          puts "Destroy Exception: #{message}"
          errors << Mongo::ORM::Error.new(:base, message)
        end
        return false
      end
    end
  end
end
