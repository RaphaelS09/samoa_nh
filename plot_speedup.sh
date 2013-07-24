# Sam(oa)² - SFCs and Adaptive Meshes for Oceanic And Other Applications
# Copyright (C) 2010 Oliver Meister, Kaveh Rahnema
# This program is licensed under the GPL, for details see the file LICENSE


#!/bin/bash
echo "Plotting results..."

cd $1

echo "#Element throughput by sections and threads" > "darcy.plt"
echo "#Threads ET per (initialization, time steps) per sections" >> "darcy.plt"

for file in darcy*.log; do
	processes=$(echo $file | grep -oE "_p[0-9]+" | grep -oE "[0-9]+")
	threads=$(echo $file | grep -oE "_t[0-9]+" | grep -oE "[0-9]+")
	sections=$(echo $file | grep -oE "_s[0-9]+" | grep -oE "[0-9]+")

	processes=${processes:-1}
	threads=${threads:-1}
	sections=${sections:-1}

	echo -n $processes $threads $sections" " >> "darcy.plt"
	grep -E "r0.*Element throughput" $file | grep -oE "[0-9]+\.[0-9]+" | tr "\n" " " | cat >> "darcy.plt"
	echo "" >> "darcy.plt"
done


echo "#Cell update throughput and flux solver throughput by sections and threads" > "swe.plt"
echo "#Threads CUT FST per sections" >> "swe.plt"

for file in swe*.log; do
	processes=$(echo $file | grep -oE "_p[0-9]+" | grep -oE "[0-9]+")
	threads=$(echo $file | grep -oE "_t[0-9]+" | grep -oE "[0-9]+")
	sections=$(echo $file | grep -oE "_s[0-9]+" | grep -oE "[0-9]+")
	
	processes=${processes:-1}
	threads=${threads:-1}
	sections=${sections:-1}

	echo -n $processes $threads $sections" "  >> "swe.plt"
	    
	grep -E "r0.*Cell update throughput" $file | grep -oE "[0-9]+\.[0-9]+" | tr "\n" " " | cat >> "swe.plt"
	grep -E "r0.*Flux solver throughput" $file | grep -oE "[0-9]+\.[0-9]+" | tr "\n" " " | cat >> "swe.plt"
	echo ""  >> "swe.plt"
done

gnuplot &> /dev/null << EOT

set terminal postscript enhanced color
set xlabel "concurrency"
set ylabel "M/s"

title(n) = sprintf("%d section(s)", n)

p(x) = x / (b * (x + a))
r(x) = x / (a * b)
u(x) = 1 / b

#*******
# Darcy
#*******

set title "Darcy element throughput - initialization"
unset output
set xrange [0:*]
set yrange [0:*]

fit p(x) "darcy.plt" u (\$1*\$2):4 via a, b

plot for [n=1:64] "darcy.plt" u (\$1*\$2):(\$3 == n ? \$4 : 1/0) w points t title(n) lw 4

set output '| ps2pdf - darcy_elem_init.pdf'
set xrange [0:GPVAL_X_MAX]

replot p(x) w lines lt 1 lc 0 lw 4 title "regression",  \
	GPVAL_DATA_Y_MIN / GPVAL_DATA_X_MIN * x w lines lt 1 lc 1 lw 4 title "reference"

#********

set title "Darcy element throughput - time steps"
unset output
set xrange [0:*]
set yrange [0:*]
fit p(x) "darcy.plt" u (\$1*\$2):5 via a, b

plot for [n=1:64] "darcy.plt" u (\$1*\$2):(\$3 == n ? \$5 : 1/0) w points t title(n) lw 4
		
set output '| ps2pdf - darcy_elem.pdf'
set xrange [0:GPVAL_X_MAX]

replot p(x) w lines lt 1 lc 0 lw 4 title "regression",  \
	GPVAL_DATA_Y_MIN / GPVAL_DATA_X_MIN * x w lines lt 1 lc 1 lw 4 title "reference"

#*****
# SWE
#*****

set title "SWE flux solver throughput"
unset output
set xrange [0:*]
set yrange [0:*]
fit p(x) "swe.plt" u (\$1*\$2):5 via a, b

plot for [n=1:64] "swe.plt" u (\$1*\$2):(\$3 == n ? \$5 : 1/0) w points t title(n) lw 4

set output '| ps2pdf - swe_flux.pdf'
set xrange [0:GPVAL_X_MAX]

replot p(x) w lines lt 1 lc 0 lw 4 title "regression",  \
	GPVAL_DATA_Y_MIN / GPVAL_DATA_X_MIN * x w lines lt 1 lc 1 lw 4 title "reference"


#********

set title "SWE cell update throughput"
unset output
set xrange [0:*]
set yrange [0:*]
fit p(x) "swe.plt" u (\$1*\$2):4 via a, b

plot for [n=1:64] "swe.plt" u (\$1*\$2):(\$3 == n ? \$4 : 1/0) w points t title(n) lw 4

set output '| ps2pdf - swe_cells.pdf'
set xrange [0:GPVAL_X_MAX]

replot p(x) w lines lt 1 lc 0 lw 4 title "regression",  \
	GPVAL_DATA_Y_MIN / GPVAL_DATA_X_MIN * x w lines lt 1 lc 1 lw 4 title "reference"


EOT
