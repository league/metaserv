set output "power.eps"
set terminal epslatex color 
set logscale x

set key noautotitles
set xlabel "Exponent (2\\textsuperscript{\\textit x})"
set ylabel "Requests per second"
set border 3
set xtics nomirror 2
set ytics nomirror 200
set yrange [0:600]
set mxtics 0
set nozeroaxis
set size .68,.60
set grid ytics
set key 4600,620 width 2 

plot "power.dat"   with lp lw 2 pt 6 title "Staged", \
     "powerun.dat" with lp lw 2 pt 8 title "Unstaged"
