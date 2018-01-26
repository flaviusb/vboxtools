#!/usr/bin/env bats

load test_helper

. lib/utils

@test "checkenv not set" {
    FOO=foo
    unset BAR

    run checkenv BAR
    [ ! "$status" -eq 0 ]
    [ "$output"="BAR is unset" ]

    run checkenv FOO BAR
    [ ! "$status" -eq 0 ]
    [ "$output"="BAR is unset" ]
}

@test "checkenv set all" {
    FOO=foo
    BAR=bar
    result="$(checkenv FOO BAR)"
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

    VBOX_NAME="f o o"
    run runscancode ""
    [ "$status" -eq 0 ]
    [ "${output}" = 'VBoxManage controlvm "f o o" keyboardputscancode 1c 9c' ]
}

@test "runscancode all arguments" {
    fixture "keyboardputscancode"
    export PATH=$FIXTURE_ROOT:$PATH
    run runscancode "hello world" foo 2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = 'VBoxManage controlvm "foo" keyboardputscancode 23 a3' ]
    [ "${lines[1]}" = 'VBoxManage controlvm "foo" keyboardputscancode 12 92' ]
}

# vim: set filetype=sh: