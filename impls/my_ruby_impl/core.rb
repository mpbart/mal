require 'pry'
module Core
  class IndexOutOfRange < StandardError; end

  class << self
    def ns
      @ns ||= {
        MalSymbolType.new('*') => MalBuiltinType.new('*') { |a, b| MalIntegerType.new(a.data * b.data)},
        MalSymbolType.new('/') => MalBuiltinType.new('/') { |a, b| MalIntegerType.new(a.data / b.data)},
        MalSymbolType.new('+') => MalBuiltinType.new('+') { |a, b| MalIntegerType.new(a.data + b.data)},
        MalSymbolType.new('-') => MalBuiltinType.new('-') { |a, b| MalIntegerType.new(a.data - b.data)},
        MalSymbolType.new('list') => MalBuiltinType.new('list') { |*args| MalListType.new(args) },
        MalSymbolType.new('list?') => MalBuiltinType.new('list?') { |*args| MalBooleanFactory.to_boolean(args[0].is_a? MalListType) },
        MalSymbolType.new('empty?') => MalBuiltinType.new('empty?') { |*args| MalBooleanFactory.to_boolean(args[0].data.empty?) },
        MalSymbolType.new('count') => MalBuiltinType.new('count'){ |*args| MalIntegerType.new(args[0].is_a?(MalListType) ? args[0].data.count : args[0].count) },
        MalSymbolType.new('=') => MalBuiltinType.new('='){ |*args| MalBooleanFactory.to_boolean(args[0].equals?(args[1])) },
        MalSymbolType.new('<') => MalBuiltinType.new('<'){ |*args| MalBooleanFactory.to_boolean(args[0].data < args[1].data) },
        MalSymbolType.new('<=') => MalBuiltinType.new('<='){ |*args| MalBooleanFactory.to_boolean(args[0].data <= args[1].data) },
        MalSymbolType.new('>') => MalBuiltinType.new('>'){ |*args| MalBooleanFactory.to_boolean(args[0].data > args[1].data) },
        MalSymbolType.new('>=') => MalBuiltinType.new('>='){ |*args| MalBooleanFactory.to_boolean(args[0].data >= args[1].data) },
        MalSymbolType.new('pr-str') => MalBuiltinType.new('pr-str'){ |*args| MalStringType.new(args.map{ |s| Printer.pr_str(s, print_readably: true) }.join(' ')) },
        MalSymbolType.new('str') => MalBuiltinType.new('str'){ |*args| MalStringType.new(args.map{ |s| Printer.pr_str(s, print_readably: false) }.join('')) },
        MalSymbolType.new('prn') => MalBuiltinType.new('prn'){ |*args| puts args.map{ |arg| Printer.pr_str(arg, print_readably: true) }.join(' '); MalNilType.new(nil) },
        MalSymbolType.new('println') => MalBuiltinType.new('println'){ |*args| puts args.map{ |arg| Printer.pr_str(arg, print_readably: false) }.join(' '); MalNilType.new(nil) },
        MalSymbolType.new('read-string') => MalBuiltinType.new('read-string'){ |*args| Reader.read_str(args[0].data) },
        MalSymbolType.new('slurp') => MalBuiltinType.new('slurp'){ |*args| MalStringType.new(File.open(args[0].data).read) },
        MalSymbolType.new('atom') => MalBuiltinType.new('atom'){ |*args| MalAtomType.new(args[0]) },
        MalSymbolType.new('atom?') => MalBuiltinType.new('atom?'){ |*args| MalBooleanFactory.to_boolean(args[0].is_a? MalAtomType) },
        MalSymbolType.new('deref') => MalBuiltinType.new('deref'){ |*args| args[0].data },
        MalSymbolType.new('@') => MalBuiltinType.new('@'){ |*args| args[0].data },
        MalSymbolType.new('reset!') => MalBuiltinType.new('reset!'){ |*args| args[0].data = args[1]; args[1] },
        MalSymbolType.new('swap!') => MalBuiltinType.new('swap!'){ |*args| args[0].data = args[1].call(args[0].data, *args[2..]); args[0].data },
        MalSymbolType.new('cons') => MalBuiltinType.new('cons'){ |*args| MalListType.new([args[0]] + args[1].data) },
        MalSymbolType.new('concat') => MalBuiltinType.new('concat'){ |*args| MalListType.new(args.each_with_object([]) { |i, acc| acc.concat(i.data) })},
        MalSymbolType.new('nth') => MalBuiltinType.new('nth'){ |*args| raise Core::IndexOutOfRange unless args[0].data.length > args[1].data; args[0].data[args[1].data] },
        MalSymbolType.new('first') => MalBuiltinType.new('first'){ |*args| Array(args[0].data).first || MalNilType.new(nil) },
        MalSymbolType.new('rest') => MalBuiltinType.new('rest'){ |*args| MalListType.new(Array(Array(args[0].data)[1..])) },
        MalSymbolType.new('throw') => MalBuiltinType.new('throw'){ |*args| raise MalExceptionType.new(args[0].data) },
        MalSymbolType.new('apply') => MalBuiltinType.new('apply'){ |*args| args[0].call(*args[1...-1].map{ |i| i }.concat(args[-1].data)) },
        MalSymbolType.new('map') => MalBuiltinType.new('map'){ |*args| MalListType.new(args[1].data.map{ |i| args[0].fn.call(i) }) },
        MalSymbolType.new('nil?') => MalBuiltinType.new('nil?'){ |*args| MalBooleanFactory.to_boolean(args[0].is_a?(MalNilType)) },
        MalSymbolType.new('true?') => MalBuiltinType.new('true?'){ |*args| MalBooleanFactory.to_boolean(args[0].is_a?(MalTrueType)) },
        MalSymbolType.new('false?') => MalBuiltinType.new('false?'){ |*args| MalBooleanFactory.to_boolean(args[0].is_a?(MalFalseType)) },
        MalSymbolType.new('symbol?') => MalBuiltinType.new('symbol?'){ |*args| MalBooleanFactory.to_boolean(args[0].is_a?(MalSymbolType)) },
      }
    end
  end
end
