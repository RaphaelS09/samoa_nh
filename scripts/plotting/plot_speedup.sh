# Sam(oa)² - SFCs and Adaptive Meshes for Oceanic And Other Applications
# Copyright (C) 2010 Oliver Meister, Kaveh Rahnema
# This program is licensed under the GPL, for details see the file LICENSE


#!/bin/bash
echo "Plotting results..."

cd $1

rm -f darcy*.plt swe*.plt

for file in darcy*.log ; do
	flags=$(echo $file | grep -oE "(_no[a-zA-Z0-9]+)+")
	processes=$(echo $file | grep -oE "_p[0-9]+" | grep -oE "[0-9]+")
	threads=$(echo $file | grep -oE "_t[0-9]+" | grep -oE "[0-9]+")
	sections=$(echo $file | grep -oE "_s[0-9]+" | grep -oE "[0-9]+")

	processes=${processes:-1}
	threads=${threads:-1}
	sections=${sections:-1}

    csplit $file "/Phase statistics:/" {*} &>/dev/null

    i=0
    for phase in xx* ; do
	    echo -n $processes $threads $sections" " >> "darcy"$i".plt"
	    grep -E "r0.*Element throughput" $phase | grep -oE "[0-9]+\.[0-9]+" | tr "\n" " " | cat >> "darcy"$i".plt"
	    echo "" >> "darcy"$i".plt"

        i=$(( $i + 1 ))
    done

    rm -f xx*
done

for file in swe*.log ; do
	flags=$(echo $file | grep -oE "(_no[a-zA-Z0-9]+)+")
	processes=$(echo $file | grep -oE "_p[0-9]+" | grep -oE "[0-9]+")
	threads=$(echo $file | grep -oE "_t[0-9]+" | grep -oE "[0-9]+")
	sections=$(echo $file | grep -oE "_s[0-9]+" | grep -oE "[0-9]+")
	
	processes=${processes:-1}
	threads=${threads:-1}
	sections=${sections:-1}

    csplit $file "/Phase statistics:/" {*} &>/dev/null

    i=0
    for phase in xx* ; do
	    echo -n $processes $threads $sections" "  >> "swe"$i".plt"
	    grep -E "r0.*Element throughput" $phase | grep -oE "[0-9]+\.[0-9]+" | tr "\n" " " | cat >> "swe"$i".plt"
	    echo ""  >> "swe"$i".plt"

        i=$(( $i + 1 ))
    done

    rm -f xx*
done


i=0
for phase in darcy*.plt ; do
    sort -t" " -n -k 3,3 -k 1,1 -k 2,2 $phase -o $phase
    i=$(( $i + 1 ))
done

i=0
for phase in swe*.plt ; do
    sort -t" " -n -k 3,3 -k 1,1 -k 2,2 $phase -o $phase

    i=$(( $i + 1 ))
done

gnuplot &>/dev/null << EOT

set terminal postscript enhanced color font ',30'
set xlabel "Cores"
set ylabel "Mio. Elements per sec."
set key left top

title(n) = sprintf("%d section(s)", n)

set style line 999 lt 2 lw 8 lc rgb "black"

set for [n=1:64] style line n lt 1 lw 8
set style line 1 lc rgb "cyan"
set style line 2 lc rgb "orange"
set style line 4 lc rgb "magenta"
set style line 8 lc rgb "red"
set style line 16 lc rgb "blue"
set style line 32 lc rgb "green"

#*******
# Darcy
#*******

do for [i=1:20] {
    infile = sprintf('darcy%i.plt', i)
    set title 'Darcy element througput'

    unset output
    set xrange [0:*]
    set yrange [0:*]

    plot for [n=1:64] infile u (\$1*\$2):(\$3 == n ? \$4 : 1/0) ls n w linespoints t title(n)

    outfile = sprintf('| ps2pdf - darcy%i_lin.pdf', i)
    set output outfile

    set xtics GPVAL_DATA_X_MAX/8
    replot GPVAL_DATA_Y_MIN / GPVAL_DATA_X_MIN * x w lines ls 999 title "reference"
}

#*****
# SWE
#*****

do for [i=1:20] {
    infile = sprintf('swe%i.plt', i)
    set title 'SWE element througput'

    unset output
    set xrange [0:*]
    set yrange [0:*]

    plot for [n=1:64] infile u (\$1*\$2):(\$3 == n? \$4 : 1/0) ls n w linespoints t title(n)

    outfile = sprintf('| ps2pdf - swe%i_lin.pdf', i)
    set output outfile

    set xtics GPVAL_DATA_X_MAX/8
    replot GPVAL_DATA_Y_MIN / GPVAL_DATA_X_MIN * x w lines ls 999 title "reference"
}

EOT
