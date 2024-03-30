
source ./utils_functions.sh

delete_from_table(){
    current_db=$1
    list_tables_Present "$current_db"

    while true
    do
        read -r -p "Enter table name to delete upon : ( or q for exit ) " tb_name
        if [[ $tb_name = [qQ] ]]
        then
            echo -e "${RED_bold}Delete operation cancelled. Exiting...${RESET}"
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

    field_names=$(awk 'BEGIN { FS="[,\n]"; OFS="," } { printf "%s%s", $1, (NR%3 ? "," : "\n") }' "${metadata_file}")
    if [[ $(cat $db_file | wc -l) -lt 1 ]]
    then
        echo -e "${RED_Highlight_bold}${tb_name} does not have any fields to be deleted. Exiting...${RESET}"
        tableMenu
        return
    else
        echo "Fields in table '$tb_name': $field_names"
    fi

    draw_customized_table "$metadata_file" "$db_file" "$db_name" "$tb_name"

    while true
    do
        read -r -p "Enter field name to delete upon : ( or q for exit ) " delete_field
        if [[ $delete_field = [qQ] ]]
        then
            echo -e "${RED_bold}Delete operation cancelled. Exiting...${RESET}"
            tableMenu
            return
        fi

        if ! database_validate "$tb_name" "Table"
        then
            continue
        fi

        if [[ -z "$(awk -F ',' -v search="$delete_field" '$0 ~ "\\<" search "\\>" {print $1}' "${metadata_file}")" ]]
        then
            echo "Field Not Found"
            continue
        else
            echo "Field is exist"
        fi

        delete_field_position=$(awk -F ',' -v search="$delete_field" '$0 ~ "\\<" search "\\>" {print NR}' "${metadata_file}")
        delete_field_datatype="$(awk -F ',' -v search="$delete_field" '{ if( $1 == search) {print $2}}' "${metadata_file}")"
        break
    done

    while true
    do
        read -r -p "Enter value to delete : ( or q for exit ) " delete_value
        if [[ $delete_value = [qQ] ]]
        then
            echo -e "${RED_bold}Delete operation cancelled. Exiting...${RESET}"
            tableMenu
            return
        fi
        if ! datatype_validate "$delete_value" "$delete_field_datatype"
        then
            echo -e "${RED_Highlight_bold}Invalid datatype for  $delete_field must be $delete_field_datatype.${RESET}"
            continue
        fi

        if [[ -z $(awk -F ',' -v delete_field="$delete_field_position" -v delete_value="$delete_value" 'BEGIN {OFS=","} { if ($delete_field == delete_value) {print $0;}}' "${db_file}") ]]
        then
            echo "Value Not Found"
            continue
        else
            awk -F ',' -v delete_field="$delete_field_position" -v delete_value="$delete_value" 'BEGIN {OFS=","} { if ($delete_field != delete_value) {print $0;}}' "${db_file}" > temp_file && mv temp_file "${db_file}"
            echo "Row Deleted Successfully"
            break
        fi
    done

    draw_customized_table "$metadata_file" "$db_file" "$db_name" "$tb_name"
    tableMenu
}