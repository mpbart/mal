class Env
  VARIADIC_IDENTIFIER = '&'

  def initialize(outer, binds: [], exprs: [])
    @outer = outer
    @data = {}
    if binds.map(&:data).include? VARIADIC_IDENTIFIER
      bind_variadic_args(binds, exprs)
    else
      binds.zip(exprs).each{ |key, value| set(key, value) }
    end
  end

  def set(key, value)
    @data[key.data] = value
  end

  def find(key)
    if !@data[key.data].nil?
      return @data[key.data]
    elsif !@outer.nil?
      @outer.find(key)
    end
  end

  def get(key)
    value = find(key)
    raise Evaluator::SymbolNotFound.new("#{key.data} not found") unless value
    value
  end

  def bind_variadic_args(binds, exprs)
    pivot_idx = binds.map(&:data).index(VARIADIC_IDENTIFIER)
    variadic_arg = binds[pivot_idx + 1]

    binds[0...pivot_idx].zip(exprs[0...pivot_idx]).each { |key, value| set(key, value) }
    set(variadic_arg, MalListType.new(exprs[pivot_idx..]))
  end
end
