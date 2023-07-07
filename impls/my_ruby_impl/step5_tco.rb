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
    loop do
      if !ast.is_a?(MalListType)
        return Evaluator.eval_ast(ast, env)
      elsif ast.data.empty?
        return ast
      else
        case ast.data[0].data
        when DEF_SYMBOL
          return env.set(ast.data[1], evals(ast.data[2], env))
        when LET_SYMBOL
          inner_env = Env.new(env)
          ast.data[1].data.each_slice(2) { |key, value| inner_env.set(key, evals(value, inner_env)) }
          env = inner_env
          ast = ast.data[2]
        when DO_SYMBOL
          Evaluator.eval_ast(MalListType.new(ast.data[1...-1]), env)
          ast = ast.data[-1]
        when IF_SYMBOL
          result = evals(ast.data[1], env)
          ast = if !result.is_a?(MalNilType) && !result.is_a?(MalFalseType)
            ast.data[2]
          else
            if ast.data[3].nil?
              MalNilType.new(nil) 
            else
              ast.data[3]
            end
          end
        when FUNCTION_SYMBOL
          return MalFunctionType.new(ast: ast.data[2], params: ast.data[1].data, env: env)
        else
          evaluated_list = Evaluator.eval_ast(ast, env)
          f, args = evaluated_list.data[0], evaluated_list.data[1..]
          if f.is_a?(MalFunctionType)
            ast = f.ast
            env = Env.new(f.env, binds: f.params, exprs: args)
          else
            return f.call(*args.map)
          end
        end
      end
    end
  end

  def self.prints(evaluated_input)
    Printer.pr_str(evaluated_input, print_readably: true)
  end

  def self.rep
    env = Env.new(nil)
    Core.ns.each { |key, value| env.set(key, value) }
    evals(Reader.read_str("(def! not (fn* (a) (if a false true)))"), env)

    while true
      begin
        puts "user> "
        puts prints(evals(reads, env))
      rescue Reader::EOFError
        puts "ERROR: EOF"
      rescue Reader::InvalidTokenError => e
        puts "ERROR: EOF - invalid token"
      rescue Evaluator::SymbolNotFound => e
        puts e
      end
    end
  end
end

REPL.rep
