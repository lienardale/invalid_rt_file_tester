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

	echo "Test no arg:" >> kill.log
	echo "Test no arg:" >> leaks.log
	LEAKS=$(valgrind --leak-check=full --show-leak-kinds=all ./../miniRT 2>&1 | grep "no leaks are possible")
	sleep 0.6
	echo $LEAKS >> leaks.log
	PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
	echo -n "Test no arg:"
	if [ $PID ]
	then
		kill $PID 1>&2
		echo $WRONG >> kill.log
		echo $WRONG
	else
		if [ -z "$LEAKS" ]
		then
			echo $WRONG >> leaks.log
			echo -ne $WRONG
		else
			echo $RIGHT >> leaks.log
			echo -ne $RIGHT
		fi
	fi

	echo "Test non-exist0:" >> kill.log
	echo "Test non-exist0:" >> leaks.log
	LEAKS=$(valgrind --leak-check=full --show-leak-kinds=all ./../miniRT srcs/error.rt 2>&1 | grep "no leaks are possible")
	sleep 0.6
	echo $LEAKS >> leaks.log
	PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
	echo -n "Test non-exist0:"
	if [ $PID ]
	then
		kill $PID 1>&2
		echo $WRONG >> kill.log
		echo $WRONG
	else
		if [ -z "$LEAKS" ]
		then
			echo $WRONG >> leaks.log
			echo -ne $WRONG
		else
			echo $RIGHT >> leaks.log
			echo -ne $RIGHT
		fi
	fi

	echo "Test non-exist1:" >> kill.log
	echo "Test non-exist1:" >> leaks.log
	LEAKS=$(valgrind --leak-check=full --show-leak-kinds=all ./../miniRT srcs/error 2>&1 | grep "no leaks are possible")
	sleep 0.6
	echo $LEAKS >> leaks.log
	PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
	echo -n "Test non-exist1:"
	if [ $PID ]
	then
		kill $PID 1>&2
		echo $WRONG >> kill.log
		echo $WRONG
	else
		if [ -z "$LEAKS" ]
		then
			echo $WRONG >> leaks.log
			echo -ne $WRONG
		else
			echo $RIGHT >> leaks.log
			echo -ne $RIGHT
		fi
	fi

	echo "Test multi-arg0:" >> kill.log
	echo "Test multi-arg0:" >> leaks.log
	LEAKS=$(valgrind --leak-check=full --show-leak-kinds=all ./../miniRT srcs/objects.rt srcs/objects.rt 2>&1 | grep "no leaks are possible")
	sleep 0.6
	echo $LEAKS >> leaks.log
	PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
	echo -n "Test multi-arg0:"
	if [ $PID ]
	then
		kill $PID 1>&2
		echo $WRONG >> kill.log
		echo $WRONG
	else
		if [ -z "$LEAKS" ]
		then
			echo $WRONG >> leaks.log
			echo -ne $WRONG
		else
			echo $RIGHT >> leaks.log
			echo -ne $RIGHT
		fi
	fi

	echo "Test multi-arg1:" >> kill.log
	echo "Test multi-arg1:" >> leaks.log
	LEAKS=$(valgrind --leak-check=full --show-leak-kinds=all ./../miniRT srcs/objects.rt srcs/objects.rt srcs/objects.rt 2>&1 | grep "no leaks are possible")
	sleep 0.6
	echo $LEAKS >> leaks.log
	PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
	echo -n "Test multi-arg1:"
	if [ $PID ]
	then
		kill $PID 1>&2
		echo $WRONG >> kill.log
		echo $WRONG
	else
		if [ -z "$LEAKS" ]
		then
			echo $WRONG >> leaks.log
			echo -ne $WRONG
		else
			echo $RIGHT >> leaks.log
			echo -ne $RIGHT
		fi
	fi

	echo "Test .cube:" >> kill.log
	echo "Test .cube:" >> leaks.log
	LEAKS=$(valgrind --leak-check=full --show-leak-kinds=all ./../miniRT srcs/0.cube 2>&1 | grep "no leaks are possible")
	sleep 0.6
	echo $LEAKS >> leaks.log
	PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
	echo -n "Test .cube:"
	if [ $PID ]
	then
		kill $PID 1>&2
		echo $WRONG >> kill.log
		echo $WRONG
	else
		if [ -z "$LEAKS" ]
		then
			echo $WRONG >> leaks.log
			echo -ne $WRONG
		else
			echo $RIGHT >> leaks.log
			echo -ne $RIGHT
		fi
	fi
	i=0
	while true; do
		if [[ "$i" -gt 191 ]]; then
			break
		fi
		if ! (("$i" % 10)) ; then
			echo
		fi

		echo "Test $i:" >> kill.log
		echo -n "Test $i:" >> leaks.log
		LEAKS=$(valgrind --leak-check=full --show-leak-kinds=all ./../miniRT srcs/$i.rt 2>&1 | grep "no leaks are possible")
		sleep 0.6
		echo $LEAKS >> leaks.log
		PID=$(ps -ef | grep "miniRT" | grep -v 'grep' | awk '{print $2}')
		echo -ne " $i:"
		if [ $PID ]
		then
			kill $PID 1>&2
			echo $WRONG >> kill.log
			echo -ne $WRONG
		else
			if [ -z "$LEAKS" ]
			then
				echo $WRONG >> leaks.log
				echo -ne $WRONG
			else
				echo $RIGHT >> leaks.log
				echo -ne $RIGHT
			fi
		fi
		((i++))
	done
}

echo -e "\033[0;31m[DISCLAIMER]\nThis script tests leaks with a strict interpretation of memory leaks.\n
i.e. that 'still reachables' are not acceptable in this project's scope.\n
You can debate this choice during correction if you do not agree.\033[0m"

run 2>> kill.log

DIFF=$(diff kill.log srcs/kill_diff.log)
if [ "$DIFF" == "" ] ; then
	echo -e "\033[0;32m[OK]\033[0m"
	echo -e "\033[0;32mNo errors, gg.\033[0m"
else
	echo -e "\033[0;31m[KO]\033[0m"
	echo ''
	echo -e "\033[0;31mErrors, check kill.log + leaks.log, re-run if suspicious or if some lines look like 'kill: 35686: No such process'.\033[0m"
	echo ''
	echo -e "\033[0;31mIf the person tells you the tester is wrong, run a few test manually.\033[0m"
	echo ''
	echo -e "\033[0;31mIf they are slow, but you do not see a window opening, they are right.\033[0m"
	echo -e "\033[0;31mElse, they're wrong, you can grade the project 0.\033[0m"
	echo ''
	echo -e "\033[0;31mIf you haven't, RTFM.\033[0m"
fi
