set output "static.eps"
set terminal epslatex color 9
set size .68,.6
set logscale x
set border 3

set ylabel "Requests per second"
set ytics nomirror 200

set xlabel "File size (bytes)"
set xtics nomirror ("1k" 1024, "4k" 4096, "16k" 16384, "64k" 65536)
set xrange [768:98304]
set mxtics 2
set grid ytics 
set key 48000,1040 width 4 

#     "static.apache.dat"   with lp lw 2 title "Apache", \

plot "static.camlcode.dat" with lp lw 2 pt 6 title "Caml code", \
     "static.camlfile.dat" with lp lw 2 pt 8 title "Caml file", \
     "static.php.dat"      with lp lw 2 pt 7 lt 4 title "PHP"
