#!/bin/bash

# Simple file to extract the sheet information in
# BASH

# First order dependency: include.sh
. $(dirname "$0")/src/include.sh

# Dependencie(s)

if [[ $(echo -en $__COLORIZE_OUTPUT_SH) -eq "" ]]; then
include 'src/colorize_output.sh'
fi

if [[ $(echo -en $__PROMPT_SH) -eq "" ]]; then 
include 'src/prompt.sh'
fi

if [[ $(echo -en $__START_SH) -eq "" ]]; then
include 'src/start.sh'
fi

# End : dependencies


# This message provides all the details required. Call
# This message to get the details. However, note that this
# message do not provide on any details of the procedure
# of the code. 

helpmsg() {
    echo -en '
extract.sh

SYNTAX: ./extract.sh [-o | --option] PARAMETER

This script stores a typical spreadsheet as a sql table. 

Usage:
-h | --help                                         shows this message
-U | --usename USERNAME          specifies the database username [optional]
-d | --dbname DBANME                specifies the database name to connect with [optional]
-f  | --filename FILENAME            specifies the text file to read [required]
-t  | --table-name TABLENAME    specifies the table name [DEFAULT: name of the sheet]
'
}

# PROCEDURES

# 1. Parse the programming argument list
# 2. Iterate through the argument list, and assign variables accordingly
# 3. Validate the assignments (e.g, check if the specified file exists)
# 4. start our main procedure

USERNAME=""
DBNAME=""
FILENAME=""
TABLENAME=""

# The script hasn't been called with any arguments.
if  [ $# -eq 0 ]; then
    helpmsg
    exit 0
fi

# Gets all the parameters.
ARGS=()
for ARG in "$@"
do
    #append ARGS
    ARGS[${#ARGS[@]}]=$ARG
done

# Iterate and assign 
for  (( i=0; i<$#; i++))
do 
    case ${ARGS[i]} in
        "-h"  |  "--help")
            helpmsg
            exit 0
            ;;
        "-d" | "--dbname")
            let "i++"
            DBNAME=${ARGS[i]}
            ;;
        "-U" | "--username")
            let "i++"
            USERNAME=${ARGS[i]}
            ;;
        "-f" | "--filename")
            let "i++"
            FILENAME=${ARGS[i]}
            ;;
        "-t" | "--tablename")
            let "i++"
            TABLENAME=${ARGS[i]}
            ;;
        *)
            # Having a wrong command doesn't terminate the program
            # However, it returns an error

            prompt --warning "WARNING: "
            prompt --info "Argument \"${ARGS[i]}\" is not an option. Omitting the argument. \n"
            ;;
    esac
done

# Command that will be used in postgresql
USER_COMMAND=""
DB_COMMAND=""


# Validate the assignments

# 1. Check whether the database filename has been inputted 
if [[ -z $FILENAME ]]; then
    prompt --error "FATAL ERROR: Filename not specified. Aborting the program. \n"
    exit 1
fi

# 2. Check whether the database filename exists
if [[ -f $FILENAME ]]; then 
    prompt --info "$FILENAME exists. Starting the conversion. \n"
else 
    prompt --error "FATAL ERROR: $FILENAME doesn't exist. Aborting the program. \n"
    exit 1
fi 

# 3. if USER exists, fill in the command. Don't exit if not, as it is optional. 
if [[ ! -z $USERNAME ]]; then
    prompt --info "Settting the username as $USERNAME. \n"
    USER_COMMAND="-U $USERNAME"
else 
    prompt --warning "username not specified. Using the default username. \n"
fi

# 4. if DBNAME exists, fill in the command. Don't exit if not, as it is optional.
if [[ ! -z $DBNAME ]]; then 
    prompt --info "Setting the database name as $DBNAME. \n"
    DB_COMMAND="-d $DBNAME"
else
    prompt --warning "database name not specified. Using the default name. \n"
fi

# 5. If TABLENAME exists, fill in the command. Otherwise, use the default name.
if [[ ! -z $TABLENAME ]]; then 
    prompt --info "Setting the table name as $TABLENAME. \n"
else 
    # The defualt table name is the name of the filename. 
    TABLENAME=$( echo $FILENAME | awk -F'/' '{ print $NF }' | awk -F'.' '{ for( i = 1 ; i <= NF-1 ; i++) { printf("%s", $i) } }' )
    #TABLENAME=${TABLENAME::-1}

    # Explanation of the above sentence
    # 1. Firstly, it outputs the filename -> /path/to/example.one.two.sh
    # 2. Then it pipelines it into awk, where awk removes the path -> example.one.two.sh
    # 3. Then it pipelines it into awk again, where awk removes the extention -> example.one.two
    # 4. Finally, remove the final fullstop, and the resulting value is our TABLENAME.

    #NOTE: Some RDBMS may not support fullstop in their table names, so fullstops are trimmed.

    prompt --warning "Table name not specified. Setting the default table name: $TABLENAME \n"
fi 

# Starts the creation of the database
start "$TABLENAME" "$USER_COMMAND" "$DB_COMMAND" "$FILENAME"

prompt --success "All done!\n"