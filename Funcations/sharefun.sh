#!/bin/bash

LC_COLLATE=C 
shopt -s extglob 

Reset="\033[0m"
Red="\033[31m"
#err
Green="\033[32m"
#scess
Yellow="\033[33m"
#waring
Blue="\033[34m"
#enter
Cyan="\033[36m"
Purple="\033[35m"

LightBlue="\033[94m"  
LightGreen="\033[92m" 
Orange="\033[91m"   

RESERVED_WORDS=("int" "string" "bool" "date" "TABLE" "PK" "Col" "database")
IsValidName() {
    local name=$1
    
    if [[ -z $name ]]; then
        echo -e "$Red Error: Name cannot be empty! $Reset"
        return 1
    elif [[ $name = [0-9]* ]]; then
        echo -e "$Red Error 101: Name of DB Can't Start Numbers $Reset"
        return 1
    
    elif [[ ! $name =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo -e "$Red Error 104: Name Contains Special Characters $Reset"
        return 1
    fi
    if [[ -z $(tr -d '_' <<< "$name") ]]; then
        echo -e "$Red Error: Name must contain at least one letter or number. $Reset"
        return 1
    fi

     for word in "${RESERVED_WORDS[@]}"; do
        if [[ "$name" == "$word" ]]; then
            echo -e "$Red Error: Name '$name' is a reserved word! $Reset"
            return 1
        fi
    done
    return 0
}

check_dbms() {
    
     if [[ ! -d "./DBMS"  ]]; then
        echo "DBMS folder not found, creating it..."
        mkdir -p "./DBMS"
    fi
    
    if [[ -z "$(ls -A ./DBMS 2>/dev/null)" ]]; then
    echo "The DBMS folder is empty."
    fi
}

check_dbms() {
    if [[ ! -d "./DBMS" ]]; then
        echo "DBMS not Found,Initializing DBMS for the first time..."
        mkdir -p "./DBMS"
        chmod 777 "./DBMS"
    fi
}

check_dbs() {
    if [[ -z "$(ls -A ./DBMS 2>/dev/null)" ]]; then
        echo -e "$Red Error: No Databases found in the system. $Reset"
        return 1 
    else
        return 0 
    fi
}
show_table() {
    table_file="$DB_PATH/$table_name"
    
    if [[ ! -f "$table_file" ]]; then
        echo -e "\nError: Table '$table_name' not found!"
        return
    fi

    echo -e "\n--- Table: [ $table_name ] ---"
    
    if [[ ! -s "$table_file" ]]; then
        echo "Table is empty."
    else
        column -t -s ':' "$table_file" | sed 's/^/  /'
    fi
    echo "------------------------------"
}
match_type() {
    if [[ "$col_type" == "date" ]]; then
        echo -e "$Cyan Hint: Please enter date in this format: [YYYY-MM-DD] (e.g., 2026-01-20)$Reset"
    fi

    read -r -p "Enter value for '$col_name' ($col_type): " value < /dev/tty
    
    value=$(tr " " "_" <<< "$value")

    if [[ "$value" == *":"* ]]; then
        echo -e "$Red Error: Value cannot contain ':' $Reset"
        return 1
    fi

    if [[ "$col_type" == "int" ]]; then
        if [[ -z "$value" || "$value" == *[!0-9]* ]]; then
            echo -e "$Red Error: '$col_name' must be integer (digits only).$Reset"
            return 1
        fi

    elif [[ "$col_type" == "string" ]]; then
        if [[ -z "$value" ]]; then
            echo -e "$Red Error: '$col_name' cannot be empty.$Reset"
            return 1
        fi

    elif [[ "$col_type" == "bool" ]]; then
        if [[ "$value" != "true" && "$value" != "false" ]]; then
            echo -e "$Red Error: '$col_name' must be 'true' or 'false'.$Reset"
            return 1
        fi

      elif [[ "$col_type" == "date" ]]; then
        if [[ "$value" != [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ]]; then
            echo -e "$Red Error: Wrong Format! Use YYYY-MM-DD.$Reset"
            return 1
        fi
        if ! date -d "$value" "+%Y-%m-%d" >/dev/null 2>&1; then
            echo -e "$Red Error: Logical Date Error (Check month/day values).$Reset"
            return 1
        fi
    fi

    return 0
}



list_tables() {
    tables_list=$(ls "$DB_PATH" 2>/dev/null | grep -v "^\.")

    if [[ -z "$tables_list" ]]; then
        echo -e "$Red Error 404: No tables found in this database! $Reset"
        return 1 
    else
        echo -e "$Cyan Current Tables in Database '$DB_NAME': $Reset"
        echo "----------------------"
        while read -r table; do
            if [[ -n "$table" ]]; then
                echo -e "$Green - $table $Reset"
            fi
        done <<< "$tables_list"
        echo "----------------------"
        return 0  
    fi
}


prepare_columns() {
    fline=$(sed -n '1p' "$table_file")
    columns=($(echo "$fline" | tr ':' ' '))
    num_cols=$(awk 'NR==1 {print $NF}' "$meta_file")
    meta_only=$(sed '1d' "$meta_file")
    if [[ $num_cols -le 0 ]]; then
        echo -e "$Red Error: No columns found in table! $Reset"
        return 1
    fi
    echo "Available columns:"
    awk -F: 'NR>1 {print $2 ") " $3}' "$meta_file"

}


Main_Menue(){
 echo -e "$Cyan Info 302: Returning to Main Menu... $Reset"
  echo "------------------------------------------"
  echo "1) Create_DB"
  echo "2) List_All_DB"
  echo "3) ConnectDB"
  echo "4) RemoveDB"
  echo "5) Exit"
  echo "------------------------------------------"
}

Table_Menu() {
    echo -e "$Cyan Info 301: Returning to Table Menu... $Reset"
    echo "------------------------------------------"
    echo  " 1) Create Table "
    echo  " 2) List All Tables "
    echo  " 3) Insert_in_Table "
    echo  " 4) Drop_Table "
    echo  " 5) Select_From_Table "
    echo  " 6) Delete_From_Table "
    echo  " 7) Update_Table "
    echo  " 8) Exit "
    echo "------------------------------------------"
}

Selaction_Menu(){
    echo -e "$Cyan Info 300: Returning to Selection Menu... $Reset"
    echo "------------------------------------------"
    echo "1) Select_ALL              3) Select_Specific_Columns   5) Table_Menu"
    echo "2) Select_By_Column        4) Selection_Menu"
    echo "------------------------------------------"
}
Delete_Menu(){
  echo -e "$Cyan Info 300: Returning to Delete Menu... $Reset"
  echo "------------------------------------------"
  echo "Delete Menue :"
  echo "1) Delete_ALL"
  echo "2) Delete_By_Culome"
  echo "3) Table_Menue"
  echo "------------------------------------------"
}