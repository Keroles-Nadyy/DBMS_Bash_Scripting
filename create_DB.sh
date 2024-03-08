
source ./utils_functions.sh


create_database(){
    read -p "Enter database name: " db_name

    if [[ $db_name =~ [[:space:]] ]]
    then   
        trimmed_db_name=$(echo "$db_name" | tr ' ' '_')
        read -p $'\x1b[37;41;1mDatabase name cannot contains spaces. we recommend to replace\e[0m '"${db_name}"$' \x1b[37;41;1mwith\e[0m '"${trimmed_db_name}"$' \x1b[37;41;1m In case you agree with that type [Y] or any key for decline  :\e[0m ' agreed        
        case $agreed in
        [Yy])
            db_name=$trimmed_db_name
            ;;
        *)
            echo -e "${RED_Highlight_bold}Exiting without creating Database...${RESET}"
            return 1
        esac
    fi

    if ! database_validate "$db_name"
    then
        return 1
    fi

    if [ -d $DB_Dir/$db_name ]
    then
        echo -e "${RED_Highlight_bold}Database '$db_name' already exists.${RESET}"
        return 1
    fi

    mkdir -p $DB_Dir/$db_name
    touch $DB_Dir/$db_name/$db_name-metadata.txt
    echo -e "${GREEN_Highlight_Bold}Database '$db_name' created.${RESET}"
}
