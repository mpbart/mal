require_relative 'types'

class Evaluator
  class SymbolNotFound < StandardError; end

  def self.eval_ast(ast, env)
    case ast
    when MalSymbolType
      env.get(ast)
    when MalListType, MalVectorType, MalHashMapType
      ast.class.new(ast.data.map{ |item| REPL.evals(item, env) })
    else
      ast
    end
  end
end
