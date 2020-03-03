#!/bin/bash
rm -f test.log
cd ../
make
cd invalid_rt_file_tester
i=0
while true; do
	if [[ "$i" -gt 190 ]]; then
		exit 1
	fi
	./../miniRT srcs/$i.rt >>test.log
	echo Test $i
	((i++))
done