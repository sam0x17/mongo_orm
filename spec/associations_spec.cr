require "./spec_helper"

describe Mongo::ORM::Document do
  describe "associations" do
    it "handles has_many <=> belongs_to relationships" do
      a = TestAdmin.new
      a.test_posts.should eq [] of TestPost
      a.save
      post = TestPost.new
      post.text = "haha"
      post.test_admin = a
      post.save
      post = TestPost.all.first.not_nil!
      a = TestAdmin.all.first.not_nil!
      post.test_admin.equals?(a).should be_true
      a.test_posts.inspect.should eq [post].inspect
      a.test_posts.first.not_nil!.test_admin.equals?(a).should be_true
    end

    it "handles embeds_many relationships" do
      admin = TestAdmin.new
      thing1 = TestInnerThing.new
      thing1.name = "thing 1"
      thing2 = TestInnerThing.new
      thing2.name = "thing 2"
      thing3 = TestInnerThing.new
      thing3.name = "thing 3"
      admin.test_inner_things.empty?.should be_true
      admin.test_inner_things << thing1
      admin.test_inner_things.first.name.should eq "thing 1"
      admin.test_inner_things.size.should eq 1
      admin.test_inner_things << thing2
      admin.test_inner_things << thing3
      admin.test_inner_things.size.should eq 3
      admin.test_inner_things.last.name.should eq "thing 3"
      admin.save!
      before = admin.test_inner_things.to_bson.to_s
      admin = TestAdmin.first.not_nil!
      after = admin.test_inner_things.to_bson.to_s
      after.should eq before
    end
  end
end
