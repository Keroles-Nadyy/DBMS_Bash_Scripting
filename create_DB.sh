
source ./utils_functions.sh

create_database(){
    clear
    echo -e "${BLUE_BOLD}\t\t\t\t\t=================================================================${RESET}"
    echo -e "${BLUE_BOLD}\t\t\t\t\t                         Create Database                         ${RESET}"
    echo -e "${BLUE_BOLD}\t\t\t\t\t=================================================================${RESET}"
    while true
    do
        read -p $'\x1b[36;1mEnter database name: ( or q for exit ) : \e[0m' db_name
        if [[ $db_name = [qQ] ]]
        then
            echo -e "${RED_bold}Exiting...${RESET}"
            break
        fi

        if [[ $db_name =~ [[:space:]] ]]
        then   
            trimmed_db_name=$(echo "$db_name" | tr ' ' '_')
            read -p $'\x1b[37;41;1mDatabase name cannot contains spaces. we recommend to replace\e[0m '"${db_name}"$' \x1b[37;41;1mwith\e[0m '"${trimmed_db_name}"$' \x1b[37;41;1m In case you agree with that type [Y] or any key for decline  :\e[0m ' agreed        
            case $agreed in
            [Yy])
                db_name=$trimmed_db_name
                ;;
            *)
                echo -e "${RED_Highlight_bold}creating Database cancelled...${RESET}"
                continue
            esac
        fi

        if ! database_validate "$db_name" "Database"
        then
            continue
        fi

        if [ -d $DB_Dir/$db_name ]
        then
            echo -e "${RED_Highlight_bold}Database '$db_name' already exists.${RESET}"
            continue

        fi

        mkdir -p $DB_Dir/$db_name
        echo -e "${GREEN_Highlight_Bold}Database '$db_name' created successfully.${RESET}"
    done
    mainMenu
}