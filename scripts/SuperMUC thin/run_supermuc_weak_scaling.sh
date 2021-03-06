# Sam(oa)² - SFCs and Adaptive Meshes for Oceanic And Other Applications
# Copyright (C) 2010 Oliver Meister, Kaveh Rahnema
# This program is licensed under the GPL, for details see the file LICENSE


#!/bin/bash

cpus=$(lscpu | grep "^CPU(s)" | grep -oE "[0-9]+" | tr "\n" " ")
output_dir=output/Thin_MPI_Weak_Scaling_$(date +"%Y-%m-%d_%H-%M-%S")
script_dir=$(dirname "$0")

mkdir -p $output_dir
mkdir -p scripts

echo "CPU(s) detected : "$cpus
echo "Output directory: "$output_dir
echo ""
echo "Compiling..."

scons config=supermuc.py scenario=darcy openmp=noomp -j4 &
scons config=supermuc.py scenario=swe openmp=noomp -j4 &

wait %1 %2

echo "Running scenarios..."

limit=00:10:00
postfix=_noomp

for asagimode in 2
do
	for sections in 16
	do
		for concurrency in 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192
		do
			processes=$concurrency
			threads=1
			nodes=$(( ($processes * $threads - 1) / 16 + 1 ))
			size=`echo "import numpy; print int(numpy.log2("$concurrency"))" | python`

			if [ $nodes -le 32 ]; then
               class=test
            else
               class=general
            fi

			script="scripts/cache/run_thin"$postfix"_p"$processes"_t"$threads"_s"$sections"_a"$asagimode".sh"
			cat "$script_dir/run_supermuc_template.sh" > $script

			sed -i 's=$asagimode='$asagimode'=g' $script
			sed -i 's=$sections='$sections'=g' $script
			sed -i 's=$processes='$processes'=g' $script
			sed -i 's=$threads='$threads'=g' $script
			sed -i 's=$output_dir='$output_dir'=g' $script
			sed -i 's=$nodes='$nodes'=g' $script
			sed -i 's=$limit='$limit'=g' $script
			sed -i 's=$class='$class'=g' $script
			sed -i 's=$postfix='$postfix'=g' $script
			sed -i 's=-dmin 26=-dmin '$((20 + size))'=g' $script
			sed -i 's=-dmax 29=-dmax '$((26 + size))'=g' $script

			llsubmit $script
		done
	done
done

