#! /usr/bin/bash

export LC_COLLATE=C 
shopt -s extglob

# Import external scripts
source ./create_DB.sh
source ./utils_functtions.sh
source ./drop_DB.sh


# Global variable
    # Colors
GREEN_Highlight_Bold='\x1b[37;42;1m'
RED_Highlight_bold='\x1b[37;41;1m'
RESET='\033[0m'

DB_Dir="./databases"


main_menu() {
    PS3="Choise: "
    select choise in "Create database" "List databases" "Drop database" "Connect to database" "Quit" 
    do
        case $choise in
            "Create database")
                echo create_database
                create_database
                ;;
            "List databases")
                echo list_databases
                list_databases
                ;;
            "Drop database")
                echo drop_database
                drop_database
                ;;
            "Connect to database")
                echo connect_to_database
                ;;
            "Quit")
                read -p $'\x1b[37;41;1mq or (quit): to exit || or any key to back  : \e[0m ' isExit
                if [[ $isExit = q || $isExit = quit ]]
                then
                    echo "Exiting..."
                    break
                else
                    echo -e "${GREEN_Highlight_Bold}Back again to our DBMS....${RESET}"
                fi
                ;;
            *)
                echo -e "${RED_Highlight_bold}Invalid option${RESET}"
                ;;
        esac
    done
}


echo -e "\t\tWelcome To our database :)"
echo "============================================================="
if [ ! -d $DB_Dir ] 
then
    mkdir $DB_Dir
    echo -e "${GREEN_Highlight_Bold}Database directory created successfully...${RESET}"
fi



# Start the DBMS
main_menu