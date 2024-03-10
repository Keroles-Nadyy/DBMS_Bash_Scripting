
source ./utils_functions.sh

select_from_table() {
    db_name=$1

    read -p "Enter table name to select from: " tb_name
    if ! database_validate "$tb_name" "Table"
    then
        return 1
    fi

    # Check if table exists
    metadata_file="$DB_Dir/$db_name/$tb_name-metadata.txt"
    db_file="$DB_Dir/$db_name/$tb_name.txt"

    if [[ ! -f "$db_file" && ! -f "$metadata_file"  ]]
    then
        echo -e "${RED_Highlight_bold}${tb_name} does not exist in ${db_name}. ${RESET}"
        return 1
    fi

    read -p "Do you want to display the whole table? [ Y | N ]: " confirm_all
    case $confirm_all in
        [Yy])
            echo "All records in table '$tb_name':"
            cat "$db_file"
            ;;
        [Nn])
            read -p "Do you want to display based on primary key? [ Y | N ]: " confirm_pk
            case $confirm_pk in
                [Yy])
                    read -p "Enter primary key(s) value(s) (separated by commas if multiple): " pk_values
                    IFS=',' read -ra pk_array <<< "$pk_values"
                    for pk_value in "${pk_array[@]}"
                    do
                        grep "$pk_value" "$db_file"
                    done
                    ;;
                [Nn])
                    field_datatypes=$(awk 'BEGIN { FS="[,\n]"; OFS="," } { printf "%s:%s:%s%s ", $1, $2, $3, (NR%3 ? "," : "\n") }' "${metadata_file}")
                    echo "Fields (field:datatype) in table  '$tb_name': $field_datatypes"
                    
                    read -p "Enter conditions (field=value pairs separated by commas if multiple): " conditions
                    IFS=',' read -ra condition_array <<< "$conditions"

                    # Display records based on conditions
                    if [ ${#condition_array} -eq 0 ]
                    then
                        echo -e "${RED_Highlight_bold}${tb_name} No valid Input. ${RESET}"
                        echo -e "${YELLOW_Highlight_bold}\tThe whole table will be displayed. ${RESET}"
                        cat "$db_file"
                    else                       
                        # Read metadata to get field names and primary key
                        fields=($(awk -F ',' '{print $1}' "$metadata_file"))
                        # echo "Available fields in table: ${fields[*]}"

                        # Initialize selected records array
                        selected_records=()

                        # Loop through data file to check records against conditions
                        while IFS= read -r record
                        do
                            # match flag for current record
                            match=1

                            # Split record into fields
                            record_fields=($(echo "$record" | tr ',' '\n'))

                            # Loop through conditions
                            for condition in "${condition_array[@]}"
                            do
                                # Extract field and value from condition
                                field=$(echo "$condition" | cut -d '=' -f 1)
                                value=$(echo "$condition" | cut -d '=' -f 2)

                                # Get index of field in metadata
                                field_index=$(awk -v search="$field" 'BEGIN { found=0 } { if ($0 == search) { print NR; found=1; exit } } END { if (!found) print -1 }' <(printf '%s\n' "${fields[@]}"))

                                # Check if field exists in metadata
                                    # if count using wc is 0 so it's not exist
                                if [[ "$field_index" -eq -1 || "$field_index" -eq 0 ]]
                                then
                                    echo -e "${RED_Highlight_bold}Field $field not exist in $tb_name.${RESET}"
                                    return 1
                                fi

                                field_datatype=$(awk -F ',' -v search="$field" '{ if( $1 == search) {print $2}}' "${metadata_file}")
                                if ! datatype_validate "$value" "$field_datatype"
                                then
                                    echo -e "${RED_Highlight_bold}Invalid datatype for  $field must be $field_datatype.${RESET}"
                                    return 1
                                fi
                                
                                # Get field value from record
                                field_value=${record_fields[$field_index - 1]}
                                if [ "$field_value" != "$value" ]
                                then
                                    match=0
                                    # echo -e "${RED_Highlight_bold}Field $field does not has this value : $value.${RESET}"
                                    break
                                fi
                            done

                            # If all conditions are satisfied, add record to selected records
                            if [ "$match" -eq 1 ]
                            then
                                # echo "There is a match"
                                selected_records+=("$record")
                            fi
                        done < "$db_file"

                        # Display selected records
                        echo "=========================================================="
                        if [ ${#selected_records} -eq 0 ]
                        then
                            echo -e "${RED_Highlight_bold}No match...${RESET}"
                            return 1
                        else
                            echo -e "\tSelected records:"
                            echo "${selected_records[@]}"
                        fi
                        echo "===================================================="
                    fi
                    ;;
                *)
                    echo -e "${RED_Highlight_bold}Invalid input. Please enter [ Y| N ]. ${RESET}"
                    continue
                    # return 1
                    ;;
            esac
            ;;
        *)
            echo -e "${RED_Highlight_bold}Invalid input. Please enter [ Y| N ]. ${RESET}"
            # return 1
            continue
            ;;
    esac
}