require "../src/mongo_orm"
require "spec"

class TestUser < Mongo::ORM::Document
  field name : String
  field age : Int32
  field identifier : Int64
  field deleted_at : Time
  field stupid : Bool
  timestamps
end

class TestBlog < Mongo::ORM::EmbeddedDocument
  field name : String
  field description : String
  embeds thing : TestInnerThing
end

class TestInnerThing < Mongo::ORM::EmbeddedDocument
  field name : String
end

class TestAdmin < Mongo::ORM::Document
  field first_name : String
  field last_name : String
  field age : Int32
  embeds blog : TestBlog
  timestamps
end

Spec.before_each do
  TestUser.drop
  TestAdmin.drop
end

Spec.after_each do
  TestUser.drop
  TestAdmin.drop
end
