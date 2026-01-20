#!/bin/bash
source ./Funcations/sharefun.sh

connect_db() {

    local old_ps3="$PS3"

    trap 'echo -e "\n$Yellow [!] Connection aborted. Returning to Main Menu... $Reset";
          PS3="$old_ps3";
          trap - SIGINT;
          return' SIGINT

    check_dbms || return

    # جلب قواعد البيانات
    mapfile -t list < <(ls -d "$REAL_PATH/DBMS"/*/ 2>/dev/null | xargs -n 1 basename)

    if [[ ${#list[@]} -eq 0 ]]; then
        echo -e "$Yellow Error 404: No databases found to connect.$Reset"
        trap - SIGINT
        return
    fi

    echo -e "$Cyan Select a database to connect:$Reset"
    PS3="ConnectDB>> "

    select dbName in "${list[@]}" "Back_to_Main_Menu"
    do
        # رجوع للـ Main Menu
        if [[ "$dbName" == "Back_to_Main_Menu" ]]; then
            PS3="$old_ps3"
            trap - SIGINT
            return
        fi

        # اختيار غير صحيح
        if [[ -z "$dbName" ]]; then
            echo -e "$Red Error 101: Invalid selection. Please choose a valid number.$Reset"
            continue
        fi

        # تحقق من وجود قاعدة البيانات
        if [[ ! -d "$REAL_PATH/DBMS/$dbName" ]]; then
            echo -e "$Red Error 404: Database '$dbName' does not exist.$Reset"
            continue
        fi

        echo -e "$Green Success 200: Connected to database '$dbName'.$Reset"

        export DB_PATH="$REAL_PATH/DBMS/$dbName"
        export DB_NAME="$dbName"

        # دخول Table Menu
        if [[ -f "./Funcations/tables.sh" ]]; then
            source ./Funcations/tables.sh
        else
            echo -e "$Red Error 503: tables.sh not found.$Reset"
        fi

        # بعد الخروج من Table Menu نرجع للـ Main Menu
        PS3="$old_ps3"
        trap - SIGINT
        return
    done
}
