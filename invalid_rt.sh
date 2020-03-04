#!/bin/bash
rm -f kill.log
function run(){ 
rm -f test.log
cd ../
make
cd invalid_rt_file_tester
echo '' >> test.log
echo "Test non-exist:" >> test.log
echo "Test non-exist:" >> kill.log
./../miniRT srcs/error.rt >> test.log &
sleep 0.05
ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}' | xargs kill 1>&2
echo '' >> test.log
echo "Test .cube:" >> test.log
echo "Test .cube:" >> kill.log
./../miniRT srcs/0.cube >> test.log &
sleep 0.05
ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}' | xargs kill 1>&2
i=0
while true; do
	if [[ "$i" -gt 190 ]]; then
		exit 1
	fi
	echo '' >> test.log
	echo "Test $i:" >> test.log
	./../miniRT srcs/$i.rt >> test.log &
	sleep 0.05
	ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}' | xargs kill 1>&2
	echo "Test $i:" >> kill.log
	((i++))
done
}
run 2>> kill.log

DIFF=$(diff kill.log srcs/kill_diff.log)
echo "$DIFF"
echo | diff test.log srcs/test_diff.log
