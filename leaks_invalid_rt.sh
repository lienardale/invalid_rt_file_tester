#!/bin/bash
rm -f kill.log
rm -f test.log
rm -f leaks.log
cd ../
make 2>>/dev/null
cd invalid_rt_file_tester

RIGHT="✅"
WRONG="❌"

function run(){ 

	echo "Test no arg:" >> test.log
	echo "Test no arg:" >> kill.log
	echo "Test no arg:" >> leaks.log
	valgrind ./../miniRT 2>&1 | grep "no leaks are possible" >> leaks.log &
	sleep 0.7
	PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
	echo -n "Test no arg:"
	if [ $PID ]
	then
		kill $PID 1>&2
		echo $WRONG >> kill.log
		echo $WRONG
	else
		echo $RIGHT
		# echo "\033[0;32m \xE2\x9C\x94	\033[0m"
	fi


	echo "Test non-exist0:" >> test.log
	echo "Test non-exist0:" >> kill.log
	echo "Test non-exist0:" >> leaks.log
	valgrind ./../miniRT srcs/error.rt 2>&1 | grep "no leaks are possible" >> leaks.log &
	sleep 0.7
	PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
	echo -n "Test non-exist0:"
	if [ $PID ]
	then
		kill $PID 1>&2
		echo $WRONG >> kill.log
		echo $WRONG
	else
		echo $RIGHT
		# echo "\033[0;32m \xE2\x9C\x94	\033[0m"
	fi

	echo "Test non-exist1:" >> test.log
	echo "Test non-exist1:" >> kill.log
	echo "Test non-exist0:" >> leaks.log
	valgrind ./../miniRT srcs/error 2>&1 | grep "no leaks are possible" >> leaks.log &
	sleep 0.7
	PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
	echo -n "Test non-exist1:"
	if [ $PID ]
	then
		kill $PID 1>&2
		echo $WRONG >> kill.log
		echo $WRONG
	else
		echo $RIGHT
		# echo "\033[0;32m \xE2\x9C\x94	\033[0m"
	fi

	echo "Test multi-arg0:" >> test.log
	echo "Test multi-arg0:" >> kill.log
	echo "Test multi-arg0:" >> leaks.log
	valgrind ./../miniRT srcs/objects.rt srcs/objects.rt 2>&1 | grep "no leaks are possible" >> leaks.log &
	sleep 0.7
	PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
	echo -n "Test multi-arg0:"
	if [ $PID ]
	then
		kill $PID 1>&2
		echo $WRONG >> kill.log
		echo $WRONG
	else
		echo $RIGHT
		# echo "\033[0;32m \xE2\x9C\x94	\033[0m"
	fi

	echo "Test multi-arg1:" 2>&1 >> test.log
	echo "Test multi-arg1:" >> kill.log
	echo "Test multi-arg1:" >> leaks.log
	valgrind ./../miniRT srcs/objects.rt srcs/objects.rt srcs/objects.rt 2>&1 | grep "no leaks are possible" >> leaks.log &
	sleep 0.7
	PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
	echo -n "Test multi-arg1:"
	if [ $PID ]
	then
		kill $PID 1>&2
		echo $WRONG >> kill.log
		echo $WRONG
	else
		echo $RIGHT
		# echo "\033[0;32m \xE2\x9C\x94	\033[0m"
	fi

	echo '' >> test.log
	echo "Test .cube:" >> test.log
	echo "Test .cube:" >> kill.log
	echo "Test .cube:" >> leaks.log
	valgrind ./../miniRT srcs/0.cube 2>&1 | grep "no leaks are possible" >> leaks.log &
	sleep 0.7
	PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
	echo -n "Test .cube:"
	if [ $PID ]
	then
		kill $PID 1>&2
		echo $WRONG >> kill.log
		echo $WRONG
	else
		echo $RIGHT
		# echo "\033[0;32m \xE2\x9C\x94	\033[0m"
	fi
	i=0
	while true; do
		if [[ "$i" -gt 191 ]]; then
			break
		fi
		echo '' >> test.log
		echo "Test $i:" >> test.log
		echo "Test $i:" >> kill.log
		echo -n "Test $i:" >> leaks.log
		echo -n "Test $i:"
		LEAKS=$(valgrind --leak-check=full --show-leak-kinds=all ./../miniRT srcs/$i.rt 2>&1 | grep "no leaks are possible")
		sleep 0.6
		echo $LEAKS >> leaks.log
		PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
		if [ $PID ]
		then
			kill $PID 1>&2
			echo $WRONG >> kill.log
			echo $WRONG
		else
			if [ !$LEAKS ]
			then
				echo $WRONG >> leaks.log
				echo $WRONG
			else
				echo $RIGHT >> leaks.log
				echo $RIGHT
			fi
			# echo "\033[0;32m \xE2\x9C\x94	\033[0m"
		fi
		((i++))
	done
}
run 2>> kill.log

DIFF=$(diff kill.log srcs/kill_diff.log)
if [ "$DIFF" == "" ] ; then
	echo -e "\033[0;32m[OK]\033[0m"
	echo -e "\033[0;32mNo errors, gg.\033[0m"
	echo -e "\033[0;32mCheck test.log to see if the error messages are explicit.\033[0m"
else
	echo -e "\033[0;31m[KO]\033[0m"
	echo ''
	echo -e "\033[0;31mErrors, check kill.log, re-run if suspicious or if some lines look like 'kill: 35686: No such process'.\033[0m"
	echo ''
	echo -e "\033[0;31mIf the person tells you the tester is wrong, run a few test manually.\033[0m"
	echo ''
	echo -e "\033[0;31mIf they are slow, but you do not see a window opening, they are right.\033[0m"
	echo -e "\033[0;31mElse, they're wrong, put them a 0 and tell them to come fight me.\033[0m"
	echo ''
	echo -e "\033[0;31mIf you haven't, RTFM.\033[0m"
fi
