require 'test_helper'

describe Hanami::Entity do
  describe 'manual schema' do
    let(:described_class) { Account }

    let(:input) do
      Class.new do
        def to_hash
          Hash[id: 1]
        end
      end.new
    end

    describe '#initialize' do
      it 'can be instantiated without attributes' do
        entity = described_class.new

        entity.must_be_kind_of(described_class)
      end

      it 'accepts a hash' do
        entity = described_class.new(id: 1, users: users = [User.new], name: 'Acme Inc.', codes: [1, 2, 3], email: 'account@acme-inc.test', created_at: now = DateTime.now)

        entity.id.must_equal    1
        entity.name.must_equal  'Acme Inc.'
        entity.users.must_equal users
        entity.codes.must_equal [1, 2, 3]
        entity.email.must_equal 'account@acme-inc.test'
        entity.created_at.must_be_close_to(now)
      end

      it 'accepts object that implements #to_hash' do
        entity = described_class.new(input)

        entity.id.must_equal 1
      end

      it 'freezes the intance' do
        entity = described_class.new

        entity.must_be :frozen?
      end

      it 'coerces values' do
        now    = DateTime.now
        entity = described_class.new(created_at: now.to_s)

        entity.created_at.must_be_kind_of(DateTime)
        entity.created_at.must_be_close_to(now)
      end

      it 'coerces values for array of primitives' do
        entity = described_class.new(codes: %w(4 5 6))

        entity.codes.must_equal [4, 5, 6]
      end

      it 'coerces values for array of objects' do
        entity = described_class.new(users: users = [{ name: 'L' }, { name: 'MG' }])

        users.each_with_index do |user, i|
          u = entity.users[i]

          u.must_be_kind_of(User)
          u.name.must_equal user.fetch(:name)
        end
      end

      it 'raises error if initialized with wrong primitive' do
        exception = lambda do
          described_class.new(id: :foo)
        end.must_raise(TypeError)

        exception.message.must_equal(':foo (Symbol) has invalid type for :id')
      end

      it 'raises error if initialized with wrong array primitive' do
        exception = lambda do
          described_class.new(codes: [Object.new])
        end.must_raise(TypeError)

        message = Platform.match do
          engine(:jruby) { "no implicit conversion of Object into Integer" }
          default        { "can't convert Object into Integer" }
        end

        exception.message.must_equal(message)
      end

      it "raises error if type constraint isn't honored" do
        exception = lambda do
          described_class.new(email: 'test')
        end.must_raise(TypeError)

        exception.message.must_equal '"test" (String) has invalid type for :email'
      end

      it "doesn't override manual defined schema" do
        exception = lambda do
          Warehouse.new(code: 'foo')
        end.must_raise(TypeError)

        exception.message.must_equal '"foo" (String) has invalid type for :code'
      end

      it 'symbolizes nested hash keys according to schema' do
        entity = PageVisit.new(
          id: 42,
          start: DateTime.now,
          end: (Time.now + 53).to_datetime,
          visitor: {
            'user_agent' => 'w3m/0.5.3', 'language' => { 'en' => 0.9 }
          },
          page_info: {
            'name' => 'landing page',
            scroll_depth: 0.7,
            'meta' => { 'version' => '0.8.3', updated_at: 1_492_769_467_000 }
          }
        )

        entity.visitor.must_equal(
          'user_agent' => 'w3m/0.5.3', 'language' => { 'en' => 0.9 }
        )
        entity.page_info.must_equal(
          name: 'landing page',
          scroll_depth: 0.7,
          meta: { 'version' => '0.8.3', updated_at: 1_492_769_467_000 }
        )
      end
    end

    describe '#id' do
      it 'returns the value' do
        entity = described_class.new(id: 1)

        entity.id.must_equal 1
      end

      it 'returns nil if not present in attributes' do
        entity = described_class.new

        entity.id.must_equal nil
      end
    end

    describe 'accessors' do
      it 'exposes accessors from schema' do
        entity = described_class.new(name: 'Acme Inc.')

        entity.name.must_equal 'Acme Inc.'
      end

      it 'raises error for unknown methods' do
        entity = described_class.new

        exception = lambda do
          entity.foo
        end.must_raise(NoMethodError)

        exception.message.must_include "undefined method `foo'"
      end

      it 'raises error when #attributes is invoked' do
        entity = described_class.new

        exception = lambda do
          entity.attributes
        end.must_raise(NoMethodError)

        exception.message.must_include "private method `attributes' called for #<Account"
      end
    end

    describe '#to_h' do
      it 'serializes attributes into hash' do
        entity = described_class.new(id: 1, name: 'Acme Inc.')

        entity.to_h.must_equal Hash[id: 1, name: 'Acme Inc.']
      end

      it 'must be an instance of ::Hash' do
        entity = described_class.new

        entity.to_h.must_be_instance_of(::Hash)
      end

      it 'ignores unknown attributes' do
        entity = described_class.new(foo: 'bar')

        entity.to_h.must_equal Hash[]
      end

      it 'prevents information escape' do
        entity = described_class.new(users: users = [User.new(id: 1), User.new(id: 2)])

        entity.to_h[:users].reverse!
        entity.users.must_equal(users)
      end

      it 'is aliased as #to_hash' do
        entity = described_class.new(name: 'Acme Inc.')

        entity.to_hash.must_equal entity.to_h
      end
    end

    describe '#respond_to?' do
      it 'returns ture for id' do
        entity = described_class.new

        entity.must_respond_to(:id)
      end

      it 'returns true for methods with the same name of attributes defined by schema' do
        entity = described_class.new

        entity.must_respond_to(:name)
      end

      it 'returns false for methods not in the set of attributes defined by schema' do
        entity = described_class.new(foo: 'bar')

        entity.wont_respond_to(:foo)
      end
    end
  end
end
