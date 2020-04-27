# frozen_string_literal: true

RSpec.describe Hanami::OldEntity do
  describe "manual schema (base)" do
    let(:described_class) { Account }

    let(:input) do
      Class.new do
        def to_hash
          Hash[id: 1]
        end
      end.new
    end

    describe "#initialize" do
      it "can be instantiated without attributes" do
        entity = described_class.new

        expect(entity).to be_a_kind_of(described_class)
      end

      it "accepts a hash" do
        entity = described_class.new(id: 1, owner: owner = User.new(name: "MG"), users: users = [User.new], name: "Acme Inc.", codes: [1, 2, 3], email: "account@acme-inc.test", created_at: now = DateTime.now)

        expect(entity.id).to eq(1)
        expect(entity.name).to eq("Acme Inc.")
        expect(entity.owner).to eq(owner)
        expect(entity.users).to eq(users)
        expect(entity.codes).to eq([1, 2, 3])
        expect(entity.email).to eq("account@acme-inc.test")
        expect(entity.created_at).to be_within(1).of(now)
      end

      it "accepts object that implements #to_hash" do
        entity = described_class.new(input)

        expect(entity.id).to eq(1)
      end

      it "freezes the instance" do
        entity = described_class.new

        expect(entity).to be_frozen
      end

      it "coerces values" do
        now = DateTime.now
        entity = described_class.new(created_at: now.to_s)

        expect(entity.created_at).to be_a_kind_of(DateTime)
        expect(entity.created_at).to be_within(1).of(now)
      end

      it "coerces values for array of primitives" do
        entity = described_class.new(codes: %w[4 5 6])

        expect(entity.codes).to eq([4, 5, 6])
      end

      it "coerces values for single object" do
        entity = described_class.new(owner: owner = { name: "L" })

        expect(entity.owner).to be_a_kind_of(User)
        expect(entity.owner.name).to eq(owner.fetch(:name))
      end

      it "coerces values for array of objects" do
        entity = described_class.new(users: users = [{ name: "L" }, { name: "MG" }])

        users.each_with_index do |user, i|
          u = entity.users[i]

          expect(u).to be_a_kind_of(User)
          expect(u.name).to eq(user.fetch(:name))
        end
      end

      it "raises error if initialized with wrong primitive" do
        expect { described_class.new(id: :foo) }.to raise_error(Hanami::Model::Error) do |exception|
          expect(exception.message).to include(":foo (Symbol) has invalid type for :id violates constraints (type?(Integer, :foo) failed)")
        end
      end

      it "raises error if initialized with wrong array primitive" do
        message = Platform.match do
          engine(:jruby) { "no implicit conversion of Object into Integer" }
          default        { "can't convert Object into Integer" }
        end

        expect { described_class.new(codes: [Object.new]) }.to raise_error(Hanami::Model::Error) do |exception|
          expect(exception.message).to match(message)
        end
      end

      it "raises error if type constraint isn't honored" do
        expect { described_class.new(email: "test") }.to raise_error(Hanami::Model::Error) do |exception|
          expect(exception.message).to include('"test" (String) has invalid type for :email violates constraints (format?(/@/, "test") failed)')
        end
      end

      it "doesn't override manual defined schema" do
        expect { Warehouse.new(code: "foo") }.to raise_error(Hanami::Model::Error) do |exception|
          expect(exception.message).to include('"foo" (String) has invalid type for :code violates constraints (format?(/\Awh\-/, "foo") failed)')
        end
      end

      it "symbolizes nested hash keys according to schema" do
        entity = PageVisit.new(
          id: 42,
          start: DateTime.now,
          end: (Time.now + 53).to_datetime,
          visitor: {
            "user_agent" => "w3m/0.5.3", "language" => { "en" => 0.9 }
          },
          page_info: {
            "name" => "landing page",
            scroll_depth: 0.7,
            "meta" => { "version" => "0.8.3", updated_at: 1_492_769_467_000 }
          }
        )

        expect(entity.visitor).to eq(
          user_agent: "w3m/0.5.3", language: { en: 0.9 }
        )
        expect(entity.page_info).to eq(
          PageVisit::PageInfo.new(
            name: "landing page",
            scroll_depth: 0.7,
            meta: { version: "0.8.3", updated_at: 1_492_769_467_000 }
          )
        )
      end
    end

    describe "#id" do
      it "returns the value" do
        entity = described_class.new(id: 1)

        expect(entity.id).to eq(1)
      end

      it "returns nil if not present in attributes" do
        entity = described_class.new

        expect(entity.id).to be_nil
      end
    end

    describe "accessors" do
      it "exposes accessors from schema" do
        entity = described_class.new(name: "Acme Inc.")

        expect(entity.name).to eq("Acme Inc.")
      end

      it "raises error for unknown methods" do
        entity = described_class.new

        expect { entity.foo }
          .to raise_error(NoMethodError, /undefined method `foo'/)
      end

      it "raises error when #attributes is invoked" do
        entity = described_class.new

        expect { entity.attributes }
          .to raise_error(NoMethodError, /private method `attributes' called for #<Account/)
      end
    end

    describe "#to_h" do
      it "serializes attributes into hash" do
        entity = described_class.new(id: 1, name: "Acme Inc.")

        expect(entity.to_h).to eq(Hash[id: 1, name: "Acme Inc."])
      end

      it "must be an instance of ::Hash" do
        entity = described_class.new

        expect(entity.to_h).to be_an_instance_of(::Hash)
      end

      it "ignores unknown attributes" do
        entity = described_class.new(foo: "bar")

        expect(entity.to_h).to eq(Hash[])
      end

      it "prevents information escape" do
        entity = described_class.new(users: users = [User.new(id: 1), User.new(id: 2)])

        entity.to_h[:users].reverse!
        expect(entity.users).to eq(users)
      end

      it "is aliased as #to_hash" do
        entity = described_class.new(name: "Acme Inc.")

        expect(entity.to_hash).to eq(entity.to_h)
      end
    end

    describe "#respond_to?" do
      it "returns ture for id" do
        entity = described_class.new

        expect(entity).to respond_to(:id)
      end

      it "returns true for methods with the same name of attributes defined by schema" do
        entity = described_class.new

        expect(entity).to respond_to(:name)
      end

      it "returns false for methods not in the set of attributes defined by schema" do
        entity = described_class.new(foo: "bar")

        expect(entity).to_not respond_to(:foo)
      end
    end
  end
end
