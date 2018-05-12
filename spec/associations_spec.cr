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
      post.test_admin_id = a._id
    end

    it "handles has_many <=> belongs_to relationships as class" do
      a = TestModule::Admin.new
      a.test_posters.should eq [] of TestPoster
      a.save
      post = TestPoster.new
      post.text = "haha"
      post.test_admin = a
      post.save
      post = TestPoster.all.first.not_nil!
      a = TestModule::Admin.all.first.not_nil!
      post.test_admin.equals?(a).should be_true
      a.test_posters.inspect.should eq [post].inspect
      a.test_posters.first.not_nil!.test_admin.equals?(a).should be_true
      post.test_admin_id = a._id
    end

    it "handles has_many <=> belongs_to relationships as class" do
      a = TestModule::Admin.new
      a.save
      p = TestModule::Permission.new
      p.name = "test"
      p.val = 1
      p.admin = a
      p.save
      
      
      p.admin.equals?(a).should be_true
      a.permissions.size.should eq 1
      a.permissions[0].id.should eq p._id
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
      moduleThing1 = TestModule::Embed.new
      moduleThing1.name = "module thing 1"
      moduleThing2 = TestModule::Embed.new
      moduleThing2.name = "module thing 2"
      admin.test_inner_things_modules.empty?.should be_true
      admin.test_inner_things_modules << moduleThing1
      admin.test_inner_things_modules.first.name.should eq "module thing 1"
      admin.test_inner_things_modules.size.should eq 1
      admin.test_inner_things_modules << moduleThing2
      admin.test_inner_things_modules.size.should eq 2
      admin.test_inner_things_modules.last.name.should eq "module thing 2"
      admin.save!
      before = admin.test_inner_things.to_bson.to_s
      beforeModule = admin.test_inner_things_modules.to_bson.to_s
      admin = TestAdmin.first.not_nil!
      after = admin.test_inner_things.to_bson.to_s
      afterModule = admin.test_inner_things_modules.to_bson.to_s
      after.should eq before
      afterModule.should eq beforeModule
    end

    it "persists single embedded documents" do
      a = TestAdmin.new
      a.first_name = "Sam"
      a.blog = TestBlog.new
      a.blog.not_nil!.name = "test blog"
      a.save!
      a = TestAdmin.first.not_nil!
      a.first_name.should eq "Sam"
      a.blog.not_nil!.name.should eq "test blog"
    end
  end
end
