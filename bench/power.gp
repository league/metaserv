set output "power.eps"
set terminal epslatex color 
set logscale x

set key noautotitles
set xlabel "Exponent (2\\textsuperscript{\\textit x})"
set ylabel "Requests per second" 
set border 3
set xtics nomirror (127, 255, 511, 1023, 2047, 4095, 8191)
set xrange [108:9742]
set ytics nomirror 250
set yrange [0:1500]
set mxtics 0
set nozeroaxis
set size 1,1.2
set grid ytics
set key outside below reverse Left spacing 1.7

plot \
 "hofpowernat.dat" with lp lw 2 lt 2 title "Staged with higher-order functions (native)", \
 "powerunnat.dat"  with lp lw 2 lt 4 title "Unstaged (native)", \
 "power.dat"       with lp lw 2 lt 1 title "Staged with MetaOCaml (byte code)", \
 "hofpower.dat"    with lp lw 2 lt 2 title "Staged with higher-order functions (byte code)", \
 "powerun.dat"     with lp lw 2 lt 4 title "Unstaged (byte code)"
