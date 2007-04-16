set output "browse.eps"
set terminal epslatex 
set logscale x

set key noautotitles
set xlabel "Number of files"
set ylabel "Requests per second" 0.8
set border 3
set xtics nomirror 2
set ytics nomirror 200
set xrange [1.68:76]
set mxtics 0
set size .68,.85
set grid ytics
set key outside below reverse Left

plot \
  "browse.dat"       with lp lw 2 title "Staged MetaOCaml", \
  "browse-php.dat"   with lp lw 2 title "Staged PHP", \
  "unbrowse.dat"     with lp lw 2 title "Unstaged MetaOCaml", \
  "unbrowse-php.dat" with lp lw 2 title "Unstaged PHP"

#     "browse-apache.dat" with lp lw 2 title "*Apache", \
