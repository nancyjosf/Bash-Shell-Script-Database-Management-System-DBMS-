#! /bin/bash
source ./Funcations/sharefun.sh

list_dbs() {
    check_dbms || return
    
    data=$(ls -F ./DBMS 2>/dev/null | grep '/' | tr -d '/')

    if [[ -z $data ]]; then 
        echo -e "$Red Error 107 : DBMS Empty $Reset"
    else
        echo -e "$Green Current Databases: $Reset"
        echo "----------------------"
        echo "$data" | while read -r line; do
            echo " - $line"
        done
        echo "----------------------"
    fi 
}