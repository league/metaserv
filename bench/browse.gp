set output "browse.eps"
set terminal epslatex color 
set logscale x

set key noautotitles
set xlabel "Number of files"
set ylabel "Requests per second" 0.8
set border 3
set xtics nomirror 2
set ytics nomirror 200
set xrange [1.68:76]
set mxtics 0
set size .68,.60
set grid ytics
set key 39,1000 box

plot "browse.dat"   with lp lw 2 pt 6 title "Staged", \
     "unbrowse.dat" with lp lw 2 pt 8 title "Unstaged", \
     "browse-apache.dat" with lp lw 2 pt 7 lt 4 title "*Apache"
