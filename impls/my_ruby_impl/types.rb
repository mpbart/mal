require 'forwardable'

class MalType
  attr_accessor :data

  def initialize(data)
    @data = data
  end

  def data_str
    data
  end
end

class MalScalarType < MalType
  def equals?(other)
    other.data == data
  end

  def count
    1
  end
end

class MalCollectionType < MalType
  extend Forwardable

  def initialize(data = nil)
    @data = data || []
  end
  def_delegator :@data, :append, :<<
  def_delegator :@data, :count, :count

  def equals?(other)
    other.is_a?(MalCollectionType) &&
      other.data.length == data.length &&
      other.data.zip(data).all?{ |i, j| i == j }
  end
end

class MalListType < MalCollectionType
  def begin_char
    '('
  end

  def end_char
    ')'
  end
end

class MalVectorType < MalCollectionType
  def begin_char
    '['
  end

  def end_char
    ']'
  end
end

class MalHashMapType < MalCollectionType
  def begin_char
    '{'
  end

  def end_char
    '}'
  end
end


class MalIntegerType < MalScalarType
  def initialize(data)
    @data = data.to_i
  end
end

class MalSymbolType < MalScalarType
end

class MalNilType < MalScalarType
  def count
    0
  end
end

class MalBooleanFactory
  class InvalidBooleanValueError < StandardError; end

  def self.to_boolean(data)
    case data
    when "true", true
      MalTrueType.new(true)
    when "false", false
      MalFalseType.new(false)
    else
      raise InvalidBooleanValueError.new("#{data} is not a valid boolean value")
    end
  end
end

class MalBooleanType < MalType
  def equals?(other)
    self.class == other.class
  end
end

class MalTrueType < MalBooleanType
end

class MalFalseType < MalBooleanType
end

class MalKeywordType < MalScalarType
  def equals?(other)
    other.is_a?(MalKeywordType) && other.data == data
  end
end

class MalModifierType < MalType
end

class MalSpecialFormType < MalType
end

class MalUnquoteType < MalModifierType
  def identifier
    'unquote '
  end
end

class MalSpliceUnquoteType < MalModifierType
  def identifier
    'splice-unquote '
  end
end

class MalQuoteType < MalModifierType
  def identifier
    'quote '
  end
end

class MalQuasiQuoteType < MalModifierType
  def identifier
    'quasiquote '
  end
end

class MalWithMetaType < MalModifierType
  def identifier
    'with-meta '
  end
end

class MalFunctionType < MalType
  attr_reader :ast, :params, :env, :fn

  def initialize(ast:, params:, env:, fn:)
    @ast = ast
    @params = params
    @env = env
    @fn = fn
  end

  def call(*args, **_kwargs)
    @fn.call(*args)
  end

  def equals?(other)
    other.data.object_id == object_id
  end
end

class MalStringType < MalType
  def initialize(data)
    data.gsub!(/\\./, {"\\\\" => "\\", "\\n" => "\n", "\\\"" => '"'})
    @data = data
  end

  def data_str
    value = data.dup

    value.gsub!('\\','\\\\\\\\')
    value.gsub!("\n",'\n')
    value.gsub!('"','\"')

    "\"#{value}\""
  end

  def equals?(other)
    other.is_a?(MalStringType) && other.data == data
  end
end

class MalBuiltinType < MalType
  def initialize(repr, &blk)
    @repr = repr
    @block = blk
  end

  def call(*args, **_kwargs)
    @block.call(*args)
  end

  def data_str
    "#<MalBuiltinType: #{@repr}>"
  end
end

class MalAtomType < MalType
end
