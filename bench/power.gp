set output "power.eps"
set terminal epslatex color 
set logscale x

set key noautotitles
set xlabel "Exponent (2\\textsuperscript{\\textit x})"
set ylabel "Requests per second" 0.8
set border 3
set xtics nomirror (127, 255, 511, 1023, 2047, 4095, 8191)
set xrange [108:9742]
set ytics nomirror 200
set yrange [0:800]
set mxtics 0
set nozeroaxis
set size .68,.60
set grid ytics
set key 300,280 reverse Left

plot "power.dat"   with lp lw 2 pt 6 title "Staged", \
     "powerun.dat" with lp lw 2 pt 8 title "Unstaged"
