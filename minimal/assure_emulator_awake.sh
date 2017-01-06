#!/bin/bash
exec $@ | grep -q ":app:connectedDebugAndroidTest"
if [ $? == 1 ]; then
    echo "Pattern not found!"
else
    adb shell input keyevent 82
fi
