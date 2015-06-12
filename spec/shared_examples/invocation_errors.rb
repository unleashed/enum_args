RSpec.shared_examples_for 'raise on invocation errors' do
  context "when invoking a method that won't take parameters" do
    it 'raises ArgumentError if it receives a String' do
      expect { subject.lazy('unexpected_param') }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError if it receives unknown keyword arguments' do
      expect { subject.lazy(unexpected_param: 27) }.to raise_error(ArgumentError)
    end
  end
end
