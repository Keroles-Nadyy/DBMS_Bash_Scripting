
source ./utils_functions.sh

drop_database() {
    while true
    do
        read -p "Enter database name to drop or [q] for exit : " db_name

        if [[ $db_name = [qQ] ]]
        then
            echo "Exiting..."
            return
        fi

        if ! database_validate "$db_name"
        then
            echo "Please try again."
            continue
        fi

        if [ ! -d $DB_Dir/$db_name ]
        then
            echo -e "${RED_Highlight_bold}Database '$db_name' does not exist. Please try again.${RESET}"
            continue
        fi

        read -p "Do you want to drop ${db_name} [Y] for agree or [any key] for decline : " answer
        case $answer in
            [Yy])
                rm -rf $DB_Dir/$db_name
                echo "Database '$db_name' dropped."
                read -p "Do you want to drop another database [Y] for agree or [any key] for decline : " delete_more
                case $delete_more in
                    [Yy])
                        continue
                        ;;
                    *)
                        echo -e "Exiting..."
                        break
                esac
                ;;
            *)
                echo -e "Exiting..."
                break
        esac
    done
}