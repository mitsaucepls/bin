#!/usr/bin/env bash

device="8C:CD:E8:B7:B8:68"

/usr/bin/expect <(
cat<<EOF
set timeout 50
spawn bluetoothctl

# Try to remove the device if it's already paired
send -- "remove $device\r"
expect {
    "not available" {
        send_user "The device was not available for removal. Continuing...\n"
    }
    "Device has been removed" {
        send_user "Device removed. Continuing...\n"
    }
    timeout {
        send_user "Timeout while trying to remove the device. Continuing...\n"
    }
}

# Start scanning to find the device
send -- "scan on\r"
expect {
    "$device" {
        send -- "pair $device\r"
        expect "Pairing successful"
        send -- "connect $device\r"
        expect "Connection successful"
        send -- "trust $device\r"
        expect "trust succeeded"
        send -- "scan off\r"
    }
    timeout {
        send_user "The device was not found during scanning.\n"
        send -- "exit\r"
        expect eof
        exit 1
    }
}

# Exit bluetoothctl
send -- "exit\r"
expect eof
EOF
)
