
source ./utils_functions.sh

connect_database() {
    read -p "Enter database name to connect: " db_name

    if ! database_validate "$db_name"
    then
        return 1
    fi

    if [[ -d $DB_Dir/$db_name ]]
    then
        read -p "Select operation: " operation
        select operation in "Create table" "List tables" "Drop table" "Back to main menu"
        do
            case $operation in
                "Create table")
                    echo create_table
                    ;;
                "List tables")
                    echo list_tables
                    ;;
                "Drop table")
                    echo drop_table
                    ;;
                "Back to main menu")
                    break
                    ;;
                *)
                    echo "Invalid option"
                    ;;
            esac
        done
    else
        echo "Database '$db_name' does not exist."
    fi
}