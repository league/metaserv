<?php 
$d = $_GET['d'];

$navspec = array(
  array("/", "<img alt='Home' src='/images/camel.icon.png' />", array()),
  array("/browse"      ,"Browse"             , array(
     array("/server/"   ,  "Server"             ),
     array("/metac/"    ,  "Translator"         ),
     array("/scripts/"  ,  "Scripts"            ),
     array("/bench/"    ,  "Benchmarking"       ),
     array("/paper/"    ,  "Paper"              ))),
  array("/power17"     ,"Power"              , array(
     array("/power17"   ,  "17"                 ),
     array("/power127"  ,  "127"                ),
     array("/power255"  ,  "255"                ),
     array("/power511"  ,  "511"                ),
     array("/power1023" ,  "1023"               ),
     array("/power2047" ,  "2047"               ),
     array("/power4095" ,  "4095"               ),
     array("/power8191" ,  "8191"               ))),
   array("/uname"       ,"Stats"              , array(
     array("/uname"     ,  "Architecture"       ),
     array("/uptime"    ,  "Uptime"             ),
     array("/gc"        ,  "Garbage collector"  ),
     array("/http"      ,  "HTTP headers"       ))),
   array("/about"       ,"About"              , array()));

preamble("browsing $d");
navbar();

if ($_GET['re']) {
   $re = $_GET['re'];
}
else {
   $re = "^[^\\.].*[^~]$";
}

$ord = $_GET['ord'];

$entry_fmt = 
"<span class='md5'>%-32s</span>  %-29s  %5s  <span class='%s'>%s%s</span>\n";

#### List files

$list = array();
$dh = opendir($d);
while(($file = readdir($dh)) !== false) {
   if(ereg($re, $file)) {
      $fd = array();
      $path = "$d/$file";
      $fd['name'] = $file;
      $fd['ext'] = strrchr($file, ".");
      $ind = "";
      switch(filetype($path)) {
      case "dir":   $fd['kind'] = "dir";     $ind = "/"; break;
      case "link":  $fd['kind'] = "symlink"; $ind = "@"; break;
      case "fifo":  $fd['kind'] = "fifo";    $ind = "|"; break;
      case "block": $fd['kind'] = "bdev";    $ind = "";  break;
      case "file":
         switch($fd['ext']) {
         case "a"  : $fd['kind'] = "lib"; break;
         case "cma": $fd['kind'] = "lib"; break;
         case "cmi": $fd['kind'] = "obj"; break;
         case "cmo": $fd['kind'] = "obj"; break;
         case "ml" : $fd['kind'] = "src"; break;
         case "mli": $fd['kind'] = "hdr"; break;
         }
      }
      $fd['mtime'] = filemtime($path);
      $fd['size'] = filesize($path);
      $fd['md5'] = "";
      $fd['prn'] = 
         sprintf($entry_fmt, "md5", 
                 strftime("%e %b %H:%M", $fd['mtime']),
                 human_size($fd['size']),
                 $fd['kind'], $fd['name'], $ind);
      array_push($list, $fd);
   }
}
closedir($dh);

#### Sort files

 ?>

<form method="get" action="">
<input type="hidden" name="d" value="<?= $d ?>">
<input type="submit" value="Redisplay" />
files matching
<input type="text" name="re" size="14" value="<?= $re ?>" />
ordered by
<select name="ord">
  <? ord_options(array(
       array("name", "Name"),
       array("ext",  "Extension"),
       array("time", "Timestamp"),
       array("size", "Size"),
       array("kind", "Kind"))); ?>
</select>
</form>

<pre>
<b>checksum                          last modified  size   name</b>
<? foreach($list as $f) {
      print $f['prn'];
   }
 ?>

<? postamble(); ?>

<?

function preamble($title)
{
   print
"<html>
  <head>
    <title>MetaOCaml Server Pages: $title</title>
    <link href='/meta.css' rel='stylesheet' type='text/css' />
  </head>
<body>
";
}

function postamble()
{
   print "</div></body></html>
";
}

function navbar()
{
   global $navspec;
   print "<div id='nav'><ul class='menu'>\n";
   foreach($navspec as $n)
   {
      print "<li><a href='$n[0]'>$n[1]</a></li>\n";
   }
   print "</ul><ul class='submenu' id='nav1'>\n";
   foreach($navspec[1][2] as $m)
   {
      print "<li><a href='$m[0]'>$m[1]</a></li>\n";
   }
   print "</ul></div><div id='body'>\n";
}

function ord_options($a)
{
   global $ord;
   foreach($a as $i) {
      if ($ord == $i[0]) {
         print "<option selected value='$i[0]'>$i[1]</option>\n";
      }
      else {
         print "<option value='$i[0]'>$i[1]</option>\n";
      }
   }
}

function human_size($n)
{
   if($n < 1024) { return sprintf("%4d", $n); }
   else if($n < 102400) { return sprintf("%4.1fk", $n/1024); }
   else if($n < 1024000) { return sprintf("%4dk", $n/1024); }
   else if($n < 104857600) { return sprintf("%4.1fM", $n/1048576); }
   else { return sprintf("%4dM", $n/1048576); }
}


 ?>
