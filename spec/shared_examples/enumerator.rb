RSpec.shared_examples_for 'an enumerator' do |enum_args = :enum_args|
  it { expect(subject).to respond_to(:each) }

  context 'when creating an Enumerator' do
    [:enum_for, :to_enum].each do |m|
      it "returns an Enumerator when calling #{Helpers.call_description(m, [:iterator], nil)}" do
        expect(subject.send(m, subject.send(enum_args).method_name)).to be_a(Enumerator)
      end
    end
  end
end
