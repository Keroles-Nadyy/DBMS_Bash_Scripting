
source ./utils_functions.sh

# Function to drop database
drop_database() {
    clear
    echo -e "${BLUE_BOLD}\t\t\t\t\t=================================================================${RESET}"
    echo -e "${BLUE_BOLD}\t\t\t\t\t                         Drop Database                           ${RESET}"
    echo -e "${BLUE_BOLD}\t\t\t\t\t=================================================================${RESET}"

    list_databases_Present

    while true
    do
        read -r -p $'\x1b[31;1mEnter database name to drop or [q] for exit : \e[0m' db_name
        if [[ $db_name = [qQ] ]]
        then
            echo -e "${RED_bold}Drop operation cancelled. Exiting...${RESET}"
            mainMenu
            return
        fi

        if ! database_validate "$db_name" "Database"
        then
            continue
        fi

        if [ ! -d $DB_Dir/$db_name ]
        then
            echo -e "${RED_Highlight_bold}Database '$db_name' does not exist. Please try again.${RESET}"
            continue
        fi

        read -r -p $'\x1b[31;1mDo you want to drop \e[0m'"${db_name} "$'\x1b[31;1m[Y] for agree or [any key] for decline : \e[0m' answer
        case $answer in
            [Yy])
                rm -rf $DB_Dir/$db_name
                echo -e "${GREEN_Highlight_Bold}Database '$db_name' dropped successfully..${RESET}"

                read -r -p $'\x1b[31;1mDo you want to drop another database [Y] for agree or [any key] for decline : \e[0m' delete_more
                case $delete_more in
                    [Yy])
                        list_databases_Present
                        continue
                        ;;
                    *)
                        echo -e "${RED_bold}Exiting...${RESET}"
                        break
                esac
                ;;
            *)
                echo -e "${RED_bold}Drop operation cancelled. Exiting...${RESET}"
                break
        esac
    done
    mainMenu
}

