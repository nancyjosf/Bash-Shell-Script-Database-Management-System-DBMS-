#! /bin/bash
source ./Funcations/sharefun.sh

create_table() {
   
trap 'rm -f "$table_file" "$meta_file" 2>/dev/null; return' SIGINT
    echo -e "\n--- Create New Table ---"

    read -r -p "Please enter the name of the table: " table_name
    table_name=$(tr " " "_" <<< "$table_name")

    if ! IsValidName "$table_name"; then
        echo -e "$Red Error 104: Invalid table name! $Reset"
        trap - SIGINT SIGTERM
        return 
    fi

    if [ -f "$DB_PATH/$table_name" ]; then
        echo -e "$Red Error 404: Table '$table_name' already exists! $Reset"
        trap - SIGINT SIGTERM
        return
    fi

    while true; do
        read -r -p "Enter number of columns: " colnumber
        if [[ -z "$colnumber" || "$colnumber" == *[!0-9]* || "$colnumber" -eq 0 ]]; then
            echo -e "$Red Error 104: Please enter a valid positive number. $Reset"
        else
            break
        fi
    done

    table_file="$DB_PATH/$table_name"
    meta_file="$DB_PATH/.$table_name.meta"

    touch "$table_file"
    touch "$meta_file"


    echo "Table Name: $table_name | Columns: $colnumber" > "$meta_file"

    for ((index=1; index<=colnumber; index++)); do
        read -r -p "Enter column $index name: " colname
        colname=$(tr " " "_" <<< "$colname")
        
        if ! IsValidName "$colname"; then
            echo -e "$Red Error 104: Invalid column name, try again. $Reset"
            ((index--)); continue
        fi

        if grep -q ":$colname:" "$meta_file" 2>/dev/null; then
            echo -e "$Red Error 404: Column name '$colname' already exists! $Reset"
            ((index--)); continue
        fi

        if [ $index -eq 1 ]; then
            echo -e "$Cyan Column $index is the PRIMARY KEY (ID) $Reset"
            REPLY=""
            local old_ps3=$PS3
            PS3="Select PK Type: "
            select pktype in "int" "string"; do
                case $pktype in
                    int|string)
                        colType=$pktype
                        break ;;
                    *) echo -e "$Red Invalid choice! $Reset" ;;
                esac
            done
            PS3=$old_ps3
            
            echo "PK:$index:$colname:$colType" >> "$meta_file"
            echo -n "$colname" >> "$table_file"
        else
            echo "Select datatype for column '$colname':"
            REPLY=""
            local old_ps3=$PS3
            PS3="Select Type: "
            select datatype in "int" "string" "bool" "date"; do
                case $datatype in
                    int|string|bool|date)
                        echo "Col:$index:$colname:$datatype" >> "$meta_file"
                        echo -n ":$colname" >> "$table_file" 
                        break ;;
                    *) echo -e "$Red Invalid choice! $Reset" ;;
                esac
            done
            PS3=$old_ps3
        fi
    done

    echo -e "" >> "$table_file" 
    
    trap - SIGINT SIGTERM

    echo -e "$Green Success 200: Table '$table_name' created successfully! $Reset"
}
