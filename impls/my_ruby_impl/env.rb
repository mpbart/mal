class Env
  def initialize(outer, binds: [], exprs: [])
    @outer = outer
    @data = {}
    binds.zip(exprs).each{ |key, value| set(key, value) }
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
end
