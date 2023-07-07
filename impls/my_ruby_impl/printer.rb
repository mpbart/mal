class Printer
  def self.pr_str(ast, print_readably: false)
    case ast
    when MalCollectionType
      pr_list_type(ast)
    when MalModifierType
      pr_modifier_type(ast)
    when MalNilType
      pr_nil_type
    when MalScalarType, MalBooleanType
      pr_scalar_type(ast)
    when MalFunctionType
      pr_function_type(ast)
    when MalStringType
      pr_str_type(ast, print_readably)
    end
  end

  def self.pr_list_type(type)
    type.begin_char + type.data.map { |d| pr_str(d) }.join(' ') + type.end_char
  end

  def self.pr_scalar_type(type)
    type.data_str
  end

  def self.pr_modifier_type(type)
    '(' + type.identifier + pr_str(type.data) + ')'
  end

  def self.pr_function_type(type)
    '#<function>'
  end

  def self.pr_nil_type
    'nil'
  end

  def self.pr_str_type(type, print_readably)
    return type.data unless print_readably

    type.data_str
  end
end
