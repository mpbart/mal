module Core
  class IndexOutOfRange < StandardError; end

  class << self
    attr_accessor :ns

    def add_builtin(symbol, &block)
      ns[MalSymbolType.new(symbol)] = MalBuiltinType.new(symbol, &block)
    end

    def ns
      @ns ||= {}
    end
  end

  add_builtin('*')          { |*args| MalIntegerType.new(args[0].data * args[1].data)}
  add_builtin('/')          { |*args| MalIntegerType.new(args[0].data / args[1].data)}
  add_builtin('+')          { |*args| MalIntegerType.new(args[0].data + args[1].data)}
  add_builtin('-')          { |*args| MalIntegerType.new(args[0].data - args[1].data)}
  add_builtin('=')          { |*args| MalBooleanFactory.to_boolean(args[0].equals?(args[1])) }
  add_builtin('<')          { |*args| MalBooleanFactory.to_boolean(args[0].data < args[1].data) }
  add_builtin('>')          { |*args| MalBooleanFactory.to_boolean(args[0].data > args[1].data) }
  add_builtin('@')          { |*args| args[0].data }
  add_builtin('<=')         { |*args| MalBooleanFactory.to_boolean(args[0].data <= args[1].data) }
  add_builtin('>=')         { |*args| MalBooleanFactory.to_boolean(args[0].data >= args[1].data) }
  add_builtin('apply')      { |*args| args[0].call(*args[1...-1].map{ |i| i }.concat(args[-1].data)) }
  add_builtin('assoc')      { |*args| MalHashMapType.new(args[0].data + args[1..]) }
  add_builtin('atom')       { |*args| MalAtomType.new(args[0]) }
  add_builtin('atom?')      { |*args| MalBooleanFactory.to_boolean(args[0].is_a? MalAtomType) }
  add_builtin('conj')       { |*args| MalNilType.new(nil) }
  add_builtin('concat')     { |*args| MalListType.new(args.each_with_object([]) { |i, acc| acc.concat(i.data) })}
  add_builtin('cons')       { |*args| MalListType.new([args[0]] + args[1].data) }
  add_builtin('contains?')  { |*args| args[0].contains?(args[1]) }
  add_builtin('count')      { |*args| MalIntegerType.new(args[0].is_a?(MalListType) ? args[0].data.count : args[0].count) }
  add_builtin('deref')      { |*args| args[0].data }
  add_builtin('dissoc')     { |*args| MalHashMapType.new(Array(args[0].remove_keys(args[1..]).map.reduce(&:concat))) }
  add_builtin('empty?')     { |*args| MalBooleanFactory.to_boolean(args[0].data.empty?) }
  add_builtin('false?')     { |*args| MalBooleanFactory.to_boolean(args[0].is_a?(MalFalseType)) }
  add_builtin('first')      { |*args| Array(args[0].data).first || MalNilType.new(nil) }
  add_builtin('fn?')        { |*args| MalNilType.new(nil) }
  add_builtin('get')        { |*args| args[0].get(args[1]) }
  add_builtin('hash-map')   { |*args| MalHashMapType.new(args) }
  add_builtin('keys')       { |*args| MalListType.new(args[0].keys) }
  add_builtin('keyword')    { |*args| args[0].is_a?(MalKeywordType) ? args[0] : MalKeywordType.new(':' + args[0].data) }
  add_builtin('keyword?')   { |*args| MalBooleanFactory.to_boolean(args[0].is_a?(MalKeywordType)) }
  add_builtin('list')       { |*args| MalListType.new(args) }
  add_builtin('list?')      { |*args| MalBooleanFactory.to_boolean(args[0].is_a? MalListType) }
  add_builtin('map')        { |*args| MalListType.new(args[1].data.map{ |i| args[0].fn.call(i) }) }
  add_builtin('map?')       { |*args| MalBooleanFactory.to_boolean(args[0].is_a?(MalHashMapType)) }
  add_builtin('meta')       { |*args| MalNilType.new(nil) }
  add_builtin('number?')    { |*args| MalNilType.new(nil) }
  add_builtin('nil?')       { |*args| MalBooleanFactory.to_boolean(args[0].is_a?(MalNilType)) }
  add_builtin('nth')        { |*args| raise Core::IndexOutOfRange unless args[0].data.length > args[1].data; args[0].data[args[1].data] }
  add_builtin('pr-str')     { |*args| MalStringType.new(args.map{ |s| Printer.pr_str(s, print_readably: true) }.join(' ')) }
  add_builtin('println')    { |*args| puts args.map{ |arg| Printer.pr_str(arg, print_readably: false) }.join(' '); MalNilType.new(nil) }
  add_builtin('prn')        { |*args| puts args.map{ |arg| Printer.pr_str(arg, print_readably: true) }.join(' '); MalNilType.new(nil) }
  add_builtin('str')        { |*args| MalStringType.new(args.map{ |s| Printer.pr_str(s, print_readably: false) }.join('')) }
  add_builtin('readline')   { |*args|  puts Printer.pr_str(args[0]); MalStringType.new($stdin.readline.chomp) }
  add_builtin('read-string'){ |*args| Reader.read_str(args[0].data) }
  add_builtin('reset!')     { |*args| args[0].data = args[1]; args[1] }
  add_builtin('rest')       { |*args| MalListType.new(Array(Array(args[0].data)[1..])) }
  add_builtin('seq')        { |*args| MalNilType.new(nil) }
  add_builtin('sequential?'){ |*args| MalBooleanFactory.to_boolean(args[0].is_a?(MalSequentialType)) }
  add_builtin('slurp')      { |*args| MalStringType.new(File.open(args[0].data).read) }
  add_builtin('string?')    { |*args| MalNilType.new(nil) }
  add_builtin('swap!')      { |*args| args[0].data = args[1].call(args[0].data, *args[2..]); args[0].data }
  add_builtin('symbol?')    { |*args| MalBooleanFactory.to_boolean(args[0].is_a?(MalSymbolType)) }
  add_builtin('symbol')     { |*args| MalSymbolType.new(args[0].data) }
  add_builtin('throw')      { |*args| raise MalExceptionType.new(args[0].data) }
  add_builtin('time-ms')    { |*args| MalNilType.new(nil) }
  add_builtin('true?')      { |*args| MalBooleanFactory.to_boolean(args[0].is_a?(MalTrueType)) }
  add_builtin('vals')       { |*args| MalListType.new(args[0].vals) }
  add_builtin('vector')     { |*args| MalVectorType.new(args) }
  add_builtin('vector?')    { |*args| MalBooleanFactory.to_boolean(args[0].is_a?(MalVectorType)) }
  add_builtin('with-meta')  { |*args| MalNilType.new(nil) }
end
