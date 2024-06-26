
source ./utils_functions.sh
source ./create_TB.sh
source ./drop_TB.sh
source ./insert_TB.sh
source ./select_TB.sh
source ./update_TB.sh
source ./delete_from_TB.sh


connect_database(){
    clear
    echo -e "${BLUE_BOLD}\t\t\t\t\t=====================================================================${RESET}"
    echo -e "${BLUE_BOLD}\t\t\t\t\t                         Connect to Database                         ${RESET}"
    echo -e "${BLUE_BOLD}\t\t\t\t\t=====================================================================${RESET}"
    
    list_databases_Present
    while true
    do
        read -r -p $'\x1b[33;1mEnter database name to connect:  ( or q for exit ) \e[0m' db_name
        if [[ $db_name = [qQ] ]]
        then
            echo -e "${RED_bold}Exiting...${RESET}"
            break
        fi
        if ! database_validate "$db_name" "Database"
        then
            # return 1
            continue
        fi

        if [ -d $DB_Dir/$db_name ]
        then
            PS3="$(echo -e "${YELLOW_bold}${db_name} >> Select operation : ${RESET}")"
            select operation in "Create table" "List tables" "Drop table" "Insert into table" "Select from table" "Update table" "Delete from table" "Back to main menu"
            do
                case $operation in
                    "Create table")
                        create_table "$db_name"
                        ;;
                    "List tables")
                        list_tables "$db_name"
                        ;;
                    "Drop table")
                        drop_table "$db_name"
                        ;;
                    "Insert into table")
                        insert_into_table "$db_name"
                        ;;
                    "Select from table")
                        select_from_table "$db_name"
                        ;;
                    "Update table")
                        update_table "$db_name"
                        ;;
                    "Delete from table")
                        delete_from_table "$db_name"
                        ;;
                    "Back to main menu")
                        PS3="$(echo -e "${BLUE_BOLD}Select Database Operation >> ${RESET}")"
                        mainMenu
                        break
                        ;;
                    *)
                        echo -e "${RED_Highlight_bold}Invalid option.${RESET}"
                        ;;
                esac
            done
        else
            echo -e "${RED_Highlight_bold}Database '$db_name' does not exist.${RESET}"
            continue
        fi
        break
    done
}

mainMenu