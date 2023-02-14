#!/bin/bash

#deleting one of the available databases

read -p "Enter the database name: " DataBaseName


#checking the existence of the database
if ! [[ -d ./MyDataBases/$DataBaseName ]]; then
	echo "There is no such name, pelase choose another name"
	. ./deleting_database.sh
else
	rm -r ./MyDataBases/"$DataBaseName"
	echo "DataBase: $DataBaseName was deleted Successfully"
fi
	
