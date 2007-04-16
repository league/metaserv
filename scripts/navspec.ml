let spec = 
  ["/" ,"<img alt='Home' src='/images/camel.icon.png' />" ,[];
   "/browse"      ,"Browse"             ,[
     "/server/"   ,  "Server"             ;
     "/metac/"    ,  "Translator"         ;
     "/scripts/"  ,  "Scripts"            ;
     "/bench/"    ,  "Benchmarking"       ;
     "/paper/"    ,  "Paper"              ];
   "/power17"     ,"Power"              ,[
     "/power17"   ,  "17"                 ;
     "/power127"  ,  "127"                ;
     "/power255"  ,  "255"                ;
     "/power511"  ,  "511"                ;
     "/power1023" ,  "1023"               ;
     "/power2047" ,  "2047"               ;
     "/power4095" ,  "4095"               ;
     "/power8191" ,  "8191"               ];
   "/uname"       ,"Stats"              ,[
     "/uname"     ,  "Architecture"       ;
     "/uptime"    ,  "Uptime"             ;
     "/gc"        ,  "Garbage collector"  ;
     "/http"      ,  "HTTP headers"       ];
   "/about"       ,"About"              ,[]
 ]

let preamble s = Printf.sprintf
"<html>
  <head>
    <title>MetaOCaml Server Pages: %s</title>
    <link href='/meta.css' rel='stylesheet' type='text/css' />
  </head>
<body>
" s

let navbar = NavBar.gen spec

let postamble =
"</div></body></html>
"
