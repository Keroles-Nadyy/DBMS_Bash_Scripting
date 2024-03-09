
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

datatype_validate(){
    data=$1
    constrint=$2
    specified_string=$3
    case $constrint in
        "int")
            if ! [[ $data =~ ^[0-9]+$ ]]
            then
                echo -e "${RED_Highlight_bold}Invalid number.${RESET}"
                return 1
            fi
            ;;
        "string")
            case $specified_string in
            "full_name")
                if ! [[  "$data" =~ "^[a-zA-Z][a-zA-Z0-9_ ]+$" ]]
                then
                    echo -e "${RED_Highlight_bold}Invalid Full name, spaces only are allowed but not at the beginning.${RESET}"
                    return 1
                fi
                ;;
            "first_name")
                if  [[ ! $data =~ ^[a-zA-Z]+$ ]]
                then
                    echo -e "${RED_Highlight_bold}Invalid name, letters only.${RESET}"
                    return 1
                fi
                ;;
            "user_name")
                if  [[ ! $data =~ "^[a-zA-Z][a-zA-Z0-9_]+$" ]]
                then
                    echo -e "${RED_Highlight_bold}Not valid user_name, only letters, numbers, and underscores are valid.${RESET}"
                    return 1
                fi
                ;;
            "user_name")
                if  [[ ! $data =~ "^[a-zA-Z][a-zA-Z0-9_]+$" ]]
                then
                    echo -e "${RED_Highlight_bold}Not valid user_name, only letters, numbers, and underscores are valid.${RESET}"
                    return 1
                fi
                ;;
            "email")
                if  [[ ! $data =~ ^[a-zA-Z0-9][a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
                then
                    echo -e "${RED_Highlight_bold}Invalid email.${RESET}"
                    return 1
                fi
                ;;
            "phone_number")
                if  [[ ! $data =~ ^[+][0-9]{8,}|[0-9]{8,}$ ]]
                then
                    echo -e "${RED_Highlight_bold}Invalid phone number.${RESET}"
                    return 1
                fi
                ;;
            *)
                echo -e "${RED_Highlight_bold}Invalid datatype.${RESET}"
                return 1
                ;;
            esac
    esac
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
