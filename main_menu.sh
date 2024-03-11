#! /usr/bin/bash

export LC_COLLATE=C 
shopt -s extglob

# Import external scripts
source ./create_DB.sh
source ./utils_functions.sh
source ./drop_DB.sh
source ./connect_DB.sh

export LC_COLLATE=C 
shopt -s extglob


# Global variable
    # Colors
GREEN_Highlight_Bold='\x1b[37;42;1m'
GREEN_bold='\x1b[32;1m'
RED_Highlight_bold='\x1b[37;41;1m'
RED_bold='\x1b[31;1m'
YELLOW_Highlight_bold='\x1b[30;43;1m'
YELLOW_bold='\x1b[33;1m'
CYAN_bold='\x1b[36;1m'
BLUE_BOLD='\x1b[34;1m'
TEST='\033[34;1m'
RESET='\033[0m'

DB_Dir="./databases"


main_menu() {
    clear
    echo -e "${BLUE_BOLD}\t\t\t\t\t==============================================================================${RESET}"
    echo -e "${BLUE_BOLD}\t\t\t\t\t                         Welcome to Bash DBMS Project                         ${RESET}"
    echo -e "${BLUE_BOLD}\t\t\t\t\t==============================================================================${RESET}"

    PS3="$(echo -e "${BLUE_BOLD}Select Database Operation >> ${RESET}")"
    select choise in "Create database" "List databases" "Drop database" "Connect to database" "Quit" 
    do
        case $choise in
            "Create database")
                create_database
                ;;
            "List databases")
                list_databases
                ;;
            "Drop database")
                drop_database
                ;;
            "Connect to database")
                connect_database
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


# echo -e "\t\tWelcome To our database :)"
# echo "============================================================="

if [ ! -d $DB_Dir ] 
then
    mkdir $DB_Dir
    echo -e "${GREEN_Highlight_Bold}Database directory created successfully...${RESET}"
fi

main_menu