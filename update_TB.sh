
source ./utils_functions.sh

update_table(){
    db_name=$1

    read -p "Enter table name to update into: " tb_name
    if ! database_validate "$tb_name" "Table"
    then
        return 1
    fi

    metadata_file="$DB_Dir/$db_name/$tb_name-metadata.txt"
    db_file="$DB_Dir/$db_name/$tb_name.txt"

    if [[ ! -f "$db_file" && ! -f "$metadata_file"  ]]
    then
        echo -e "${RED_Highlight_bold}${tb_name} does not exist in ${db_name}. ${RESET}"
        return 1
    fi

    pk_field=$(awk -F ',' '/PRIMARY KEY/ {print $1}' "${metadata_file}")
    pk_field_datatype="$(awk -F ',' -v search="$pk_field" '{ if( $1 == search) {print $2}}' "${metadata_file}")"
    pk_field_position=$(awk -F ',' '/PRIMARY KEY/ {print NR}' "${metadata_file}")

    # Read field to update
    read -p "Enter PK for row to update: " PK_field_value
    echo "${PK_field_value}"
    if ! datatype_validate "$PK_field_value" "$pk_field_datatype"
    then
        echo -e "${RED_Highlight_bold}Invalid datatype for  $field must be $pk_field_datatype.${RESET}"
        return 1
    fi

    if [ -z "$(awk -F ',' -v search="$PK_field_value" -v position="$pk_field_position" '{ if ($position == search) { print $position } }' "${db_file}")" ]
    then
        echo "${PK_field_value} PK doesn't Exist"
        return 1
    else
        # Read field to update
        read -p "Enter field to update: " field_name
        if ! database_validate "$field_name" "Field"
        then
            return 1
        fi
        # field_in_table
        if [ "$field_name" == $pk_field ]
        then
            echo "Not allowed to update the PK"
            return 1
        else
            if [ "$field_name" == "$(awk -F ',' -v search="$field_name" '{ if( $1 == search) {print $1}}' "${metadata_file}")" ]
            then
                field_datatype=$(awk -F ',' -v search="$field_name" '{ if( $1 == search) {print $2}}' "${metadata_file}")
            else
                echo "Invalid Input"
                return 1
            fi

            read -p "Enter new value for '$field_name': " new_value
            
            if ! datatype_validate "$new_value" "$field_datatype"
            then
                echo -e "${RED_Highlight_bold}Invalid datatype for  $field_name must be $field_datatype.${RESET}"
                return 1
            fi
            update_field_position=$(awk -F ',' -v search="$field_name" '$0 ~ "\\<" search "\\>" {print NR}' "${metadata_file}")

            echo "Start updating"
            awk -F ',' -v field="$update_field_position" -v new_val="$new_value" -v cond_field="$pk_field_position" -v cond_val="$PK_field_value" 'BEGIN {OFS=","} { if ($cond_field == cond_val) {$field = new_val;} print $0;}' "$db_file" > temp_file && mv temp_file "$db_file"
            echo "Updated successfully"

        fi
    fi
}