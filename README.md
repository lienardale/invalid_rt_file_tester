# invalid_rt_file_tester

clone the repository at the root of your miniRT without giving it a different name

use "bash invalid_rt.sh"

check the kill.log file, if there are only "Test 0:" lines, it means the test passed

if there are lines looking like "invalid_rt.sh: line 3: 16740 Terminated: 15          ./../miniRT srcs/$i.rt >> test.log"
it means a window was open, and that the mini_RT treated an invalid file as a valid one

if there are no such lines, you can add "system("leaks miniRT");" before all the exits commands of the mini_RT
then run "bash leaks_invalid_rt.sh" and check the "test_leaks.log" file

if you want to see the error messages the mini_RT outputed, look into the "test.log" file


