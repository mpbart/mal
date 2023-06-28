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
  def ==(other)
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
end

class MalListType < MalCollectionType
  def begin_char
    '('
  end

  def end_char
    ')'
  end

  def ==(other)
    other.data.length == data.length && other.data.zip(data).all?{ |i, j| i == j }
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
  def self.to_boolean(data)
    if data
      MalTrueType.new(true)
    else
      MalFalseType.new(false)
    end
  end
end

class MalBooleanType < MalType
  def ==(other)
    self.class == other.class
  end
end

class MalTrueType < MalBooleanType
end

class MalFalseType < MalBooleanType
end

class MalKeywordType < MalScalarType
end

class MalModifierType < MalType
end

class MalSpecialFormType < MalType
end

class MalDerefType < MalModifierType
  def identifier
    'deref '
  end
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
  def call(*args, **kwargs)
    @data.call(*args)
  end

  def ==(other)
    other.data.object_id == object_id
  end
end
