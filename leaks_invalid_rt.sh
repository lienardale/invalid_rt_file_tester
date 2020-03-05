#!/bin/bash
function run(){ 
rm -f test_leaks.log
cd ../
make
cd invalid_rt_file_tester
echo "Test non-exist:" >> test_leaks.log
./../miniRT srcs/error.rt | grep "leaks for" >> test_leaks.log
echo '' >> test_leaks.log
echo "Test .cube:" >> test_leaks.log
./../miniRT srcs/0.cube | grep "leaks for" >> test_leaks.log
i=0
while true; do
	if [[ "$i" -gt 190 ]]; then
		exit 1
	fi
	echo '' >> test_leaks.log
	echo "Test $i:" >> test_leaks.log
	./../miniRT srcs/$i.rt | grep "leaks for" >> test_leaks.log
	((i++))
done
}
run 

