<?php 
## directory argument is first stage
$d = $_SERVER['argv'][1];

## navigation bar generated in first stage
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
?>
<?= "<?php\n" ?>
## regular expression and sort order are second stage arguments:
if (isset($_GET['re'])) {
   if($_GET['re']) {
      $re = $_GET['re'];
   }
   else {
      $re = ".";
   }
}
else {
   $re = "^[^\\.].*[^~]$";
}

$ord = $_GET['ord'];
<?php

### We can list the files and prepare the entries in the first stage,
### but filtering is saved for later.

$entry_fmt = 
"<span class='md5'>%-32s</span>  %-13s  %5s  <a class='file' href='%s'><span class='%s'>%s</span></a>%s\n";

$list = array();
$dh = opendir($d);
while(($file = readdir($dh)) !== false) {
      $fd = array();
      $path = "$d/$file";
      $fd['name'] = $file;
      $fd['ext'] = strrchr($file, ".");
      $fd['kind'] = "";
      $ind = "";
      switch(filetype($path)) {
      case "dir":   $fd['kind'] = "dir";     $ind = "/"; break;
      case "link":  $fd['kind'] = "symlink"; $ind = "@"; break;
      case "fifo":  $fd['kind'] = "fifo";    $ind = "|"; break;
      case "block": $fd['kind'] = "bdev";    $ind = "";  break;
      default:
         switch($fd['ext']) {
         case ".a"  : $fd['kind'] = "lib"; break;
         case ".cma": $fd['kind'] = "lib"; break;
         case ".cmi": $fd['kind'] = "obj"; break;
         case ".cmo": $fd['kind'] = "obj"; break;
         case ".ml" : $fd['kind'] = "src"; break;
         case ".mli": $fd['kind'] = "hdr"; break;
         }
      }
      $fd['mtime'] = filemtime($path);
      $fd['size'] = filesize($path);
      $fd['md5'] = $ind=="/"? "" : md5(file_get_contents($path));
      $fd['prn'] = 
         sprintf($entry_fmt, $fd['md5'], 
                 strftime("%e %b %H:%M", $fd['mtime']),
                 human_size($fd['size']), $path, 
                 $fd['kind'], $fd['name'], $ind);
      array_push($list, $fd);
}
closedir($dh);

### Now it's time to pass that array from first to second stage.
### Using var_export seems to be slow.  Maybe serialize is better?
## print "\$list = ";
## print var_export($list);
## print ";\n";
print "\$list = unserialize(\"". addcslashes(serialize($list),'"'). "\");\n";
?>

#### Sort files -- 2nd stage code
function cmp_ext($a,$b) { return strcmp($a['ext'],$b['ext']); }
function cmp_kind($a,$b) { return strcmp($a['kind'],$b['kind']); }
function cmp_name($a,$b) { return strcmp($a['name'],$b['name']); }

function numcmp($a,$b) { return ($a == $b)? 0 : (($a < $b)? -1 : 1); }
function cmp_mtime($a,$b) { return numcmp($a['mtime'],$b['mtime']); }
function cmp_size($a,$b) { return numcmp($a['size'],$b['size']); }

switch($ord) {
case "ext":  usort($list, "cmp_ext"); break;
case "kind": usort($list, "cmp_kind"); break;
case "time": usort($list, "cmp_mtime"); break;
case "size": usort($list, "cmp_size"); break;
default:     usort($list, "cmp_name");
}
<?= "?>\n" ?>

<form method="get" action="">
<input type="submit" value="Redisplay" />
files matching
<input type="text" name="re" size="14" value='<?= "<?= \$re ?>" ?>' />
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
<?= "<?\n" ?>
   foreach($list as $f) {
      if(ereg($re, $f['name'])) {
         print $f['prn'];
      }
   }
<?= "?>\n" ?>
</pre>
<? postamble(); ?>

<?
function preamble($title)
{
   print
"<html>
  <head>
    <title>MetaOCaml Server Pages: $title</title>
    <link href='./meta.css' rel='stylesheet' type='text/css' />
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
   if($n < 1024) { return sprintf("%4d ", $n); }
   else if($n < 102400) { return sprintf("%2.1fk", $n/1024); }
   else if($n < 1024000) { return sprintf("%4dk", $n/1024); }
   else if($n < 104857600) { return sprintf("%2.1fM", $n/1048576); }
   else { return sprintf("%4dM", $n/1048576); }
}


 ?>
