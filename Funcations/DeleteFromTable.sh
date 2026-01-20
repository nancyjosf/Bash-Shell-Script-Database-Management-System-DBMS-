#! /bin/bash
source ./Funcations/sharefun.sh

Delete_By_Culome() {
    trap 'echo -e "\n$Yellow Deletion aborted.$Reset"; return' SIGINT

    echo -e "$Cyan Your $table_name Table before Delete : $Reset"
    show_table
    prepare_columns || return

    while true; do
        read -p "Enter column number to filter to delete: " col_choice
        col_choice=$(tr " " "_" <<< "$col_choice")

        if [[ ! -z "$col_choice" && "$col_choice" != *[!0-9]* ]]; then
            if [[ "$col_choice" -ge 1 && "$col_choice" -le "$num_cols" ]]; then
                break
            else
                echo -e "$Red Error 104: Invalid column number! (Must be 1-$num_cols) $Reset"
            fi
        else
            echo -e "$Red Error 105: Invalid input! Please enter a valid number. $Reset"
        fi
    done

    col_name=${columns[$((col_choice-1))]}
    target_line=$(echo "$meta_only" | awk -F: -v idx="$col_choice" '$2 == idx {print $0}')
    col_type=$(echo "$target_line" | awk -F: '{print $4}' | tr -d ' \r\n')

    echo -e "$Green You selected Column: $col_name $Reset"
    echo -e "$Cyan Searching in: [$col_name] | Data Type: [$col_type] $Reset"

    match_type 

    matched=$(
        awk '
        BEGIN{ FS=":" }
        {
            if (NR > 1) {
                if ($col == val) {
                    print $0
                }
            }
        }
        ' col="$col_choice" val="$value" "$table_file"
    )

    if [[ -z "$matched" ]]; then
        echo -e "$Red Error 106: No matching row found! $Reset"
        trap - SIGINT
        return 1
    else
        echo -e "$Yellow Rows to be deleted:$Reset"
        echo "$fline"
        echo "$matched"

        read -p "Are you sure you want to delete these rows? (y/n): " confirm
        if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
            echo -e "$Yellow Deletion cancelled. Returning... $Reset"
            trap - SIGINT
            return 1
        fi

        while read -r line_to_delete; do
            if [[ -n "$line_to_delete" ]]; then
                sed -i "/^$line_to_delete$/d" "$table_file"
            fi
        done <<< "$matched"

        echo -e "$Green Rows deleted successfully! $Reset"
        echo -e "$Cyan Your $table_name Table after Delete : $Reset"
        show_table
        trap - SIGINT
        return 0 
    fi

    trap - SIGINT
}

Delete_From_Table() {
    echo -e "$Blue Select Table to Delete From: $Reset"
    list_tables || return
    tables_list=$(ls "$DB_PATH" 2>/dev/null | grep -v "^\.")
    
    if [[ -z "$tables_list" ]]; then 
        echo -e "$Yellow Warning: No tables found in this database.$Reset"
        return
    fi

    while true; do
        read -r -p "Enter Table Name from list: " table_name
        if [[ -f "$DB_PATH/$table_name" && ! "$table_name" == .* ]]; then
            break
        else
            echo -e "$Red Error 107: Invalid Table Name. Please select a valid table.$Reset"
        fi
    done

    echo -e "$Cyan You selected Table: $table_name $Reset"
    export PS3="$table_name>> "

    table_file="$DB_PATH/$table_name"
    meta_file="$DB_PATH/.$table_name.meta"

    echo "Delete Menu:"
    local old_ps3=$PS3
    PS3="$table_name/Delete>> "

    menus=("Delete_ALL" "Delete_By_Culome" "Table_Menue" "Main_Menue")

    select variable in "${menus[@]}"; do
        case $REPLY in
            1|"Delete_ALL") 
                echo -e "$Red WARNING: You are about to delete ALL records in '$table_name' $Reset"
                read -p "Are you sure? (y/n): " confirm
                if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
                    sed -i '2,$d' "$table_file"
                    echo -e "$Green All records deleted successfully! $Reset"
                else
                    echo -e "$Yellow Operation cancelled. $Reset"
                fi
                Table_Menu
                break
                
                ;;
            
            2|"Delete_By_Culome") 
                echo -e "$Purple You chose: Delete By Column ....... $Reset"
                Delete_By_Culome
                break
                ;;
            
            3|"Table_Menue")
                Table_Menu
                return
                
                ;;
            
            4|"Main_Menue")
                Main_Menue
                export PS3="$DB_NAME>> "
                break
                ;;
            
            *)
                echo -e "$Red Error 108: Invalid Choice. Please select a valid option.$Reset"
                ;;
        esac     
    done
    PS3=$old_ps3
}
