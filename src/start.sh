#!/bin/bash

# Simple function to extract the sheet information inBASH.  
# This function takes a raw data file and extracts the information
# as if the datas are tabularized. 

# Define header: __START_SH
# Use this header definition to include file.
if [[ $(echo -en "$__START_SH") -eq "" ]]; then 
__START_SH="1"
fi


# First order dependency: include.sh
# Dependency to grant dependency utilities
. $(dirname "$0")/src/include.sh

# Dependencies
if [[ $(echo -en $__COLORIZE_OUTPUT_SH) -eq "" ]]; then
include 'src/colorize_output.sh'
fi

if [[ $(echo -en $__PROMPT_SH) -eq "" ]]; then 
include 'src/prompt.sh'
fi

# This function creates a database from the arguments specified.
# SYNTAX: start "$TABLENAME" "$USER_COMMAND" "$DB_COMMAND", "$FILENAME"

start() {
    local TABLENAME="$1"
    local USER_COMMAND="$2"
    local DB_COMMAND="$3"
    local FILENAME="$4"

    # Procuedures
    # Create the table
    # Read the file 
    # Read line by line
    # Read by tab
    # Each tab is assigned to some indice in the table. 

    # Read the file 
    local INPUT=$(cat "$FILENAME")

    # Tracks the number of iteration happened. Used to keep different
    # cases for COUNT=1, and COUNT = others
    local COUNT=1

    # Read lines, where input seperator is \n
    while IFS=$'\n' read -r LINE; do 

        # Read tabs, where input seperator is \t
        IFS=$'\t' read -ra  WORDS <<< "$LINE"

        # Iterate the words, and
        # 1. create database if COUNT = 1 
        # 2. add row if COUNT != 1

        local COMMAND=""
        for WORD in "${WORDS[@]}"; do 
            if [[ $COUNT == 1 ]]; then
                COMMAND+="\\\"${WORD}\\\" varchar(255), "
            else
                COMMAND+="'${WORD}', "
            fi
        done 

        # Truncate the last comma
        COMMAND=$(echo $COMMAND | sed 's/,\s*$/ /')
        #echo $COMMAND

        local MAIN_COMMAND
        if [[ $COUNT == 1 ]]; then
            # CREATE the table using the specified arguments. 
            # NOTE: the default value for storing every entry is varchar(255).
            # MAIN_COMMAND="psql $USER_COMMAND $DB_COMMAND -c \"CREATE TABLE $TABLENAME (${COMMAND});\""
            MAIN_COMMAND="psql $USER_COMMAND $DB_COMMAND -c \"CREATE TABLE \\\"$TABLENAME\\\" (${COMMAND});\""
            eval $MAIN_COMMAND

        else
            # Add a row using specified arguments. 
            MAIN_COMMAND="psql $USER_COMMAND $DB_COMMAND -c \"INSERT INTO \\\"$TABLENAME\\\" VALUES  (${COMMAND});\""
            eval $MAIN_COMMAND
        fi

        # If any error occurs, immediately exit the program.
        if [[ $?  != 0 ]]; then 
            prompt --error "Terminating the program with exit code 1."
            exit 1
        fi

        let "COUNT++"
    done <<< "$INPUT"

    unset LINE
    unset WORDS
    unset WORD
}

