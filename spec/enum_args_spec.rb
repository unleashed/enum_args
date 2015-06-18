require 'spec_helper'

RSpec.describe EnumArgs do
  it 'has a version number' do
    expect(EnumArgs::VERSION).not_to be nil
  end

  context 'when including EnumArgs' do
    subject { Helpers::IncludeEnumArgs.new }
    let(:accessor_method) { subject.class.send(:enum_args_accessor_method) }
    let(:enum_args) { subject.send(accessor_method) }

    it { is_expected.to be_a(Enumerable) }
    it { is_expected.to be_a(EnumArgs::ProxiedEnumerable) }
    it { is_expected.to respond_to(subject.class.enum_args_accessor_method) }

    it_behaves_like 'an enumerable', Helpers::IncludeEnumArgs.enum_args_accessor_method
    it_behaves_like 'an enumerator', Helpers::IncludeEnumArgs.enum_args_accessor_method

    it_expects_to 'raise on invocation errors'

    context 'when changing the default dynamic parameters' do
      let(:new_params) { { config: 'different', resumeinfo: 'none' } }

      before do
        enum_args.args = rand.to_s
        enum_args.using = new_params
      end

      it 'receives the changed default parameters' do
        args = Array(enum_args.args).dup
        args << new_params

        expect(subject).to receive(enum_args.method_name).with(*args)

        subject.each.next rescue StopIteration
      end
    end

    context 'at instance level' do
      it 'has an instance variable with non-nil value' do
        expect(subject.instance_variable_get("@#{accessor_method}")).not_to be_nil
      end

      it 'has an instance variable that is an EnumArgs::Proxy' do
        expect(subject.instance_variable_get("@#{accessor_method}")).to be_a(EnumArgs::Proxy)
      end

      it 'responds to the specified instance method' do
        expect(subject).to respond_to(accessor_method)
      end

      it 'has an instance method that is an EnumArgs::Proxy' do
        expect(subject.send(accessor_method)).to be_a(EnumArgs::Proxy)
      end
    end

    context 'at class level' do
      it 'has all provided class methods starting with enum_args_' do
        expect(subject.class.methods.select do |m|
          m.to_s.start_with? 'enum_args_'
        end).to include(*EnumArgs::ProxiedEnumerable::ClassMethods::METHODS)
      end
    end

    context 'when specifying malformed dynamic parameters' do
      it 'raises TypeError' do
        expect{ enum_args.using = [1,2,3] }.to raise_error(TypeError)
      end
    end
  end

  context 'when using EnumArgs::Proxy directly' do
    subject { Helpers::EnumArgsUser.new }

    it { is_expected.not_to be_a(Enumerable) }
    it { is_expected.not_to be_a(EnumArgs::ProxiedEnumerable) }

    it_behaves_like 'an enumerable'
    it_behaves_like 'an enumerator'

    it_expects_to 'raise on invocation errors'
  end
end
