#!/bin/bash
source ./Funcations/sharefun.sh

remove_db() {
    check_dbs || return   

    list=$(ls -F ./DBMS | grep '/' | tr -d '/')
    
    echo -e "$Cyan Select Database to Remove:$Reset"
    export PS3="RemoveDB>> "
    
    select dbName in $list
    do   
        if [[ -n "$dbName" ]]; then 
            if [[ -d "./DBMS/$dbName" ]]; then
                echo -e "$Yellow Deleting database '$dbName' ... Please wait.$Reset"
                if rm -r "./DBMS/$dbName" 2>/dev/null; then
                    sleep 1 
                    echo -e "$Green Success: Database '$dbName' deleted successfully.$Reset"
                else
                    echo -e "$Red Error 403: Permission denied while deleting '$dbName'.$Reset"
                fi
            else
                echo -e "$Red Error 404: Database '$dbName' does not exist.$Reset"
            fi
            break 
        else 
            echo -e "$Red Error 400: Invalid selection. Please choose a valid number.$Reset"
        fi 
    done 
    export PS3="minaDB>>"
}
