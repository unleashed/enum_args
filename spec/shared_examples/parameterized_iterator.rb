RSpec.shared_examples_for 'a parameterized iterator' do |enum_args, m, args, blk, n = nil|
  it "calls the iterator when chaining .next" do
    expect(subject).to receive(iterator_method(enum_args))
    e = call_method(subject, m, args, blk)
    e = call_method(e, *n) unless n.nil?
    e.next rescue StopIteration
  end

  it "calls the iterator with default params when chaining .next" do
    eargs = iterator_args(enum_args).dup
    eargs << iterator_using(enum_args)

    expect(subject).to receive(iterator_method(enum_args)).with(*eargs)

    e = call_method(subject, m, args, blk)
    e = call_method(e, *n) unless n.nil?
    e.next rescue StopIteration
  end

  it 'calls the iterator with specific params when chaining .next' do
    using = iterator_using(enum_args)
    (using.keys.size + 1).times.map do |size|
      using.to_a.combination(size).to_a.flatten
    end.each do |combined_kv_ary|
      h = {}
      combined_kv_ary.each_slice(2) do |k, v|
        h[k] = v.to_i + 1
      end

      eargs = Array(iterator_args(enum_args)).dup
      eargs << using.merge(h)
      targs = Array(args).dup
      targs << h

      expect(subject).to receive(iterator_method(enum_args)).with(*eargs)

      e = call_method(subject, m, targs, blk)
      e = call_method(e, *n) unless n.nil?
      e.next rescue StopIteration
    end
  end

  private

  def call_method(subject, m, args, blk)
    if blk.nil?
      subject.send(m, *args)
    else
      subject.send(m, *args, &blk)
    end
  end

  def iterator(enum_args)
    subject.send(enum_args)
  end

  def iterator_method(enum_args)
    iterator(enum_args).method_name
  end

  def iterator_args(enum_args)
    iterator(enum_args).args
  end

  def iterator_using(enum_args)
    iterator(enum_args).using
  end
end
