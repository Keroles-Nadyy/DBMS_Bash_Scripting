
source ./utils_functions.sh

delete_from_table(){
    current_db=$1
    list_tables "$current_db"

    read -p "Enter table name to delete upon : " tb_name
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

    read -p "Enter field name to delete upon : " delete_field
    if ! database_validate "$tb_name" "Table"
    then
        return 1
    fi

    if [[ -z "$(awk -F ',' -v search="$delete_field" '$0 ~ "\\<" search "\\>" {print $1}' "${metadata_file}")" ]]
    then
        echo "Field Not Found"
        return 1
    else
        echo "Field is exist"
    fi

    delete_field_position=$(awk -F ',' -v search="$delete_field" '$0 ~ "\\<" search "\\>" {print NR}' "${metadata_file}")
    delete_field_datatype="$(awk -F ',' -v search="$delete_field" '{ if( $1 == search) {print $2}}' "${metadata_file}")"


    read -p "Enter value to delete : " delete_value
    echo "${delete_value}"
    if ! datatype_validate "$delete_value" "$delete_field_datatype"
    then
        echo -e "${RED_Highlight_bold}Invalid datatype for  $field must be $pk_field_datatype.${RESET}"
        return 1
    fi
    echo "Passed validation"

    if [[ -z $(awk -F ',' -v delete_field="$delete_field_position" -v delete_value="$delete_value" 'BEGIN {OFS=","} { if ($delete_field == delete_value) {print $0;}}' "${db_file}") ]]
    then
        echo "Value Not Found"
    else
        awk -F ',' -v delete_field="$delete_field_position" -v delete_value="$delete_value" 'BEGIN {OFS=","} { if ($delete_field != delete_value) {print $0;}}' "${db_file}" > temp_file && mv temp_file "${db_file}"
        echo "Row Deleted Successfully"
    fi

}