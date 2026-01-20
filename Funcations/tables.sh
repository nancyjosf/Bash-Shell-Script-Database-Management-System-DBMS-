#! /bin/bash
#meta file
# Table Name: class | Columns: 2
# PK:1:name:int
# Col:2:chair:string

#data file
#id:name:passed
#1:nancy:2005
#5:maina:2003
#4:afrim:2003

source ./Funcations/sharefun.sh
source ./Funcations/DeleteFromTable.sh
source ./Funcations/SelectFromTable.sh
source ./Funcations/InsertItoTable.sh
source ./Funcations/CreateTable.sh
source ./Funcations/DropTable.sh
source ./Funcations/UpDateTable.sh

echo -e "$Cyan ===================================== $Reset"
echo -e "$Cyan       Welcome to Table Menu       $Reset"
echo -e "$Cyan ===================================== $Reset"

PS3="$DB_NAME>> "
table_menu=("Create_Table" "List_All_Tables" "Insert_in_Table" "Drop_Table" "Select_From_Table" "Delete_From_Table" "Update_Table" "Exit")

select variable in "${table_menu[@]}"
do 
    case $REPLY in 
    1 | "Create_Table") 
        echo -e "$Purple Selected: Create Table$Reset"
        create_table 
        Table_Menu
        ;;

    2 | "List_All_Tables")
        echo -e "$Purple Selected: List All Tables$Reset"
        list_tables 
        Table_Menu
        ;;

    3 | "Insert_in_Table")
        echo -e "$Purple Selected: Insert Into Table$Reset"
        insert_into_table 
        Table_Menu
        ;; 

    4 | "Drop_Table")
        echo -e "$Purple Selected: Drop Table$Reset"
        drop_table
        Table_Menu
        ;;

    5 | "Select_From_Table")
        echo -e "$Purple Selected: Select From Table$Reset"
        Select_From_Table
        Table_Menu
        ;;

    6 | "Delete_From_Table")
        echo -e "$Purple Selected: Delete From Table$Reset"
        Delete_From_Table
        Table_Menu
        ;;    
    
    7 | "Update_Table")
        echo -e "$Purple Selected: Update Table$Reset"
        update_table
        Table_Menu
        ;; 

    8 | "Exit")
        echo -e "$Yellow Returning to Main Menu... $Reset"
        
        break 
        
        ;;

    *)
        echo -e "$Red Error 400: Invalid Option! Please try again.$Reset"
        ;;
    esac 
done
