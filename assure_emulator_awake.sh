#!/usr/bin/expect -f

set timeout 1800
set cmd [lindex $argv 0]

spawn {*}$cmd
expect {
  -re "^(.)*:app:connectedDebugAndroidTest$" {
    exec adb shell input keyevent 82
    exp_continue
  }
  eof
}
catch wait reason
exit [lindex $reason 3]
