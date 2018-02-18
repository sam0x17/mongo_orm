require "./spec_helper"

describe Mongo::ORM::Document do
  describe "BSON support" do
    it "does not allow referencing undefined extended bson attributes" do
      a = TestAdmin.new
      a.asdf.should eq nil
      expect_raises(Exception) { a.asdf! }
    end

    it "allows defining new extended bson attributes" do
      a = TestAdmin.new
      a.field_1 = "test_1"
      a.field_2 = "test_2"
      a.field_3 = "test_3"
      a.field_1.should eq "test_1"
      a.field_3.should eq "test_3"
      a.field_2.should eq "test_2"
      a.asdf = nil
      a.asdf.should eq nil
    end

    it "should not allow extended bson support to override standard fields" do
      a = TestAdmin.new
      a.first_name = "Sam"
      a.first_name.should eq "Sam"
      a.extended_bson.has_key?("first_name").should be_false
      a.middle_name = "Livingston"
      a.extended_bson.has_key?("middle_name").should be_true
      a.middle_name.should eq "Livingston"
    end

    it "allows extended bson attributes to change values" do
      a = TestAdmin.new
      a.middle_name = "Alfred"
      a.middle_name.should eq "Alfred"
      a.middle_name = "Winifred"
      a.middle_name.should eq "Winifred"
    end

    it "works with embedded documents" do
      a = TestAdmin.new
      a.blog = TestBlog.new
      b = a.blog.not_nil!
      b.cool_thing = "yeah"
      b.cool_thing.should eq "yeah"
      a.blog.not_nil!.cool_thing.should eq "yeah"
      a.not_nil!.to_bson.to_s.includes?("\"cool_thing\" : \"yeah\"").should be_true
    end

    it "works with standard documents" do
      a = TestAdmin.new
      a.first_name = "Sam"
      a.stellar_thing = "rad"
      a.stellar_thing.should eq "rad"
      a.first_name.should eq "Sam"
      a.to_bson.to_s.includes?("stellar_thing").should be_true
      a.to_bson.to_s.includes?("rad").should be_true
    end

    it "persists with standard documents" do
      a = TestAdmin.new
      a.awesome_thing = "yay"
      a.awesome_thing.should eq "yay"
      a.to_bson.to_s.includes?("yay").should be_true
      a.to_bson.to_s.includes?("awesome_thing").should be_true
      a.save!
      a = TestAdmin.first.not_nil!
      a.awesome_thing.should eq "yay"
      a.to_bson.to_s.includes?("yay").should be_true
      a.to_bson.to_s.includes?("awesome_thing").should be_true
    end

    it "persists with embedded documents" do
      a = TestAdmin.new
      a.blog = TestBlog.new
      a.blog.not_nil!.name = "best blog ever"
      a.blog.not_nil!.name.should eq "best blog ever"
      a.save!
      a = TestAdmin.first.not_nil!
      a.blog.not_nil!.name.should eq "best blog ever"
      a.to_bson.to_s.includes?("best blog ever").should be_true
    end
  end
end
