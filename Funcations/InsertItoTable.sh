#! /bin/bash
source ./Funcations/sharefun.sh

insert_into_table() {

    trap 'echo -e "\n$Yellow [!] Insert cancelled. No data was saved.$Reset";
          trap - SIGINT;
          return' SIGINT

    list_tables || return

    while true; do
        read -r -p "Enter table name from list: " table_name

        if [[ -z "$table_name" ]]; then
            echo -e "$Red Error: Table name cannot be empty.$Reset"

        elif [[ "$table_name" == .* ]]; then
            echo -e "$Red Error: Access denied to hidden files.$Reset"

        elif [[ ! -f "$DB_PATH/$table_name" ]]; then
            echo -e "$Red Error: Table '$table_name' does not exist.$Reset"

        elif [[ ! -f "$DB_PATH/.$table_name.meta" ]]; then
            echo -e "$Red Error: Metadata file missing. Table is corrupted.$Reset"

        else
            break
        fi
    done

    table_file="$DB_PATH/$table_name"
    meta_file="$DB_PATH/.$table_name.meta"

    new_row=""

  
  while IFS=: read -r col_role col_index col_name col_type; do

    export col_name
    export col_type

    while true; do
        match_type || continue

        
        if [[ "$col_role" == "PK" ]]; then
            exists=$(awk -F: -v val="$value" 'NR>1 && $1==val {print 1}' "$table_file")
            if [[ -n "$exists" ]]; then
                echo -e "$Red Error: Primary Key '$value' already exists.$Reset"
                continue
            fi
        fi
        break
    done

    if [[ -z "$new_row" ]]; then
        new_row="$value"
    else
        new_row="$new_row:$value"
    fi

done < <(awk -F: 'NR>1 {print $0}' "$meta_file")


    echo "$new_row" >> "$table_file"

    trap - SIGINT

    echo -e "$Green Success 200: Data inserted successfully.$Reset"
    show_table
}
