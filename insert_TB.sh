
source ./utils_functions.sh

insert_into_table(){
    local current_db=$1
    list_tables "$current_db"

    read -p "Enter table name to insert into: " tb_name

    if ! database_validate "$tb_name" "Table"
    then
        return 1
    fi

    # Check if table exists
    if [ ! -f "$DB_Dir/$current_db/$tb_name.txt" ]; then
        echo "Error: Table '$tb_name' does not exist in database '$current_db'."
        return 1
    fi

    # Check if metadata file exists
    metadata_file="$DB_Dir/$current_db/$tb_name-metadata.txt"
    db_file="$DB_Dir/$current_db/$tb_name.txt"
    
    if [ ! -f "$metadata_file" ]
    then
        echo "Error: Metadata file for table '$tb_name' not found."
        return 1
    fi

    # Extract field names and data types from metadata
    # field_datatypes=$(awk -F ',' '{printf "%s:%s, ", $1, $2}' "$metadata_file")
    field_datatypes=$(awk 'BEGIN { FS="[,\n]"; ORS="," } { printf "%s:%s:%s%s ", $1, $2, $3, (NR%3 ? "," : "\n") }' "${metadata_file}")
    echo "Fields (field:datatype) in table  '$tb_name': $field_datatypes"


    # Prompt user to insert data
    read -p "Enter data in the format 'value1,value2, ...': " inputData

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

        echo "MetaData: ${field_name} ${datatype} ${is_nullable} ${primary_key}"

        value="${values[count]}"
        count=$((count + 1))

        # Validate input
        if [ -z "$value" ]
        then
            # check if NOT NULL
            if [ "$is_nullable" == "NOT NULL" ]
            then
                echo "Error: '$field_name' cannot be NULL."
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
                    echo "$value already exists"
                    return 1
                else 
                    echo "$value does not exist"
                fi
            fi
        fi
    done  < "$metadata_file"

    # Insert values into table
    echo "$inputData" >> $db_file
    echo "Values inserted into table '$tb_name'."

    echo "Back Again to main Menu...."
}