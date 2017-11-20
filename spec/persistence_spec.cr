require "./spec_helper"

describe Mongo::ORM::Document do
  describe "persistance" do
    it "can do basic saving" do
      u = TestUser.new
      u._id.should eq nil
      u.save
      u._id.should_not eq nil
    end

    it "can be found once it has been saved" do
      u = TestUser.new
      u.name = "Sam"
      u.age = 26
      u.identifier = 2847284_i64
      u.stupid = true
      u.updated_at.should eq nil
      u.save
      u.updated_at.should_not eq nil
      u.name.should eq "Sam"
      u2 = TestUser.find(u._id)
      u2.should_not eq nil
      u2.not_nil!.equals?(u).should be_true
    end
  end
end
