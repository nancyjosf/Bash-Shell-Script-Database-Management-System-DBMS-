create_db() {
    check_dbms || return 
    
    read -r -p "Enter Name of DB : " input 
    input=$(tr " " "_" <<< "$input") 

    if IsValidName "$input"; then
        if [[ -d "./DBMS/$input" ]]; then 
            echo -e "$Red Error 103: Name of DB Already Exist $Reset"  
        else
            echo "Wait Create DB ......"
            if mkdir -p "./DBMS/$input"; then 
                sleep 1
                echo -e "$Green Success 203: DB '$input' created successfully. $Reset"
            else 
                echo -e "$Red The operation failed. Check permissions. $Reset"
            fi 
        fi 
    fi
}