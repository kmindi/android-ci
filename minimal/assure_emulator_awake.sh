#!/usr/bin/expect -f

set timeout 1800
set cmd [lindex $argv 0]

spawn {*}$cmd
expect {
  -re "^:app:connectedDebugAndroidTest$" {
        set temp $spawn_id
        spawn adb shell input keyevent 82
        set spawn_id $temp
        exp_continue
  }
  eof
}
catch wait reason
exit [lindex $reason 3]
