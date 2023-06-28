require_relative 'reader'
require_relative 'printer'
require_relative 'evaluator'
require_relative 'env'
require_relative 'types'
require_relative 'core'

class REPL
  DEF_SYMBOL = 'def!'
  LET_SYMBOL = 'let*'
  DO_SYMBOL = 'do'
  IF_SYMBOL = 'if'
  FUNCTION_SYMBOL = 'fn*'

  def self.reads
    input = $stdin.readline
    Reader.read_str(input)
  end

  def self.evals(ast, env)
    if !ast.is_a?(MalListType)
      Evaluator.eval_ast(ast, env)
    elsif ast.data.empty?
      ast
    else
      case ast.data[0].data
      when DEF_SYMBOL
        env.set(ast.data[1], evals(ast.data[2], env))
      when LET_SYMBOL
        inner_env = Env.new(env)
        ast.data[1].data.each_slice(2) { |key, value| inner_env.set(key, evals(value, inner_env)) }
        evals(ast.data[2], inner_env)
      when DO_SYMBOL
        ast.data[0...-1].each{ |item| Evaluator.eval_ast(item) }
        Evaluator.eval_ast(ast.data[-1])
      when IF_SYMBOL
        result = evals(ast.data[1], env)
        if !result.is_a?(MalNilType) && !result.is_a?(MalFalseType)
          evals(ast.data[2], env)
        else
          return MalNilType.new(nil) if ast.data[3].nil?

          evals(ast.data[3], env)
        end
      when FUNCTION_SYMBOL
        MalFunctionType.new(Proc.new{ |*args| evals(ast.data[2], Env.new(env, binds: ast.data[1].data, exprs: args)) })
      else
        evaluated_list = Evaluator.eval_ast(ast, env)
        evaluated_list.data[0].call(*evaluated_list.data[1..].map)
      end
    end
  end

  def self.prints(evaluated_input)
    Printer.pr_str(evaluated_input)
  end

  def self.rep
    env = Env.new(nil)
    Core.ns.each { |key, value| env.set(key, value) }

    while true
      begin
        puts "user> "
        puts prints(evals(reads, env))
      rescue Reader::EOFError
        puts "ERROR: EOF"
      rescue Reader::InvalidTokenError
        puts "ERROR: EOF - invalid token"
      rescue Evaluator::SymbolNotFound => e
        puts e
      end
    end
  end
end

REPL.rep
