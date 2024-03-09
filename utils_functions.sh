
database_validate(){
    db_object_name=${1:-$db_name}
    db_object=${2:-Database}
    
    if [[ $db_name =~ [[:space:]] ]]
    then   
        echo -e "${RED_Highlight_bold}${db_object} name cannot contain space.${RESET}"
        return 1
    fi

    if [ -z $db_name ]
    then
        echo -e "${RED_Highlight_bold}${db_object} name cannot be empty.${RESET}"
        return 1
    fi

    if [ ${#db_name} -lt 2 ]
    then
        echo -e "${RED_Highlight_bold}${db_object} name must be at least 3 characters long.${RESET}"
        return 1
    fi

    if [[ ! $db_name =~ ^[a-zA-Z] ]]
    then
        echo -e "${RED_Highlight_bold}${db_object} name must start with a letter.${RESET}"
        return 1
    fi

    if [[ ! $db_name =~ ^[a-zA-Z0-9_]+$ ]] 
    then
        echo -e "${RED_Highlight_bold}${db_object} name can only contain alphanumeric characters and underscores.${RESET}"
        return 1
    fi
}


list_databases(){
    if [ -z "$(ls -A "$DB_Dir" )" ]
    then
        echo "No databases exist..."
    else
        echo -e "\tExisting databases :"
        ls -p "$DB_Dir" | grep '/$' | sed 's/\/$//'
    fi
}
