#!/usr/bin/env bats

@test "Should fail when no argument is set" {
    run ./qanda.sh

    [ "$status" -eq 20 ]
    [ "${output}" == "ERR! Q&A source file missing as argument" ]
}

@test "Should fail when the qanda file don't exists" {
    run ./qanda.sh unknown_file.puml

    [ "$status" -eq 21 ]
    [ "${output}" == "ERR! Q&A source file 'unknown_file.puml' don't exists" ]
}

@test "Should fail when the qanda file is not a plantuml file" {
    run ./qanda.sh tests/not_a_puml_file

    [ "$status" -eq 22 ]
    [ "${output}" == "ERR! Q&A source file 'tests/not_a_puml_file' is not a plantuml file (fileext: .puml)" ]
}
