
#! /bin/bash
source ./Funcations/sharefun.sh

drop_table() {
    list_tables || return

    read -r -p "Enter table name to DROP: " table_name
    table_name=$(tr " " "_" <<< "$table_name")

    if [[ "$table_name" == .* ]]; then
        echo -e "$Red Error: Access denied! You cannot drop system files. $Reset"
        return
    fi

    table_file="$DB_PATH/$table_name"
    meta_file="$DB_PATH/.$table_name.meta"

    if [[ ! -f "$table_file" ]]; then
        echo -e "$Red Error: Table '$table_name' does not exist! $Reset"
        return
    fi

    
    trap 'echo -e "\n$Yellow Drop operation aborted.$Reset"; return' SIGINT

   
    echo -e "$Yellow WARNING: You are about to delete the table '$table_name' permanently!$Reset"
    echo -e "This will delete all records and metadata associated with it."
    
    read -r -p "To confirm, please type the table name again: " confirm

    if [[ "$confirm" == "$table_name" ]]; then
        rm "$table_file" "$meta_file" 2>/dev/null
        
        if [[ $? -eq 0 ]]; then
            echo -e "$Green Table '$table_name' dropped successfully! $Reset"
        else
            echo -e "$Red Error: Could not delete table files. Check permissions.$Reset"
        fi
    else
        echo -e "$Blue Drop table canceled. Names did not match. $Reset"
    fi

    trap - SIGINT
}