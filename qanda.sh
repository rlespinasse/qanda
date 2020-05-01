#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

command -v fzf >/dev/null 2>&1 || {
    echo >&2 "ERR! I require fzf but it's not installed.  Aborting."
    exit 10
}
command -v grep >/dev/null 2>&1 || {
    echo >&2 "ERR! I require grep but it's not installed.  Aborting."
    exit 11
}
command -v sed >/dev/null 2>&1 || {
    echo >&2 "ERR! I require sed but it's not installed.  Aborting."
    exit 12
}

qanda=${1:-}

asked_question=0

check_args() {
    if [ -z "$qanda" ]; then
        echo "ERR! Q&A source file missing as argument"
        exit 20
    elif [ ! -f "$qanda" ]; then
        echo "ERR! Q&A source file '$qanda' don't exists"
        exit 21
    elif [[ ! "$qanda" == *".puml" ]]; then
        echo "ERR! Q&A source file '$qanda' is not a plantuml file (fileext: .puml)"
        exit 22
    fi
}

check_file() {
    # Verify that at least one question is declared
    if [ -z "$(get_questions_data)" ]; then
        echo >&2 "ERR! Can't find any question"
        echo >&2 "ERR! Your qanda file must declare at least one question"
        exit 30
    fi

    # Verify that at least one root questions is declared
    if [ -z "$(get_root_question_ids)" ]; then
        echo >&2 "ERR! Can't find any question to start with"
        echo >&2 "ERR! Your qanda file must declare at least one root, like '[*] --> $(get_questions_data | head -n 1 | sed 's/:.*//')'"
        exit 31
    fi

    # Verify that all questions have declared at least one answer
    while IFS=":" read -r id text; do
        if [ -z "$(get_answers_by_question_id "$id")" ]; then
            echo >&2 "ERR! Can't find any answer for question \"$text\" ($id)"
            echo >&2 "ERR! Your qanda file must declare at least one answer per question '$id --> qX : Text' line"
            exit 32
        fi
    done < <(get_questions_data)
}

get_questions_data() {
    grep '^state' "$qanda" | sed 's/^state "\(.*\)" as \(.*\)$/\2:\1/'
}

get_question_tasks_by_id() {
    local id="$1"
    grep "^$id\s*:" "$qanda" | sed "s/^${id}[^:]*:\s*//"
}

get_answers_by_question_id() {
    local id="$1"
    grep "^$id\s.*-*>.*:" "$qanda" | sed 's/^.*>[^:]*:*//'
}

get_question_by_id() {
    local id="$1"
    get_questions_data | grep "^$id:" | sed 's/^.*://'
}

find_questions_by_id() {
    while read -r data; do
        get_question_by_id "$data"
    done
}

get_question_by_answer() {
    local question="$1"
    local answer="$2"
    grep "^$question " "$qanda" | grep "$answer$" | sed 's/^.*>//;s/:.*$//;s/\s*//g'
}

get_question_by_text() {
    local text="$1"
    get_questions_data | grep ":$text$" | sed 's/:.*$//'
}

find_questions_by_text() {
    while read -r data; do
        get_question_by_text "$data"
    done
}

get_root_question_ids() {
    grep '^\[\*\]' "$qanda" | sed 's/.*>\s*\(.*\)$/\1/'
}

ask_questions() {
    while read -r data; do
        ask_question "$data"
    done
}

ask_root_question() {
    get_root_question_ids |
        find_questions_by_id |
        fzf -1 --cycle --header="What is the question you want to be ask?" |
        find_questions_by_text |
        ask_questions
}

print_answer() {
    local id="$1"
    local answer="$2"
    while read -r possible_answer; do
        if [ "$possible_answer" == "$answer" ]; then
            printf "  [X] %s\n" "$possible_answer"
        else
            printf "  [ ] %s\n" "$possible_answer"
        fi
    done < <(get_answers_by_question_id "$id")
    printf "\n"
}

ask_question() {
    local id="$1"
    asked_question=$((asked_question + 1))

    if [ -z "$id" ]; then
        ask_root_question
    elif [ "$id" == "[*]" ]; then
        return
    fi

    local question_text
    local question_content
    local header_size
    local answer

    question_content=()
    header_size=0
    while read -r task; do
        if [ "$header_size" == "0" ]; then
            printf "Tasks %s\n" "${asked_question}"
            question_content+=("Tasks")
            header_size=$((header_size + 1))
        fi

        printf "%s %s\n" "└─" "$task"
        question_content+=("└─ $task")
        header_size=$((header_size + 1))
    done < <(get_question_tasks_by_id "$id")

    if [ ! "$header_size" == "0" ]; then
        printf "\n"
        question_content+=(" ")
        header_size=$((header_size + 1))
    fi

    question_text="$(get_question_by_id "$id")"
    printf "Question ${asked_question}\n> %s?\n" "$question_text"
    question_content+=("Question ${asked_question}" "> ${question_text}?")
    header_size=$((header_size + 2))

    while read -r possible_answer; do
        question_content+=("$possible_answer")
    done < <(get_answers_by_question_id "$id")

    answer=$(printf -- "%s" "${question_content[*]}" | fzf --cycle --header-lines="$header_size")
    print_answer "$id" "$answer"
    ask_question "$(get_question_by_answer "$id" "$answer")"
}

check_args
check_file
ask_root_question
