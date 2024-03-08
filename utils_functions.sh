
database_validate(){
    db_name=$1
    
    if [ -z $db_name ]
    then
        echo "${RED_Highlight_bold}Database name cannot be empty.${RESET}"
        return 1
    fi

    if [[ ! $db_name =~ ^[a-zA-Z] ]]
    then
        echo -e "${RED_Highlight_bold}Database name must start with a letter.${RESET}"
        return 1
    fi

    if [[ ! $db_name =~ ^[a-zA-Z0-9_]+$ ]] 
    then
        echo -e "${RED_Highlight_bold}Database name can only contain alphanumeric characters and underscores.${RESET}"
        return 1
    fi
}