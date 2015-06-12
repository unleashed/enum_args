require 'spec_helper'

RSpec.describe EnumArgs do
  it 'has a version number' do
    expect(EnumArgs::VERSION).not_to be nil
  end

  context 'when including EnumArgs' do
    subject { Helpers::IncludeEnumArgs.new }

    it { is_expected.to be_a(Enumerable) }
    it { is_expected.to be_a(EnumArgs::ProxiedEnumerable) }
    it { is_expected.to respond_to(subject.class.enum_accessor_method) }

    it_behaves_like 'an enumerable', Helpers::IncludeEnumArgs.enum_accessor_method
    it_behaves_like 'an enumerator', Helpers::IncludeEnumArgs.enum_accessor_method

    it_expects_to 'raise on invocation errors'
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
