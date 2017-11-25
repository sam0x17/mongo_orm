require "./spec_helper"

describe Mongo::ORM::Document do
  describe "fields" do
    it "can handle string fields" do
      u = TestUser.new
      u.name.should eq nil
      u.name = "Sam"
      u.name.should eq "Sam"
    end

    it "can handle int32 fields" do
      u = TestUser.new
      u.age.should eq nil
      u.age = 23
      u.age.should eq 23
    end

    it "can handle int64 fields" do
      u = TestUser.new
      u.identifier = 123_i64
      u.identifier.should eq 123_i64
    end

    it "can handle built-in Time fields" do
      u = TestUser.new
      u.save
      u.updated_at.should_not eq nil
      u_new = TestUser.find(u._id).not_nil!
      u.updated_at.to_s.should eq u_new.updated_at.to_s
    end

    it "can handle custom Time fields" do
      u = TestUser.new
      u.deleted_at = Time.now.to_utc
      u.save
      u_new = TestUser.find(u._id).not_nil!
      u.deleted_at.to_s.should eq u_new.deleted_at.to_s
    end

    it "should force time fields into UTC" do
      u = TestUser.new
      u.deleted_at = Time.now
      u.save
      u_new = TestUser.find(u._id).not_nil!
      u.deleted_at.to_s.should_not eq u_new.deleted_at.to_s
      u.deleted_at.not_nil!.to_utc.to_s.should eq u_new.deleted_at.to_s
    end

    it "can handle Bool fields" do
      u = TestUser.new
      u.stupid.should eq nil
      u.stupid = false
      u.stupid.should eq false
      u.stupid = true
      u.stupid.should eq true
    end
  end
end
