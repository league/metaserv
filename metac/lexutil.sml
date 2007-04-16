signature LEX_UTILS = 
sig
    type pos = {offset:int, line:int, col:int}
    type 'a arg = 
         { push : string -> unit,
           dump : unit -> string,
           pos  : unit -> pos,
           inc  : string -> unit,
           dec  : string -> bool,
           <<   : string -> (pos * pos -> 'a) -> 'a,
           <<$  : string -> string -> (string * pos * pos -> 'a) -> 'a
           }
    val zero : pos
    val make_eof : (pos * pos -> 'a) -> 'a arg -> 'a
    val pos2str : pos -> string
    val new : unit -> 'a arg
    val DEBUG : bool ref
end

structure LexUtils : LEX_UTILS =
struct

type pos = {offset:int, line:int, col:int}
type 'a arg = 
     { push : string -> unit,
       dump : unit -> string,
       pos  : unit -> pos,
       inc  : string -> unit,
       dec  : string -> bool,
       <<   : string -> (pos * pos -> 'a) -> 'a,
       <<$  : string -> string -> (string * pos * pos -> 'a) -> 'a
       }

fun pos2str ({line, col, ...} : pos) =
    Int.toString line ^ "." ^ 
    (StringCvt.padLeft #"0" 3 (Int.toString col))

val DEBUG = ref false
val col = ref 0
fun show text =
    let val text = String.toString text
        val text = if size text < 30 then text
                   else String.substring(text,0,29)^"#"
     in "("^text^") "
    end

fun say s = 
    let val nc = !col + size s
     in if nc > 74 then print "\n" before col := size s
        else col := nc
      ; print s
    end

fun make_eof tok (a : 'a arg) =
    let val p = #pos a ()
     in if !DEBUG then say ">>>EOF<<<" else()
      ; tok(p,p)
    end

val zero = {offset=0, line=0, col=0}

val tstop = 8
fun tabify c = c div tstop * tstop + tstop

fun click(char, {offset, line, col}) =
    case char
      of #"\n" => {offset=offset+1, line=line+1, col=1}
       | #"\t" => {offset=offset+1, line=line, col=tabify(col-1)+1}
       | _ => {offset=offset+1, line=line, col=col+1}

fun new() =
let val pos = ref {offset=0, line=1, col=1}
    val accum = ref nil
    val depth = ref 0

    fun push s = accum := s :: (!accum)
    fun dump() = String.concat(rev(!accum)) before accum := nil

    fun inc  text = (push text; depth := !depth + 1)
    fun dec  text = (push text; depth := !depth - 1; !depth > 0)

    fun update text =
        let val from = !pos
            val to = CharVector.foldl click from text
         in (from, to) before pos := to
        end

    fun << text tok = 
        (if !DEBUG then say(show text) else();
         tok(update text))

    fun <<$ text s tok = 
        let val (p,q) = update text
         in if !DEBUG then say(s^show text)
            else()
          ; tok(text, p, q)
        end
 in { push=push, dump=dump, inc=inc, dec=dec,
      pos=fn()=> !pos, << = <<, <<$ = <<$ }
end

end
