#!/bin/bash
rm -f test_leaks.log
cd ../
make
cd invalid_rt_file_tester

echo "Test no arg:" >> test_leaks.log
./../miniRT | grep "leaks for" | cut -d':' -f2 >> test_leaks.log

echo '' >> test_leaks.log
echo "Test non-exist0:" >> test_leaks.log
./../miniRT srcs/error.rt | grep "leaks for" | cut -d':' -f2 >> test_leaks.log

echo '' >> test_leaks.log
echo "Test non-exist0:" >> test_leaks.log
./../miniRT srcs/error | grep "leaks for" | cut -d':' -f2 >> test_leaks.log

echo '' >> test_leaks.log
echo "Test multi-arg0:" >> test_leaks.log
./../miniRT srcs/objects.rt srcs/objects.rt | grep "leaks for" | cut -d':' -f2 >> test_leaks.log

echo '' >> test_leaks.log
echo "Test multi-arg1:" >> test_leaks.log
./../miniRT srcs/objects.rt srcs/objects.rt srcs/objects.rt | grep "leaks for" | cut -d':' -f2 >> test_leaks.log

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
	echo -e "\033[0;32mno leaks gg\033[0m"
else
	echo -ne "\033[0;31m x	\033[0m"
	echo -e "\033[0;31myou leaky bastard\033[0m"
	echo -e "\033[0;31mcheck test_leaks.log for details\033[0m"
	echo ''
	echo -e "\033[0;31mif you haven't, RTFM\033[0m"
fi
