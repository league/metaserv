set output "static.eps"
set terminal epslatex color 9
set size .68,.6
set logscale x
set border 3

set ylabel "Requests per second" 0.4
set ytics nomirror 200
set yrange [0:900]

set xlabel "File size (bytes)" 
set xtics nomirror ("1k" 1024, "2k" 2048, "4k" 4096, "8k" 8192, "16k" 16384, "32k" 32768, "64k" 65536)
set xrange [768:98304]
set mxtics 2
set grid ytics 
set key 2500,400 reverse Left

#     "static.apache.dat"   with lp lw 2 title "Apache", \

plot "static.camlfile.dat" with lp lw 2 pt 8 title "Caml file", \
     "static.camlcode.dat" with lp lw 2 pt 6 title "Caml code", \
     "static.php.dat"      with lp lw 2 pt 7 lt 4 title "PHP"
