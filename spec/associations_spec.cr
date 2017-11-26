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
  end
end
