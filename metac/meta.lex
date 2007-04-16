(* -*- sml -*- *)
open Tokens LexUtils
val eof = make_eof EOF

type lexresult = (svalue, pos) token
type arg = lexresult arg

%%
%header (functor MetaLexFun(Tokens: Meta_TOKENS));
%arg ({push,dump,inc,dec,pos,<<,<<$,...});
%s PROC TRACE STR;
%%

<INITIAL>"<?^"    => (<<yytext LP_DECL before YYBEGIN PROC);
<INITIAL>"<?pragma" => (<<yytext LP_PRAGMA before YYBEGIN PROC);

<INITIAL>"<?"     => (<<yytext LP before YYBEGIN TRACE);
<INITIAL>"<?="    => (<<yytext LP_EQ before YYBEGIN PROC);
<INITIAL>"<?\""   => (<<yytext LP_FMT before YYBEGIN STR);

<INITIAL>"<?~"    => (<<yytext LP_CODE before YYBEGIN PROC);
<INITIAL>"<?~="   => (<<yytext LP_CODE_EQ before YYBEGIN PROC);
<INITIAL>"<?~\""  => (<<yytext LP_CODE_FMT before YYBEGIN STR);
<INITIAL>"<?~let" => (<<yytext LP_CODE_LET before YYBEGIN TRACE);

<INITIAL>"<?!"    => (<<yytext LP_LIFT before YYBEGIN PROC);
<INITIAL>"<?!="   => (<<yytext LP_LIFT_EQ before YYBEGIN PROC);
<INITIAL>"<?!\""  => (<<yytext LP_LIFT_FMT before YYBEGIN STR);
<INITIAL>"<?!let" => (<<yytext LP_LIFT_LET before YYBEGIN TRACE);

<INITIAL>[^<]+    => (push yytext; <<$(dump()) "text" TEXT);
<INITIAL>"<"      => (push yytext; continue());

<PROC>"?>"        => (<<yytext RP before YYBEGIN INITIAL);
<PROC>"?>\n"      => (<<yytext RP before YYBEGIN INITIAL);
<PROC>[^\?]+      => (push yytext; <<$(dump()) "c0" CODE);
<PROC>"?"         => (push yytext; continue());

<STR>"\""     => (<<$(dump()) "str" STRING before YYBEGIN TRACE);
<STR>"\\\""   => (push yytext; continue());
<STR>(.|\n)   => (push yytext; continue());

<TRACE>"?>"   => (<<yytext RP before YYBEGIN INITIAL);
<TRACE>"?>\n" => (<<yytext RP before YYBEGIN INITIAL);
<TRACE>".<"   => (<<yytext LANGLE);
<TRACE>">."   => (<<yytext RANGLE);
<TRACE>"("    => (<<yytext LPAREN);
<TRACE>")"    => (<<yytext RPAREN);
<TRACE>"{"    => (<<yytext LCURLY);
<TRACE>"}"    => (<<yytext RCURLY);
<TRACE>"["    => (<<yytext LBRACK);
<TRACE>"]"    => (<<yytext RBRACK);
<TRACE>"let"  => (<<yytext LET);
<TRACE>"in"   => (<<yytext IN);
<TRACE>";"    => (<<yytext SEMI);
<TRACE>","    => (<<yytext COMMA);
<TRACE>"="    => (<<yytext EQ);
<TRACE>[ \t\n]+ => (<<$yytext "c1" CODE);
<TRACE>[A-Za-z_']+ => (<<$yytext "c2" CODE);
<TRACE>. => (<<$yytext "c3" CODE);

. => (print ("\n"^pos2str(pos())^": Error: unrecognized character #\""^
             Char.toString (String.sub(yytext,0))^"\"\n");
      raise LexError);
