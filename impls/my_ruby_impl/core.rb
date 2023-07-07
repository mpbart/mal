module Core
  class << self
    def ns
      @ns ||= {
        MalSymbolType.new('*') => Proc.new{ |a, b| MalIntegerType.new(a.data * b.data)},
        MalSymbolType.new('/') => Proc.new{ |a, b| MalIntegerType.new(a.data / b.data)},
        MalSymbolType.new('+') => Proc.new{ |a, b| MalIntegerType.new(a.data + b.data)},
        MalSymbolType.new('-') => Proc.new{ |a, b| MalIntegerType.new(a.data - b.data)},
        MalSymbolType.new('list') => Proc.new{ |*args| MalListType.new(args) },
        MalSymbolType.new('list?') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].is_a? MalListType) },
        MalSymbolType.new('empty?') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].data.empty?) },
        MalSymbolType.new('count') => Proc.new{ |*args| MalIntegerType.new(args[0].is_a?(MalListType) ? args[0].data.count : args[0].count) },
        MalSymbolType.new('=') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0] == args[1]) },
        MalSymbolType.new('<') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].data < args[1].data) },
        MalSymbolType.new('<=') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].data <= args[1].data) },
        MalSymbolType.new('>') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].data > args[1].data) },
        MalSymbolType.new('>=') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].data >= args[1].data) },
        MalSymbolType.new('pr-str') => Proc.new{ |*args| MalStringType.new(args.map{ |s| Printer.pr_str(s, print_readably: true) }.join(' ')) },
        MalSymbolType.new('str') => Proc.new{ |*args| MalStringType.new(args.map{ |s| Printer.pr_str(s, print_readably: false) }.join('')) },
        MalSymbolType.new('prn') => Proc.new{ |*args| puts args.map{ |arg| Printer.pr_str(arg, print_readably: true) }.join(' '); MalNilType.new(nil) },
        MalSymbolType.new('println') => Proc.new{ |*args| puts args.map{ |arg| Printer.pr_str(arg, print_readably: false) }.join(' '); MalNilType.new(nil) },
      }
    end
  end
end
