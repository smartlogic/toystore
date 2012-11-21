require 'helper'

describe Toy::Object do
  uses_objects('User')

  subject { User.new }

  it_should_behave_like 'ActiveModel'

  it "adds model naming" do
    model_name = User.model_name
    model_name.should           == 'User'
    model_name.singular.should  == 'user'
    model_name.plural.should    == 'users'
  end

  it "adds to_model" do
    user = User.new
    user.to_model.should == user
  end

  describe "#persisted?" do
    it "returns false" do
      User.new.persisted?.should be_false
    end
  end

  describe "#to_key" do
    it "returns [id] if persisted" do
      user = User.new
      user.stub(:persisted?).and_return(true)
      user.to_key.should == [user.id]
    end

    it "returns nil if not persisted" do
      User.new.to_key.should be_nil
    end

    context "with native uuid" do
      before do
        User.key :native_uuid
      end

      it "returns array with guid if persisted" do
        user = User.new
        user.stub(:persisted?).and_return(true)
        user.to_key.should == [user.id.to_guid]
      end

      it "returns nil if not persisted" do
        User.new.to_key.should be_nil
      end
    end

    context "with composite" do
      before do
        User.key :composite, attributes: {location: String, name: String}
      end

      it "returns array with guid if persisted" do
        user = User.new(location: 'IN', name: 'John')
        user.stub(:persisted?).and_return(true)
        user.to_key.should == ['IN', 'John']
      end

      it "returns nil if not persisted" do
        User.new.to_key.should be_nil
      end
    end

    context "with composite with uuid type" do
      before do
        User.key :composite, attributes: {bucket: String, track_id: SimpleUUID::UUID}
      end

      it "returns array with guid if persisted" do
        id = SimpleUUID::UUID.new
        user = User.new(bucket: '2012', track_id: id)
        user.stub(:persisted?).and_return(true)
        user.to_key.should == ['2012', id.to_guid]
      end

      it "returns nil if not persisted" do
        User.new.to_key.should be_nil
      end
    end
  end

  describe "#to_param" do
    it "returns key joined by - if to_key present" do
      user = User.new
      user.stub(:persisted?).and_return(true)
      user.to_param.should == user.to_key.join('-')
    end

    it "returns nil if to_key nil" do
      User.new.to_param.should be_nil
    end
  end
end
