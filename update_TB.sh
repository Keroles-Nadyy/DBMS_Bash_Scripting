
source ./utils_functions.sh

update_table(){
    db_name=$1
    list_tables_Present "$db_name"

    while true
    do
        read -r -p "Enter table name to update into: ( or q for exit ) " tb_name
        if [[ $tb_name = [qQ] ]]
        then
            echo -e "${RED_bold}Update operation cancelled. Exiting...${RESET}"
            tableMenu
            return
        fi

        if ! database_validate "$tb_name" "Table"
        then
            continue
        fi

        metadata_file="$DB_Dir/$db_name/$tb_name-metadata.txt"
        db_file="$DB_Dir/$db_name/$tb_name.txt"

        if [[ ! -f "$db_file" && ! -f "$metadata_file"  ]]
        then
            echo -e "${RED_Highlight_bold}${tb_name} does not exist in ${db_name}. ${RESET}"
            continue
        fi
        break
    done
    
    draw_customized_table "$metadata_file" "$db_file" "$db_name" "$tb_name"

    pk_field=$(awk -F ',' '/PRIMARY KEY/ {print $1}' "${metadata_file}")
    pk_field_datatype="$(awk -F ',' -v search="$pk_field" '{ if( $1 == search) {print $2}}' "${metadata_file}")"
    pk_field_position=$(awk -F ',' '/PRIMARY KEY/ {print NR}' "${metadata_file}")

    while true
    do
        # Read field to update
        read -r -p "Enter PK for row to update: ( or q for exit ) " PK_field_value
        if [[ $PK_field_value = [qQ] ]]
        then
            echo -e "${RED_bold}Update operation cancelled. Exiting...${RESET}"
            tableMenu
            return
        fi
        if ! datatype_validate "$PK_field_value" "$pk_field_datatype"
        then
            echo -e "${RED_Highlight_bold}Invalid datatype for $pk_field must be $pk_field_datatype.${RESET}"
            continue
        fi

        if [ -z "$(awk -F ',' -v search="$PK_field_value" -v position="$pk_field_position" '{ if ($position == search) { print $position } }' "${db_file}")" ]
        then
            echo -e "${RED_Highlight_bold}${PK_field_value} PK doesn't Exist.${RESET}"
            continue
        fi
        break
    done

    while true
    do
        # Read field to update
        read -r -p "Enter field to update: ( or q for exit ) " field_name
        if [[ $field_name = [qQ] ]]
        then
            echo -e "${RED_bold}Update operation cancelled. Exiting...${RESET}"
            tableMenu
            return
        fi
        if ! database_validate "$field_name" "Field"
        then
            continue
        fi

        # field_in_table
        if [ "$field_name" == $pk_field ]
        then
            echo -e "${RED_Highlight_bold}Not allowed to update the PK.${RESET}"
            continue
        else
            if [ "$field_name" == "$(awk -F ',' -v search="$field_name" '{ if( $1 == search) {print $1}}' "${metadata_file}")" ]
            then
                field_datatype=$(awk -F ',' -v search="$field_name" '{ if( $1 == search) {print $2}}' "${metadata_file}")
            else
                echo -e "${RED_Highlight_bold}${field_name} Not exist.${RESET}"
                continue
            fi
        fi
        break
    done
    while true
    do
        read -r -p "Enter new value for '$field_name' : ( or q for exit ) " new_value
        if [[ $new_value = [qQ] ]]
        then
            echo -e "${RED_bold}Update operation cancelled. Exiting...${RESET}"
            tableMenu
            return
        fi
        
        if ! datatype_validate "$new_value" "$field_datatype"
        then
            echo -e "${RED_Highlight_bold}Invalid datatype for  $field_name must be $field_datatype.${RESET}"
            continue
        fi
        update_field_position=$(awk -F ',' -v search="$field_name" '$0 ~ "\\<" search "\\>" {print NR}' "${metadata_file}")

        awk -F ',' -v field="$update_field_position" -v new_val="$new_value" -v cond_field="$pk_field_position" -v cond_val="$PK_field_value" 'BEGIN {OFS=","} { if ($cond_field == cond_val) {$field = new_val;} print $0;}' "$db_file" > temp_file && mv temp_file "$db_file"
        echo "Updated successfully"
        break
    done
    draw_customized_table "$metadata_file" "$db_file" "$db_name" "$tb_name"
    tableMenu
}