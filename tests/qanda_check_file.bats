#!/usr/bin/env bats

@test "Should fail when no question declared" {
    run ./qanda.sh tests/no_question.puml

    [ "$status" -eq 30 ]
    [[ ${lines[0]} == "ERR! Can't find any question" ]]
    [[ ${lines[1]} == "ERR! Your qanda file must declare at least one question" ]]
}

@test "Should fail when no root question declared" {
    run ./qanda.sh tests/no_root_question.puml
    
    [ "$status" -eq 31 ]
    [[ ${lines[0]} == "ERR! Can't find any question to start with" ]]
    [[ ${lines[1]} == "ERR! Your qanda file must declare at least one root, like '[*] --> q1'" ]]
}

@test "Should fail when missing answer to a question" {
    run ./qanda.sh tests/no_answer.puml
    
    [ "$status" -eq 32 ]
    [[ ${lines[0]} == "ERR! Can't find any answer for question \"no_answer\" (q1)" ]]
    [[ ${lines[1]} == "ERR! Your qanda file must declare at least one answer per question 'q1 --> qX : Text' line" ]]
}
