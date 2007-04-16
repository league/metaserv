set output "browse.eps"
set terminal epslatex color 
set logscale x

set key noautotitles
set xlabel "Number of files"
set ylabel "Requests per second"
set border 3
set xtics nomirror 2
set ytics nomirror 100
set xrange [2:64]
set mxtics 0
set size .68,.60
set grid ytics
set key 38,320 width 2

plot "browse.dat"   with lp lw 2 pt 6 title "Staged", \
     "unbrowse.dat" with lp lw 2 pt 8 title "Unstaged"
