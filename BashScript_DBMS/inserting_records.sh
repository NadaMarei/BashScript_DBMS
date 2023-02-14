#!/bin/bash

#inserting into a new table by checking
# 1- validity of inputs
# 2- constraints violations
record=""
Separator=":"

#getting the number of fields

read -p "Enter table name : " TableName

if ! [[ -f ./MyDataBases/$DataBaseName/${TableName}_ ]];then
    echo "this table does not exist in your database, choose again"
    . ./inserting_records.sh
else
#getting the number of columns
   ColumnNumbers= $(cat ./MyDataBases/$DataBaseName/${TableName}_ | wc -l)
   for (( i=2 ; i<=${ColumnNumbers} ; i++ )); do
    # get the meta data
    ColumnName=$(awk 'BEGIN{FS=":"}{ if(NR=='$i') print $1}' ./MyDataBases/$DataBaseName/${TableName}Meta)
    ColumnType=$(awk 'BEGIN{FS=":"}{if(NR=='$i') print $2}' ./MyDataBases/$DataBaseName/${TableName}Meta)	   
    ColumnConstraint=$( awk 'BEGIN{FS=":"}{if(NR=='$i') print $3}' ./MyDataBases/$DataBaseName/${TableName}Meta)
	
	read -p "Enter data of type $ColumnType into $ColumnName: " field

	# Validate Input
	while [[ true ]]; do
	    if [[ $ColumnType == "number" ]]; then
	    	while ! [[ $field =~ ^[0-9]*$ ]]; do
        		read "This is not a number Enter a number: " field
      		done
    	    fi
    	    if [[ $ColumnConstraint == "PK" ]]; then
      		FieldExistence=$(grep -c '^field:' ./MyDataBases/$DataBaseName/${TableName}_ )
        	if [[ FieldExistence == 1  ]]; then
          		read -p "This field already exists" field
          		continue
        	else
          		break
              fi
           fi
      	  done
     record=${record}${field}${separator}
     done
fi

echo $record >> ./MyDataBases/$DataBaseName/${TableName}_



