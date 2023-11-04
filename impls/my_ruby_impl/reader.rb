require_relative 'types'

class Reader
  attr_reader :tokens
  attr_accessor :current_position

  class InvalidTokenError < StandardError; end
  class EOFError < StandardError; end

  LINE_REGEX = /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"?|;.*|[^\s\[\]{}('"`,;)]*)/
  INTEGER_REGEX = /^\-?[0-9]+$/
  SYMBOL_REGEX = /[0-9a-zA-Z\/\+\-\*\<\>\=\&]+/
  DEREF_TOKEN = '@'
  STRING_REGEX = /\A"(?:\\.|[^\\"])*"\z/
  SPECIAL_FORM_ALIASES = {'~' => 'unquote', '`' => 'quasiquote', "'" => 'quote', '~@' => 'splice-unquote'}
  SPECIAL_FORMS = ['let*', 'def!', 'do', 'quote', 'quasiquote']
  KEYWORD_PREFIX = ':'
  COMMENT_PREFIX = ';'
  BOOLEAN_TYPES = ['true', 'false']
  NIL_TYPE = 'nil'
  COMMENT = :comment

  def initialize(tokens)
    @tokens = tokens
    @current_position = 0
  end

  def _next
    tmp = peek
    @current_position += 1
    tmp
  end

  def peek
    tokens[current_position]
  end

  def self.read_str(raw)
    new(tokenize(raw)).read_form
  end

  def self.tokenize(raw)
    raw.scan(LINE_REGEX).flatten.reject(&:empty?)
  end

  def read_form
    case peek
    when '('
      read_list
    when '['
      read_list(vector: true)
    when '{'
      read_list(hash_map: true)
    when ')', ']', '}'
      _next
      return
    else
      read_atom
    end
  end

  def read_atom
    current = _next

    if current.nil?
      raise EOFError.new
    elsif current && current[0] == COMMENT_PREFIX
      COMMENT
    elsif current && current == DEREF_TOKEN
      m = MalListType.new
      m.data << MalSymbolType.new('deref')
      m.data << read_form
      m
    elsif current && current[0] == KEYWORD_PREFIX
      MalKeywordType.new(current)
    elsif INTEGER_REGEX.match? current
      MalIntegerType.new(current)
    elsif SPECIAL_FORM_ALIASES.keys.include? current
      m = MalListType.new
      m.data << MalSymbolType.new(SPECIAL_FORM_ALIASES[current])
      m.data << read_form
      m
    elsif SPECIAL_FORMS.include? current
      MalSpecialFormType.new(current)
    elsif current == NIL_TYPE
      MalNilType.new(nil)
    elsif STRING_REGEX.match? current
      MalStringType.new(current[1...-1])
    elsif BOOLEAN_TYPES.include? current
      MalBooleanFactory.to_boolean(current)
    elsif SYMBOL_REGEX.match? current
      MalSymbolType.new(current)
    else
      raise InvalidTokenError.new("#{current} is not a valid token")
    end
  end

  def read_list(vector: false, hash_map: false)
    list = if vector
      MalVectorType.new
    elsif hash_map
      MalHashMapType.new
    else
      MalListType.new
    end
    _next

    while true
      next_token = read_form
      break unless next_token

      list << next_token unless comment?(next_token)
    end

    list
  end

  def comment?(next_token)
    next_token == COMMENT
  end
end
