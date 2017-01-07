#!/usr/bin/expect -f

set timeout 1800
set cmd [lindex $argv 0]

spawn {*}$cmd
expect -re "^:app:connectedDebugAndroidTest$"
set temp $spawn_id
  spawn ./test1.sh
  catch wait reason
  if { [lindex $reason 3] != 0} {
      puts "Problem with spawned proccess";
  }
set spawn_id $temp
catch wait reason
exit [lindex $reason 3]
