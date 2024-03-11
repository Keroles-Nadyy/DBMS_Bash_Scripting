
source ./utils_functions.sh

insert_into_table(){
    local current_db=$1
    list_tables_Present "$current_db"

    while true
    do
        read -p "Enter table name to insert into : ( or q for exit ) " tb_name
        if [[ $tb_name = [qQ] ]]
        then
            echo -e "${RED_bold}Insert operation cancelled. Exiting...${RESET}"
            tableMenu
            return
        fi
        if ! database_validate "$tb_name" "Table"
        then
            continue
        fi
        break
    done

    # Check if metadata file exists
    metadata_file="$DB_Dir/$current_db/$tb_name-metadata.txt"
    db_file="$DB_Dir/$current_db/$tb_name.txt"

    if [[ ! -f "$db_file" && ! -f "$metadata_file"  ]]
    then
        echo -e "${RED_Highlight_bold}${tb_name} does not exist in ${db_name}. ${RESET}"
        continue
    fi

    # Extract field names and data types from metadata
    field_datatypes=$(awk 'BEGIN { FS="[,\n]"; ORS="," } { printf "%s:%s:%s%s ", $1, $2, $3, (NR%3 ? "," : "\n") }' "${metadata_file}")
    echo "Fields (field:datatype) in table  '$tb_name': $field_datatypes"

    while true
    do
        # Prompt user to insert data
        read -p "Enter data in the format 'value1,value2, ...': ( or q for exit ) " inputData
        if [[ $inputData = [qQ] ]]
        then
            echo -e "${RED_bold}Insert operation cancelled. Exiting...${RESET}"
            tableMenu
            return
        fi
        # Split data by comma separator
        IFS=',' read -ra values <<< "$inputData"

        # Validate input against metadata
        count=0
        while IFS= read -r field        
        do
            field_name=$(echo "$field" | cut -d ',' -f 1)
            datatype=$(echo "$field" | cut -d ',' -f 2)
            is_nullable=$(echo "$field" | cut -d ',' -f 3)
            primary_key=$(echo "$field" | cut -d ',' -f 4)

            value="${values[count]}"
            count=$((count + 1))

            # Validate input
            if [ -z "$value" ]
            then
                # check if NOT NULL
                if [ "$is_nullable" == "NOT NULL" ]
                then
                    echo -e "${RED_Highlight_bold}${field_name} cannot be NULL.${RESET}"
                    return 1
                fi
            else
                # Check its datatype
                if ! datatype_validate "$value" "$datatype"
                then
                    return 1
                fi

                # check if it's primary key
                if [ "$primary_key" == "PRIMARY KEY" ]
                then

                    if awk -F ',' -v value="${value}" -v field_number="${count}" 'BEGIN { found=0 } { if ($field_number == value) { found = 1; exit } } END { exit !found }' "${db_file}"
                    then
                        echo -e "${RED_Highlight_bold}$value already exists.${RESET}"
                        return 1
                    else 
                        echo -e "${GREEN_Highlight_Bold}$value does not exists.${RESET}"
                    fi
                fi
            fi
        done  < "$metadata_file"

        # Insert values into table
        echo "$inputData" >> $db_file
        echo -e "${GREEN_Highlight_Bold}Values inserted into table '$tb_name' successfully.${RESET}"
        break
    done
    echo "Back Again to main Menu...."
    tableMenu
}