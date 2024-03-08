
source ./utils_functions.sh

drop_database() {
    read -p "Enter database name to drop : " db_name

    if ! database_validate "$db_name"
    then
        return 1
    fi

    if [ ! -d $DB_Dir/$db_name ]
    then
        echo -e "${RED_Highlight_bold}Database '$db_name' does not exist.${RESET}"
        return 1
    fi
    
    read -p "Do you want to drop ${db_name} [Y] for agree or [any key] for decline : " answer
    case $answer in
        [Yy])
            rm -rf $DB_Dir/$db_name
            echo "Database '$db_name' dropped."
            ;;
        *)
            echo -e "Exiting..."
            return 1
    esac
}
