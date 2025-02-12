class Printer
  def self.pr_str(ast, print_readably: false)
    case ast
    when MalCollectionType, MalHashMapType
      pr_list_type(ast, print_readably)
    when MalModifierType
      pr_modifier_type(ast)
    when MalNilType
      pr_nil_type
    when MalScalarType, MalBooleanType, MalBuiltinType
      pr_scalar_type(ast)
    when MalFunctionType
      pr_function_type(ast)
    when MalStringType
      pr_str_type(ast, print_readably)
    when MalSymbolType
      ast.data
    when MalAtomType
      pr_atom_type(ast, print_readably)
    end
  end

  def self.pr_list_type(type, print_readably)
    type.begin_char + type.data_str.map { |d| pr_str(d, print_readably: print_readably) }.join(' ') + type.end_char
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

  def self.pr_atom_type(type, print_readably)
    '(atom ' + pr_str(type.data, print_readably: print_readably).to_s + ')'
  end
end
