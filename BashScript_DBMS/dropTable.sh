#! /bin/bash 

# Remove the table 
function dropTable {
        . ./listTables.sh
        echo $'Table name to be deleted:\t'
        read tablename

        if [[ -f $tablename ]]
        then 
             	rm $tablename
                echo "$tablename is deleted!"
        else
            	echo "No matching table name"

        fi
}

dropTable
