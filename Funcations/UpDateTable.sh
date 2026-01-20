#! /bin/bash
source ./Funcations/sharefun.sh

update_table() {
    trap 'echo -e "\n$Yellow [!] Update Process Interrupted. No changes were made. $Reset"; trap - SIGINT; return' SIGINT

    list_tables || return
    
    while true; do
        read -r -p "Enter table name to UPDATE: " table_name
        
        if [[ -z "$(echo "$table_name" | tr -d ' ')" ]]; then
            echo -e "$Red Error: Table name cannot be empty! $Reset"
            continue
        fi
        
        table_name=$(tr " " "_" <<< "$table_name")
        table_file="$DB_PATH/$table_name"
        meta_file="$DB_PATH/.$table_name.meta"

        if [[ ! -f "$table_file" ]]; then
            echo -e "$Red Error: Table '$table_name' does not exist! Try again. $Reset"
            list_tables
        else
            break
        fi
    done

    echo -e "$Blue\n--- Current Data ---$Reset"
    show_table

    while true; do
        read -r -p "Enter PRIMARY KEY (Frist Culom)value to update: " pk_value
        
        if [[ -z "$(echo "$pk_value" | tr -d ' ')" ]]; then
            echo -e "$Red Error: Primary key cannot be empty! $Reset"
            continue
        fi

        row=$(awk -F: -v pk="$pk_value" '$1 == pk {print NR ":" $0}' "$table_file")

        if [[ -z "$row" ]]; then
            echo -e "$Red Error: Primary key '$pk_value' not found! Try again. $Reset"
        else
            break 
        fi
    done

    row_num=$(echo "$row" | cut -d: -f1)
    row_data=$(echo "$row" | cut -d: -f2-)

    IFS=':' read -r -a fields <<< "$row_data"
 
    mapfile -t meta < <(tail -n +2 "$meta_file")
    for ((i=1; i<${#meta[@]}; i++)); do
        col_name=$(echo "${meta[$i]}" | cut -d: -f3)
        col_type=$(echo "${meta[$i]}" | cut -d: -f4)
        current_value="${fields[$i]}"

        echo -e "$Yellow Column: $col_name ($col_type) | Current: $current_value $Reset"
        
        while true; do
            match_type 
            
            if [[ "$value" == ":" ]]; then
                echo -e "$Red Error: Data cannot contain colon (:). Try again.$Reset"
                continue
            fi
            
            if [[ -z "$value" ]]; then
                value="$current_value"
                break
            fi

            if [[ "$col_type" == "int" ]]; then
                if [[ $value != +([0-9]) ]]; then
                    echo -e "$Red Error: '$col_name' must be an INTEGER. Try again.$Reset"
                    continue
                fi
            elif [[ "$col_type" == "string" ]]; then
                if [[ $value == +([0-9]) ]]; then
                    echo -e "$Red Error: '$col_name' must be a STRING (cannot be only numbers). Try again.$Reset"
                    continue
                fi
            fi

            break
        done
        
        fields[$i]="$value"
    done

    updated_row=$(IFS=:; echo "${fields[*]}")

    tmp_file="/tmp/table_update_$$"
    if awk -v ln="$row_num" -v new="$updated_row" 'NR == ln { print new; next } { print }' "$table_file" > "$tmp_file"; then
        mv "$tmp_file" "$table_file"
        echo -e "$Green Row updated successfully! $Reset"
    else
        echo -e "$Red Error: Failed to write to file! $Reset"
        rm -f "$tmp_file"
    fi

    echo -e "$Blue\n--- Updated Table ---$Reset"
    show_table

    trap - SIGINT
}