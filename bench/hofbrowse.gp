set output "hofbrowse.eps"
set terminal epslatex color 9
set logscale x

set key noautotitles
set xlabel "Number of files"
set ylabel "Requests per second"
set border 3
set xtics nomirror 2
set ytics nomirror 250
set yrange [0:1500]
set xrange [1.68:76]
set mxtics 0
set size 1, 1.2
set grid ytics
set key outside below reverse Left spacing 1.7

plot \
  "hofbrowsenat.dat" with lp lw 2 lt 2 title "Staged with higher-order functions (native)", \
  "browse.dat"       with lp lw 2 lt 1 title "Staged with MetaOCaml (byte code)", \
  "hofbrowse.dat"    with lp lw 2 lt 2 title "Staged with higher-order functions (byte code)", \
  "unbrowsenat.dat"  with lp lw 2 lt 4 title "Unstaged OCaml (native)"
