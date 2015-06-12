RSpec.shared_examples_for 'an enumerable' do |enum_args = :enum_args|
  context 'when calling Enumerable methods' do
    Helpers::ENUMERABLE_METHODS.each do |m, args, blk|
      context "when calling #{Helpers.call_description(m, args, blk)}" do
        it "returns an Enumerator" do
          expect(subject.send(m, *args, &blk)).to be_a(Enumerator)
        end

        it_behaves_like 'a parameterized iterator', enum_args, m, args, blk

        context 'and chaining with Enumerator methods' do
          (m == :lazy ? Helpers::ENUMERATOR_LAZY_METHODS :
           Helpers::ENUMERATOR_METHODS).each do |n, n_args, n_blk|
            context "when chaining with #{Helpers.call_description(m, args, blk, [n, n_args, n_blk])}" do
              it 'returns an Enumerator' do
                expect(subject.send(m, *args, &blk).send(n, *n_args, &n_blk)).to be_a(Enumerator)
              end

              it_behaves_like 'a parameterized iterator', enum_args, m, args, blk, [n, n_args, n_blk]
            end
          end
        end
      end
    end
  end
end
