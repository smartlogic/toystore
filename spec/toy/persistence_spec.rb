require 'helper'

describe Toy::Persistence do
  uses_constants('User')

  let(:klass) do
    Class.new { include Toy::Store }
  end

  describe ".adapter" do
    it "sets if arguments and reads if not" do
      User.adapter(:memory, {})
      User.adapter.should == Adapter[:memory].new({})
    end

    it "defaults options to empty hash" do
      Adapter[:memory].should_receive(:new).with({}, {})
      User.adapter(:memory, {})
    end

    it "works with options" do
      Adapter[:memory].should_receive(:new).with({}, :something => true)
      User.adapter(:memory, {}, :something => true)
    end

    it "raises argument error if name provided but not client" do
      lambda do
        klass.adapter(:memory)
      end.should raise_error(ArgumentError, 'Client is required')
    end

    it "defaults to memory adapter if no name or client provided and has not been set" do
      klass.adapter.should_not be_nil
      klass.adapter.client.should eql({})
    end

    it "allows changing adapter even after use of default" do
      hash = {}
      klass.adapter
      klass.adapter :memory, hash
      klass.adapter.client.should equal(hash)
    end
  end

  describe ".create" do
    before do
      User.attribute :name, String
      User.attribute :age, Integer
      @doc = User.create(:name => 'John', :age => 50)
    end
    let(:doc) { @doc }

    it "creates key in database with attributes" do
      User.adapter.read(doc.id).should == {
        'name' => 'John',
        'age'  => 50,
      }
    end

    it "returns instance of model" do
      doc.should be_instance_of(User)
    end
  end

  describe ".delete(*ids)" do
    it "should delete a single record" do
      doc = User.create
      User.delete(doc.id)
      User.key?(doc.id).should be_false
    end

    it "should delete multiple records" do
      doc1 = User.create
      doc2 = User.create

      User.delete(doc1.id, doc2.id)

      User.key?(doc1.id).should be_false
      User.key?(doc2.id).should be_false
    end

    it "should not complain when records do not exist" do
      doc = User.create
      User.delete("taco:bell:tacos")
    end
  end

  describe ".destroy(*ids)" do
    it "should destroy a single record" do
      doc = User.create
      User.destroy(doc.id)
      User.key?(doc.id).should be_false
    end

    it "should destroy multiple records" do
      doc1 = User.create
      doc2 = User.create

      User.destroy(doc1.id, doc2.id)

      User.key?(doc1.id).should be_false
      User.key?(doc2.id).should be_false
    end

    it "should not complain when records do not exist" do
      doc = User.create
      User.destroy("taco:bell:tacos")
    end
  end

  describe "#adapter" do
    it "delegates to class" do
      User.new.adapter.should equal(User.adapter)
    end
  end

  describe "declaring an attribute with an abbreviation" do
    before do
      User.attribute(:twitter_access_token, String, :abbr => 'tat')
    end

    it "persists to adapter using abbreviation" do
      user = User.create(:twitter_access_token => '1234')
      raw = user.adapter.read(user.id)
      raw['tat'].should == '1234'
      raw.should_not have_key('twitter_access_token')
    end

    it "loads from store correctly" do
      user = User.create(:twitter_access_token => '1234')
      user = User.get(user.id)
      user.twitter_access_token.should == '1234'
      user.tat.should == '1234'
    end
  end

  describe "#initialize_from_database" do
    before do
      User.attribute(:age, Integer, :default => 20)
      @user = User.allocate
    end

    it "sets new record to false" do
      @user.initialize_from_database
      @user.should_not be_new_record
    end

    it "sets attributes" do
      @user.initialize_from_database('age' => 21)
    end

    it "sets defaults" do
      @user.initialize_from_database
      @user.age.should == 20
    end

    it "does not fail with nil" do
      @user.initialize_from_database(nil).should == @user
    end

    it "returns self" do
      @user.initialize_from_database.should == @user
    end
  end

  describe "#new_record?" do
    it "returns true if new" do
      User.new.should be_new_record
    end

    it "returns false if not new" do
      User.create.should_not be_new_record
    end
  end

  describe "#persisted?" do
    it "returns true if persisted" do
      User.create.should be_persisted
    end

    it "returns false if not persisted" do
      User.new.should_not be_persisted
    end

    it "returns false if deleted" do
      doc = User.create
      doc.delete
      doc.should_not be_persisted
    end
  end

  describe "#save" do
    before do
      User.attribute :name, String
      User.attribute :age, Integer
      User.attribute :accepted_terms, Boolean, :virtual => true
    end

    context "with new record" do
      before do
        @doc = User.new(:name => 'John', :age => 28, :accepted_terms => true)
      end

      it "saves to key" do
        @doc.save
        User.key?(@doc.id)
      end

      it "does not persist virtual attributes" do
        @doc.save
        @doc.adapter.read(@doc.id).should_not include('accepted_terms')
      end

      it "is persisted" do
        @doc.save
        @doc.persisted?.should be_true
      end

      it "returns true" do
        @doc.save.should be_true
      end

      context "with #persist overridden" do
        before do
          @doc.class_eval do
            def persist
            end
          end
        end

        it "is persisted" do
          @doc.save
          @doc.persisted?.should be_true
        end

        it "returns true" do
          @doc.save.should be_true
        end
      end
    end

    context "with existing record" do
      before do
        @doc      = User.create(:name => 'John', :age => 28)
        @key      = @doc.id
        @value    = User.adapter.read(@doc.id)
        @doc.name = 'Bill'
        @doc.accepted_terms = false
      end
      let(:doc) { @doc }

      it "does not change primary key" do
        @doc.save
        doc.id.should == @key
      end

      it "updates value in adapter" do
        @doc.save
        User.adapter.read(doc.id).should_not == @value
      end

      it "does not persist virtual attributes" do
        @doc.save
        @doc.adapter.read(@doc.id).should_not include('accepted_terms')
      end

      it "updates the attributes in the instance" do
        @doc.save
        doc.name.should == 'Bill'
      end

      it "is persisted" do
        @doc.save
        @doc.persisted?.should be_true
      end

      it "returns true" do
        @doc.save.should be_true
      end

      context "with #persist overridden" do
        before do
          @doc.class_eval do
            def persist
            end
          end
        end

        it "is persisted" do
          @doc.save
          doc.persisted?.should be_true
        end

        it "returns true" do
          @doc.save.should be_true
        end
      end
    end
  end

  describe "#update_attributes" do
    before do
      User.attribute :name, String
    end

    it "should change attribute and save" do
      user = User.create(:name => 'John')
      User.get(user.id).name.should == 'John'

      user.update_attributes(:name => 'Geoffrey')
      User.get(user.id).name.should == 'Geoffrey'
    end
  end

  describe "#delete" do
    it "should remove the instance" do
      doc = User.create
      doc.delete
      User.key?(doc.id).should be_false
    end

    it "uses persisted id for adapter delete" do
      user = User.new
      user.stub(:persisted_id => 1)
      user.adapter.should_receive(:delete).with(1)
      user.delete
    end
  end

  describe "#destroy" do
    it "should remove the instance" do
      doc = User.create
      doc.destroy
      User.key?(doc.id).should be_false
    end
  end

  describe "#destroyed?" do
    it "should be false if not deleted" do
      doc = User.create
      doc.should_not be_destroyed
    end

    it "should be true if deleted" do
      doc = User.create
      doc.delete
      doc.should be_destroyed
    end
  end

  describe "#clone" do
    it "returns instance that is a new_record" do
      User.new.clone.should be_new_record
      User.create.clone.should be_new_record
    end

    it "is never destroyed" do
      user = User.create
      user.clone.should_not be_destroyed
      user.destroy
      user.clone.should_not be_destroyed
    end
  end

  describe "#persisted_id" do
    it "returns id attribute value converted for storage" do
      raw_value = 1
      typecast_for_store_value = '1'
      user = User.new(:id => raw_value)
      user.persisted_id.should eq(typecast_for_store_value)
    end
  end

  describe "#persist" do
    it "calls write on adapter with persisted id and attributes" do
      user = User.new
      user.stub(persisted_id: 1, persisted_attributes: {one: 'two'})
      user.adapter.should_receive(:write).with(1, {one: 'two'})
      user.persist
    end
  end
end
