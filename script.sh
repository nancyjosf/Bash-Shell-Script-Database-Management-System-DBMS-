#!/bin/bash
#Must use abslute bath
echo -e "$Cyan Running DBMS System...$Reset"

REAL_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "$REAL_PATH"

chmod +x ./*.sh ./Funcations/*.sh 2>/dev/null
chmod -R 777 ./DBMS/ 2>/dev/null

source ./Funcations/sharefun.sh
source ./Funcations/CreateDB.sh
source ./Funcations/ListAllDB.sh
source ./Funcations/ConnectDB.sh
source ./Funcations/RemoveDB.sh

echo -e "$Purple ===================================== $Reset"
echo -e "$Purple   Welcome to Our DBMS System   $Reset"
echo -e "$Purple ===================================== $Reset"
echo -e "$LightGreen Main Menu:$Reset"

LC_COLLATE=C 
shopt -s extglob 
export PS3="minaDB>> "

check_dbms || return

menu=("Create_DB" "List_All_DB" "Connect_DB" "Remove_DB" "Exit")

select variable in "${menu[@]}"
do
    case $REPLY in 
    1 | "Create_DB" ) 
        echo -e "$Purple Selected: Create Database$Reset"
        create_db 
        Main_Menue
      ;;

    2 | "List_All_DB")
        echo -e "$Cyan Selected: List All Databases$Reset"
        list_dbs
        Main_Menue
    ;;

    3 | "Connect_DB")
        echo -e "$Purple Selected: Connect to Database$Reset"
        connect_db
        
    ;;

    4 | "Remove_DB")
        echo -e "$Purple Selected: Remove Database$Reset"
        remove_db
        list_dbs
        Main_Menue
    ;;

    5 | "Exit")
        echo -e "$Purple Exiting DBMS... Goodbye! 👋 $Reset"
        exit 
    ;;

    *)
        echo -e "$Red Error 400: Invalid option. Please select a valid number.$Reset"
    ;;
    esac    
done
