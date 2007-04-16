
structure MetaLrVals =
  MetaLrValsFun(structure Token = LrParser.Token)
structure MetaLex =
  MetaLexFun(MetaLrVals.Tokens)
structure MetaParser = 
  JoinWithArg
    (structure ParserData=MetaLrVals.ParserData
     structure Lex=MetaLex
     structure LrParser=LrParser)

structure Main =
struct

fun err (s,p1,p2) = 
    raise Fail (LexUtils.pos2str p1^"-"^
                LexUtils.pos2str p2^": "^s)

fun parse f =
    let val i = TextIO.openIn f
        fun close() = TextIO.closeIn i
        fun input n = TextIO.inputN(i,n)
        val arg = LexUtils.new()
        val stream = MetaParser.makeLexer input arg
     in #1(MetaParser.parse(512, stream, err, ())
           handle e => (close(); raise e))
        before close()
    end

fun main(_,[f]) =
    let val {decl,code,pragmas} = parse f
        val base = OS.Path.base f
        val m = explode(OS.Path.file base)
        val m = implode(Char.toUpper(hd m) :: tl m)
        val outf = OS.Path.joinBaseExt {base=base, ext=SOME "ml"}
        val out = TextIO.openOut outf
        fun w s = TextIO.output(out,s)
        val args = Option.getOpt(AtomMap.find(pragmas, Atom.atom "args"),"")
     in w "module "; w m; w " = struct\n"
      ; w "let lift x = .<x>.\n"
      ; Buf.output decl out
      ; w "let page "; w args; w " = .<fun req puts ->\n"
      ; w "let arg = Request.arg req in\n"
      ; Buf.output code out
      ; w "\n>.\nend\n"
      ; TextIO.closeOut out
      ; 0
    end
  | main _ = 
    (TextIO.output(TextIO.stdErr, "Usage: metac filename.meta\n");
     1)

end
