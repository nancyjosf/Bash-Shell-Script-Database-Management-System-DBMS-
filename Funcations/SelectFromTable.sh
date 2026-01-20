
#! /bin/bash
source ./Funcations/sharefun.sh

Select_By_Culome(){
    trap 'echo -e "\n$Yellow [!] Selection Process Cancelled. Returning to Menu... $Reset"; trap - SIGINT; return' SIGINT
    prepare_columns || return
    echo "Select Column to Find Row:"
    read -p "Enter column number: " col_choice
    col_choice=$(tr " " "_" <<< "$col_choice")
     if [[ -z "$col_choice" || "$col_choice" == *[!0-9]* ]]; then
        echo -e "$Red Error: Please enter a valid positive number. $Reset"
       return
     fi
     if [[ "$col_choice" -gt 0 && "$col_choice" -le "$num_cols" ]]; then
            
            col_name=${columns[$((col_choice-1))]}
            col_type=$(echo "$meta_only" | awk -F: -v idx="$col_choice" '$2 == idx {print $4}' | tr -d ' \r\n')
            
            if [[ -z "$col_type" ]]; then
               col_type="unknown"
            fi
           echo -e "$Green Column Selected Successfully  $Reset"
           echo -e "$Cyan → Column Name : [$col_name] $Reset"
           echo -e "$Cyan → Data Type  : [$col_type] $Reset"

            
            match_type
            matched=$(
                 awk '
                  BEGIN{
                      FS=":"          
                  }

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
            echo -e "$Red No matching row found! $Reset"
            else
            echo -e "$Green Matching row(s):$Reset"
            echo "$fline"
            echo -e "${LightGreen}${matched}${Reset}"
            fi 

           else
            echo -e "$Red Invalid selection! $Reset"
            
           fi   
       trap - SIGINT
}


Selact_spicific_culums(){
    trap 'echo -e "\n$Yellow [!] Selection cancelled. Returning to menu... $Reset"; trap - SIGINT; return' SIGINT
    prepare_columns || return

    selected_cols=()

    while true; do
        found=false 
        read -p "Enter column number to select: " col_choice
        col_choice=$(tr " " "_" <<< "$col_choice")
        
        if [[ ! -z "$col_choice" && "$col_choice" != *[!0-9]* ]]; then
            if [[ "$col_choice" -ge 1 && "$col_choice" -le "$num_cols" ]]; then
                for col in "${selected_cols[@]}"; do
                    if [[ "$col" == "$col_choice" ]]; then
                        found=true
                        break
                    fi
                done

                if [[ "$found" == true ]]; then
                    echo -e "$Yellow Column already selected! $Reset"
                else
                    selected_cols+=("$col_choice")
                    echo -e "$Green Column '${columns[$((col_choice-1))]}' added. $Reset"
                fi
            else
                echo -e "$Red Invalid column number! (Must be 1-$num_cols) $Reset"
            fi
        else
            echo -e "$Red Invalid input! Please enter a number. $Reset"
        fi

        while true; do
            read -p "Do you want to select another column? (y/n): " again
            case $again in
                [yY]) break ;; 
                [nN]) break 2 ;; 
                *) echo -e "$Red Error: Please enter 'y' for yes or 'n' for no. $Reset" ;;
            esac
        done
    done

    if [[ ${#selected_cols[@]} -eq 0 ]]; then
        echo -e "$Red No columns were selected! $Reset"
    else
      fields_list=$(echo "${selected_cols[@]}" | tr ' ' ',')
      echo -e "$Cyan Selected Columns:$Reset"
      cut -d: -f"$fields_list" "$table_file" | column -t -s ':'
    fi

    trap - SIGINT
}

Select_From_Table(){
    echo -e "$Blue Your Chois is Select Table  : $Reset"
    list_tables || return
    tables_list=$(ls "$DB_PATH" 2>/dev/null | grep -v "^\.")
    
    if [[ -z "$tables_list" ]]; then 
      return
    fi

    while true; do
        read -r -p "Enter Table Name from list: " table_name
        if [[ -f "$DB_PATH/$table_name" && ! "$table_name" == .* ]]; then
            break 
        else
            echo -e "$Red Error: Invalid Table Name. $Reset"
        fi
    done

    echo -e "$Cyan You selected Table: $table_name $Reset"
    
    local old_ps3=$PS3
    PS3="$table_name/Select>> "
    
    table_file="$DB_PATH/$table_name"
    meta_file="$DB_PATH/.$table_name.meta"

    menus=("Select_ALL" "Select_By_Culome" "Select_specific_columns" "Selaction_Menu" "Table_Menu")

    select variable in "${menus[@]}"
    do
    case $REPLY in
      1 | "Select_ALL") 
        echo -e "$Purple Your Choice is Select_ALL .......$Reset"
        show_table
        Selaction_Menu
      ;; 

      2 | "Select_By_Culome") 
        echo -e "$Purple Your Choice is Select_By_Culome .......$Reset"
        Select_By_Culome
        Selaction_Menu
      ;;   

      3 | "Select_specific_columns") 
        echo -e "$Purple Your Choice is  Select specific columns.......$Reset"
        Selact_spicific_culums
        Selaction_Menu
      ;;

      4 | "Selaction_Menu")
         Selaction_Menu
      ;;

      5 | "Table_Menu")
        export PS3="$DB_NAME>> "
        return 
      ;;  

       *)
        echo -e "${Red}Invalid Choice${Reset}"
      ;;
    esac     
    done
    PS3=$old_ps3
}
