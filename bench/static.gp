set output "static.eps"
set terminal epslatex color 9
set size 1,1.2
set logscale x
set border 3

set ylabel "Requests per second" 
set ytics nomirror 250
set yrange [0:1500]

set xlabel "File size (bytes)" 
set xtics nomirror ("1k" 1024, "2k" 2048, "4k" 4096, "8k" 8192, "16k" 16384, "32k" 32768, "64k" 65536)
set xrange [768:98304]
set mxtics 2
set grid ytics 
set key outside below reverse Left spacing 1.7

plot \
  "static.nativefile.dat" with lp lw 2 lt 2 title "OCaml FileHandler (native)", \
  "static.camlfile.dat"   with lp lw 2 lt 4 title "OCaml FileHandler (byte code)", \
  "static.camlcode.dat"   with lp lw 2 lt 1 title "MetaOCaml CodeHandler (byte code)", \
  "static.php.dat"        with lp lw 2 lt 6 title "PHP"
