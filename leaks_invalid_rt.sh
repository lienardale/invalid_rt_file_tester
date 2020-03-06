#!/bin/bash
rm -f test_leaks.log
cd ../
make
cd invalid_rt_file_tester
echo "Test non-exist:" >> test_leaks.log
./../miniRT srcs/error.rt | grep "leaks for" | cut -d':' -f2 >> test_leaks.log
echo '' >> test_leaks.log
echo "Test .cube:" >> test_leaks.log
./../miniRT srcs/0.cube | grep "leaks for" | cut -d':' -f2 >> test_leaks.log
i=0
while true; do
	if [[ "$i" -gt 191 ]]; then
		break
	fi
	echo '' >> test_leaks.log
	echo "Test $i:" >> test_leaks.log
	./../miniRT srcs/$i.rt | grep "leaks for" | cut -d':' -f2 >> test_leaks.log
	((i++))
done

tmp=$(diff test_leaks.log srcs/leaks_diff.log)

if [ "$tmp" == "" ] ; then
	echo -ne "\033[0;32m \xE2\x9C\x94	\033[0m"
	echo no leak gg
else
	echo -ne "\033[0;31m x	\033[0m"
	echo you leaky bastard
fi
