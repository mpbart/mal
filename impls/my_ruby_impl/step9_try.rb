require 'pry'
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
  DEF_MACRO_SYMBOL = 'defmacro!'
  MACROEXPAND_SYMBOL = 'macroexpand'
  QUOTE_SYMBOLS = ['quote', "'"]
  QUASIQUOTE_SYMBOLS = ['quasiquote', '`']
  QUASIQUOTEEXPAND_SYMBOLS = 'quasiquoteexpand'
  UNQUOTE_SYMBOLS = ['unquote', '~']
  SPLICE_UNQUOTE_SYMBOLS = ['splice-unquote', '~@']
  TRY_SYMBOL = 'try*'

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
        ast = macro_expand(ast, env)
        return Evaluator.eval_ast(ast, env) unless ast.is_a?(MalListType)

        case ast.data[0].data
        when DEF_SYMBOL
          return env.set(ast.data[1], evals(ast.data[2], env))
        when DEF_MACRO_SYMBOL
          value = evals(ast.data[2], env)
          value.is_macro = true
          return env.set(ast.data[1], value)
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
          return MalFunctionType.new(ast: ast.data[2], params: ast.data[1].data, env: env, fn: Proc.new{ |*args| evals(ast.data[2], Env.new(env, binds: ast.data[1].data, exprs: args.flatten) )})
        when *QUOTE_SYMBOLS
          return ast.data[1]
        when *QUASIQUOTE_SYMBOLS
          ast = quasiquote(ast.data[1])
        when *QUASIQUOTEEXPAND_SYMBOLS
          return quasiquote(ast.data[1])
        when MACROEXPAND_SYMBOL
          return macro_expand(ast.data[1], env)
        when TRY_SYMBOL
          begin
            ast = evals(ast.data[1], env)
          rescue => e
            rescued_exception = MalStringType.new(e.message)
            new_env = Env.new(env, binds: [ast.data[2].data[1]], exprs: [rescued_exception])
            ast = evals(ast.data[2].data[2], new_env)
          end
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
    env.set(MalSymbolType.new('eval'), Proc.new{ |ast| evals(ast, env) })
    env.set(MalSymbolType.new('*ARGV*'), MalListType.new(Array(ARGV[1..])))
    evals(Reader.read_str("(def! not (fn* (a) (if a false true)))"), env)
    evals(Reader.read_str('(def! load-file (fn* (f) (eval (read-string (str "(do " (slurp f) "\nnil)")))))'), env)
    evals(Reader.read_str("(defmacro! cond (fn* (& xs) (if (> (count xs) 0) (list 'if (first xs) (if (> (count xs) 1) (nth xs 1) (throw \"odd number of forms to cond\")) (cons 'cond (rest (rest xs)))))))"), env)

    if ARGV[0]
      prints(evals(Reader.read_str("load-file #{ARGV[0]}"), env))
      return
    end

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
      rescue Core::IndexOutOfRange => e
        puts "ERROR: index out of range"
      rescue MalExceptionType => e
        puts "ERROR: #{e.message}"
      end
    end
  end

  def self.quasiquote(ast)
    case ast 
    when MalListType
      if ast.data.length > 0 && UNQUOTE_SYMBOLS.include?(ast.data[0].data)
        return ast.data[1]
      else
        def self.inner_quasiquote(ast)
          return ast if ast.data.empty?

          elt = ast.data[0]
          if elt.is_a?(MalListType) && elt.data.length > 0 && SPLICE_UNQUOTE_SYMBOLS.include?(elt.data[0].data)
            MalListType.new([MalSymbolType.new('concat'), elt.data[1], inner_quasiquote(MalListType.new(ast.data[1..]))])
          else
            MalListType.new([MalSymbolType.new('cons'), quasiquote(elt), inner_quasiquote(MalListType.new(ast.data[1..]))])
          end
        end

        inner_quasiquote(ast)
      end
    when MalSymbolType, MalHashMapType
      MalListType.new([MalSymbolType.new('quote'), ast])
    else
      ast
    end
  end

  def self.is_macro_call?(ast, env)
    if ast.is_a?(MalListType) && ast.data[0].is_a?(MalSymbolType)
      value = env.find(ast.data[0])
      return value && value.is_a?(MalFunctionType) && value.is_macro
    else
      false
    end
  end

  def self.macro_expand(ast, env)
    while is_macro_call?(ast, env)
      func = env.get(ast.data[0])
      ast = func.call(ast.data[1..])
    end

    ast
  end
end

REPL.rep
