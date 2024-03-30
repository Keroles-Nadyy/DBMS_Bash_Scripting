source ./utils_functions.sh

drop_table(){
    current_db=$1
    if ! list_tables_Present "$current_db"
    then
        echo -e "${RED_Highlight_bold}No tables to be dropped.${RESET}"
        tableMenu
        return 1
    fi

    while true
    do
        read -r -p "Enter table name to drop : ( or q for exit ) " tb_name
        if [[ $tb_name = [qQ] ]]
        then
            echo -e "${RED_bold}Drop operation cancelled. Exiting...${RESET}"
            tableMenu
            return
        fi
        if ! database_validate "$tb_name" "Table"
        then
            continue
        fi

        metadata_file="$DB_Dir/$current_db/$tb_name-metadata.txt"
        db_file="$DB_Dir/$current_db/$tb_name.txt"

        if [[ ! -f "$db_file" && ! -f "$metadata_file"  ]]
        then
            echo -e "${RED_Highlight_bold}${tb_name} does not exist in ${db_name}. ${RESET}"
            continue
        fi
        break
    done

    while true
    do
        read -r -p "Are you sure you want to drop table '$tb_name' from database '$current_db'? [ Y | N ]: " confirm
        case $confirm in
            [Yy])
                rm "$db_file"
                rm "$metadata_file"
                echo -e "${GREEN_Highlight_Bold}Table $tb_name dropped successfully from database $current_db.${RESET}"
                list_tables_Present "$current_db"
                break
                ;;
            [Nn])
                echo -e "${RED_Highlight_bold}Drop operation cancelled.${RESET}"
                list_tables_Present "$current_db"
                break
                ;;
            *)
                echo -e "${RED_Highlight_bold}Invalid input. Please enter [ Y | N ].${RESET}"
                continue
                ;;
        esac
    done
    tableMenu
}