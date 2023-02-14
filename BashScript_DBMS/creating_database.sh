#!/bin/bash

#creating a new database by checking two things
# 1- its existence in my Database system
# 2- a valid name

echo "Enter the database name: " 
read DataBaseName

#checking the name validity using regex
while ! [[ $DataBaseName =~ ^[a-zA-Z_][a-zA-Z0-9_\$\@#]*$ ]]; do
	echo "Enter a valid name that satisfys MYSQL naming convention"
	read -p "Enter the database name :  " DataBaseName
done

#checking the existence of the database
if [[ -d ./MyDataBases/$DataBaseName ]]; then
	echo "This name already exists, choose another name"
	. ./creating_database.sh
else
	mkdir ./MyDataBases/"$DataBaseName"
	echo "DataBase: $DataBaseName was created Successfully"
fi
	
