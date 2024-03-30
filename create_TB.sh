source ./utils_functions.sh

create_table(){
    db_name=$1
    list_tables_Present "$db_name"

    # reset Variables
    notNull_fields_names=()
    fields_names=()
    
    while true
    do
        read -r -p "Enter table name : ( or q for exit ): " tb_name
        if [[ $tb_name = [qQ] ]]
        then
            echo -e "${RED_bold}Create operation cancelled. Exiting...${RESET}"
            tableMenu
            return
        fi
        # validate table name using database_validate function in utils_functions.sh
        if ! database_validate "$tb_name" "Table"
        then
            continue
        fi

        # Check if the table is already exist or not.
        if [ -f "$DB_Dir/$db_name/$tb_name.txt" ]
        then
            echo -e "${RED_Highlight_bold}Table '$tb_name' already exists.${RESET}"
            continue
        fi
        break
    done
    
    # In case the table name is valid and it's not exist, create 2 files, table_name.txt, table_name-metadata.txt 
    tb_file=$DB_Dir/$db_name/$tb_name.txt
    tb_meta_file=$DB_Dir/$db_name/$tb_name-metadata.txt
    
    touch $tb_file
    touch $tb_meta_file
    echo "Table '$tb_name' created."

    
    # Ask for number of fields in the table that must be more than 1 field
    while true
    do
        read -r -p "Enter the number of fields: ( or q for exit ) " tb_num_fields
        if [[ $tb_num_fields = [qQ] ]]
        then
            echo -e "${RED_bold}Exiting...${RESET}"
            # Drop table
            rm -f "$tb_file"
            rm -f "$tb_meta_file"
            tableMenu
            return
        else
            until [[ $tb_num_fields =~ ^[2-9]+$ ]]
            do
                echo -e "${RED_Highlight_bold}Number must be at least 2 fields.${RESET}"
                read -r -p "Enter the number of fields: " tb_num_fields
            done
        fi
        break
    done

    # Start looping over these fields 
    # for i in $(seq $tb_num_fields)
    for ((i = 0 ; i < $tb_num_fields ; i++))
    do
        read -r -p "Enter name for field $(($i+1)):  ( or q for exit )  " field_name
        if [[ $field_name = [qQ] ]]
        then
            echo -e "${RED_bold}Exiting...${RESET}"
            # Drop table
            rm -f "$tb_file"
            rm -f "$tb_meta_file"
            tableMenu
            return
        fi
        if ! database_validate "$field_name" "Field"
        then
            ((i--))
            continue
        else
            # specify the datatype
            while true
            do
                read -r -p "Enter data type for $field_name [ string | int ] : ( or q for exit ) " data_type
                if [[ $data_type = [qQ] ]]
                then
                    echo -e "${RED_bold}Exiting...${RESET}"
                    # Drop table
                    rm -f "$tb_file"
                    rm -f "$tb_meta_file"
                    tableMenu
                    return
                fi
                case $data_type in
                    [sS][tT][rR][iI][nN][gG])
                        data_type="String"
                        break
                        ;;
                    [iI][nN][tT])
                        data_type="int"
                        break
                        ;;
                    *)
                        echo -e "${RED_Highlight_bold}Invalid datatype. Please enter [ string | int ].${RESET}"
                        continue
                        ;;
                esac
            done

            # specify if the field is primary or not
            if [ -z "$primary_key" ]
            then
                while true
                do
                    read -r -p "Is $field_name a primary key? [ Y | N ] : " is_primary
                    case $is_primary in
                        [Yy])
                            primary_key="PRIMARY KEY"
                            echo -e "${GREEN_Highlight_Bold}Primary key selected: ${field_name}.${RESET}"
                            pk_field=$field_name
                            break
                            ;;
                        [Nn])
                            primary_key=""
                            break
                            ;;
                        *)
                            echo -e "${RED_Highlight_bold}IInvalid input. Please enter [ Y | N ].${RESET}"
                            continue
                            ;;
                    esac
                done
            fi
            
            # specify if the field is Nullable or not
            if [[ ! $field_name = $pk_field ]]
            then
                while true
                do
                    read -r -p "Is $field_name nullable? [ Y | N ]: " is_nullable
                    case $is_nullable in
                        [Yy])
                            nullable="NULL"
                            break
                            ;;
                        [Nn])
                            nullable="NOT NULL"
                            # Store fields names that are not null into array
                            notNull_fields_names+=("$field_name")
                            break
                            ;;
                        *)
                            echo -e "${RED_Highlight_bold}IInvalid input. Please enter [ Y | N ].${RESET}"
                            continue
                            ;;
                    esac
                done
            else
                nullable="NOT NULL"
            fi

            # insert field details to metadata file
            if [[ $field_name = $pk_field ]]
            then
                echo "$field_name,$data_type,$nullable,$primary_key" >> "$tb_meta_file"
            else
                echo "$field_name,$data_type,$nullable" >> "$tb_meta_file"
            fi

            # Store fields names in array
            fields_names+=("$field_name")
        fi
    done

    # If no primary key selected, prompt user again to choose one
    if [ -z "$primary_key" ]
    then
        echo -e "${YELLOW_Highlight_bold}No primary key selected. Please choose one.${RESET}"
        for field in "${fields_names[@]}"
        do
            echo -n "$field "
        done
        echo " "

        if [[ ${#notNull_fields_names} -gt 0 ]]
        then
            echo -n -e "${YELLOW_Highlight_bold}Our recommendations : ${RESET} "
            for nfield in "${notNull_fields_names[@]}"
            do
                echo -n "$nfield "
            done
            echo " "
        fi
        
        while true
        do
            read -r -p "Enter name of field to set as primary key: " primary_key_field
            if [[ " ${fields_names[@]} " =~ " ${primary_key_field} " ]]
            then
                if [[ "${notNull_fields_names[@]}" =~ "${primary_key_field}" ]]
                then
                    echo "${primary_key_field}"
                    
                    # The 1 at the end of the awk command, to print the current record (line).
                    awk -v key="${primary_key_field}" -v new_value="PRIMARY KEY" 'BEGIN{FS=","; OFS=","} { if($1 == key) {$4=new_value}}1' "$tb_meta_file" > temp && mv temp "$tb_meta_file"
                    break
                else
                    echo "${primary_key_field}"
                    read -r -p "Do you want ${primary_key_field} to be NOT NULL? [ Y | N ]: " nullable_modify
                    case $nullable_modify in
                        [Yy])
                            awk -v key="${primary_key_field}" -v new_value1="NOT NULL" -v new_value2="PRIMARY KEY" 'BEGIN{FS=","; OFS=","} { if($1 == key) {$3=new_value1; $4=new_value2}}1' "$tb_meta_file" > temp && mv temp "$tb_meta_file"
                            notNull_fields_names+=("$primary_key_field")
                            break
                            ;;
                        [Nn])
                            echo -e "${YELLOW_Highlight_bold}Please choose one from the list above.${RESET}"
                            continue
                            ;;
                        *)
                            echo -e "${RED_Highlight_bold}IInvalid input. Please enter [ Y | N ].${RESET}"
                            continue
                            ;;
                    esac
                fi
            else
                echo -e "${RED_Highlight_bold}Invalid field name. Please choose one from the list above..${RESET}"
                continue
            fi
        done
    fi
    echo -e "${GREEN_Highlight_Bold}Table '$tb_name' created successfully.${RESET}"
    tableMenu
}