module Core
  class << self
    def ns
      @ns ||= {
        MalSymbolType.new('*') => Proc.new{ |a, b| MalIntegerType.new(a.data * b.data)},
        MalSymbolType.new('/') => Proc.new{ |a, b| MalIntegerType.new(a.data / b.data)},
        MalSymbolType.new('+') => Proc.new{ |a, b| MalIntegerType.new(a.data + b.data)},
        MalSymbolType.new('-') => Proc.new{ |a, b| MalIntegerType.new(a.data - b.data)},
        MalSymbolType.new('prn') => Proc.new{ |*args| print Printer.pr_str(args[0], print_readably: true); MalNilType.new(nil) },
        MalSymbolType.new('list') => Proc.new{ |*args| MalListType.new(args) },
        MalSymbolType.new('list?') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].is_a? MalListType) },
        MalSymbolType.new('empty?') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].data.empty?) },
        MalSymbolType.new('count') => Proc.new{ |*args| MalIntegerType.new(args[0].is_a?(MalListType) ? args[0].data.count : args[0].count) },
        MalSymbolType.new('=') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].class == args[1].class && args[0] == args[1]) },
        MalSymbolType.new('<') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].data < args[1].data) },
        MalSymbolType.new('<=') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].data <= args[1].data) },
        MalSymbolType.new('>') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].data > args[1].data) },
        MalSymbolType.new('>=') => Proc.new{ |*args| MalBooleanFactory.to_boolean(args[0].data >= args[1].data) },
      }
    end
  end
end
