#!/usr/bin/env bats

load test_helper

. lib/utils

@test "checkenv not set" {
    FOO=foo
    unset BAR

    run checkenv BAR
    [ ! "$status" -eq 0 ]
    [ "$output" = "'BAR' is undefined" ]

    run checkenv FOO BAR
    [ ! "$status" -eq 0 ]
    [ "$output" = "'BAR' is undefined" ]
}

@test "checkenv set all" {
    FOO=foo
    BAR=bar
    result="$(checkenv FOO BAR)"
    [ -z "$result" ]
}

@test "checkenv space" {
    FOOBAR="foo bar"
    result="$(checkenv FOOBAR)"
    [ -z "$result" ]
    [ -z "$output" ]
}

@test "checkenvfile not defined" {
    fixture "checkenvfile"
    cd $FIXTURE_ROOT
    run checkenvfile FOO
    [ ! "$status" -eq 0 ]
    [ "$output" = "'FOO' is undefined" ]
}

@test "checkenvfile not created" {
    fixture "checkenvfile"
    FOO=foo
    cd $FIXTURE_ROOT
    run checkenvfile FOO
    [ ! "$status" -eq 0 ]
    [ "$output" = "'foo' is missing in working directory; aborting" ]
}

@test "checkenvfile space" {
    FOOBAR="foo bar"
    result="$(checkenv FOOBAR)"
    run checkenvfile FOOBAR
    [ ! "$status" -eq 0 ]
    [ "$output" = "'foo bar' is missing in working directory; aborting" ]
}

@test "checkenvfile created" {
    fixture "checkenvfile"
    BAR=bar
    cd $FIXTURE_ROOT
    run checkenvfile BAR
    [ "$status" -eq 0 ]
    [ -z "$result" ]
}

@test "putscancode passthru" {
    run putscancode ""
    [ "$status" -eq 0 ]
    [ "$output" = "1c 9c" ]

    run putscancode "hello world"
    [ "$status" -eq 0 ]
    [ "$output" = "23 a3 12 92 26 a6 26 a6 18 98 39 b9 11 91 18 98 13 93 26 a6 20 a0 1c 9c" ]
}

@test "runscancode default" {
    fixture "keyboardputscancode"
    export PATH=$FIXTURE_ROOT:$PATH
    VBOX_NAME=box
    run runscancode ""
    [ "$status" -eq 0 ]
    [ "${output}" = 'VBoxManage controlvm "box" keyboardputscancode 1c 9c' ]

    VBOX_SCANCODE_LIMIT=3
    run runscancode "hello"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = 'VBoxManage controlvm "box" keyboardputscancode 23 a3 12' ]
    [ "${lines[1]}" = 'VBoxManage controlvm "box" keyboardputscancode 92 26 a6' ]
}

@test "runscancode spaces" {
    fixture "keyboardputscancode"
    export PATH=$FIXTURE_ROOT:$PATH
    VBOX_NAME="f o o"
    run runscancode ""
    [ "$status" -eq 0 ]
    [ "${output}" = 'VBoxManage controlvm "f o o" keyboardputscancode 1c 9c' ]

    run runscancode "" "b b"
    [ "$status" -eq 0 ]
    [ "${output}" = 'VBoxManage controlvm "b b" keyboardputscancode 1c 9c' ]
}

@test "runscancode all arguments" {
    fixture "keyboardputscancode"
    export PATH=$FIXTURE_ROOT:$PATH
    run runscancode "hello world" foo 2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = 'VBoxManage controlvm "foo" keyboardputscancode 23 a3' ]
    [ "${lines[1]}" = 'VBoxManage controlvm "foo" keyboardputscancode 12 92' ]
}

@test "sourceconfigs base" {
    sourceconfigs base
    [ "$VBOX_DISK_SIZE" = "10000" ]
}

@test "sourceconfigs missing not found" {
    run sourceconfigs no_such_file
    [ ! "$status" -eq 0 ]
}

@test "find_vm various" {
    fixture "listvms"
    export PATH=$FIXTURE_ROOT:$PATH

    run find_vm demo
    [ ! "$status" -eq 0 ]
    [ "${lines[0]}" = "vm 'demo' not found" ]

    run find_vm 'demo v'
    [ ! "$status" -eq 0 ]
    [ "${lines[0]}" = "vm 'demo v' not found" ]

    run find_vm 'demo vm'
    [ "$status" -eq 0 ]
    run find_vm 'demo_vm'
    [ "$status" -eq 0 ]
}

@test "check_vm_running various" {
    # given that it is same output format as 'VBoxManage list vms'
    fixture "listvms"
    export PATH=$FIXTURE_ROOT:$PATH

    # not reported as not running
    run check_vm_running demo
    [ ! "$status" -eq 0 ]
    [ -z "$output" ]
    run check_vm_running 'demo v'
    [ ! "$status" -eq 0 ]

    run check_vm_running 'demo vm'
    [ "$status" -eq 0 ]
    run check_vm_running 'demo_vm'
    [ "$status" -eq 0 ]
}

@test "wait_vm_shutdown not a vm" {
    fixture "listvms"
    export PATH=$FIXTURE_ROOT:$PATH
    run wait_vm_shutdown demo
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "vm 'demo' not found" ]
}

@test "wait_vm_shutdown stayed running" {
    fixture "waitvms"
    export PATH=$FIXTURE_ROOT:$PATH
    run wait_vm_shutdown demo_vm
    [ "$status" -eq 1 ]
    [ -z "$output" ]
    # TODO check that appropriate VBoxManage calls were actually made
}
# vim: set filetype=sh:
