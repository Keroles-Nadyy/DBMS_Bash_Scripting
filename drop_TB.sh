source ./utils_functions.sh

drop_table(){
    current_db=$1
    if ! list_tables "$current_db"
    then
        echo -e "${RED_Highlight_bold}No tables to be dropped.${RESET}"
        return 1
    fi

    read -p "Enter table name to drop: " tb_name

    # validate table name using database_validate function in utils_functions.sh
    if ! database_validate "$tb_name" "Table"
    then
        return 1
    fi

    # Check if table exists
    if [ ! -f "$DB_Dir/$current_db/$tb_name.txt" ]
    then
        echo -e "${RED_Highlight_bold}Table '$tb_name' does not exist in database '$current_db'.${RESET}"
        return 1
    fi
    
    read -p "Are you sure you want to drop table '$tb_name' from database '$current_db'? [ Y | N ]: " confirm
    case $confirm in
        [Yy])
            rm "$DB_Dir/$current_db/$tb_name.txt"
            rm "$DB_Dir/$current_db/$tb_name-metadata.txt"
            echo -e "${GREEN_Highlight_bold}Table '$tb_name' dropped successfully from database '$current_db'.${RESET}"
            list_tables "$current_db"
            ;;
        [Nn])
            echo -e "${RED_Highlight_bold}Drop operation cancelled.${RESET}"
            list_tables "$current_db"
            ;;
        *)
            echo -e "${RED_Highlight_bold}Invalid input. Please enter [ Y | N ].${RESET}"
            ;;
    esac
}