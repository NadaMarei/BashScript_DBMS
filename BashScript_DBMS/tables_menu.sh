#!/bin/bash


#Starting the tables menu

PS3="Table_Menu: Type the number of your choice: "

function table_menu {
	echo $'Please choose an option: \n'
	select action in 'Create Table' 'List Tables' 'Drop Table' 'Insert into Table' 'Select From Table' 'Delete From Table' 	'Update Table' 'Main Menu' 'Exit'
		do
			case $action in
			'Create Table') 
				createTable;;
			'List Tables') 
				listTable;;
			'Drop Table') 
				dropTable;;
			'Insert into Table') 
				insertRecord;;
			'Select From Table') 
				listTable
				selectRecord;;
			'Delete From Table') 
				deleteRecord;;
			'Update Table') 
				updateRecord;;
			'Main Menu') 
				. ./opening_menu.sh;;
			'Exit') 
				clear
				echo -e "See you later, Thanks for using our DBMS :)\n" 
				exit;;
			*)
				echo "Invalid choice, Redirecting to main menu..." 
				sleep 2
				. ./opening_menu.sh;;
			esac
	done
}
function createTable {
	cd ./MyDataBases/$database 2> /dev/null
	echo $'Please enter table name to create it: \n'
	read table 2> /dev/null
	if [[ -f $table ]]
	then 
		echo "table already exists!"
		cd ../..
		. ./connecting_database.sh
	else
		touch $table
		echo "table created succesfully!"
	fi
	
	echo "Please enter Number of fields: "
	read fields 2> /dev/null
	num='^[0-9]+$'
	if  [[ $fields =~ $num ]]
	then 
		# Primary Key mark
		mark="true"
		for (( i=1; i<=$fields ; i++ ))
		do
			echo "Please enter name for field no.$i: "
			read colname
			# setting Primary Key for the field
			while [ $mark == "true" ]
			do
				echo "Is this a Primary Key? [Y/N]"
				read pk
				if [[ $pk == "Y" || $pk == "y" || $pk == "yes" ]]
				then
				# change the value of the mark so never enter the loop again if the user select a field as PK 
					mark="false"
				#  echo [-n] no new line so it will append (PK) to the field name 
					echo -n "(PK)" >> $table
				else
					break
				fi
			done
			
			# setting column data type
			while true
			do 
				echo "Choose data type from (int , varchar)"
				read datatype 2> /dev/null
				case $datatype in
				# append data type to the field name
					int)
					echo -n $colname"($datatype);" >> $table;;
					varchar)
					echo -n $colname"($datatype);" >> $table;;
					*)
					echo "Incorrect Data type!"
					continue;
				esac
				break
				
			done
	
		done
		
		#end of table header
		echo $'\n' >> $table 
		echo "Your table $table created"
		#redirect to tables_menu
		cd ../..
		table_menu
	else
	# if user enter anything except numbers
		echo "$fields is not a valid input. Please enter numbers only !"
		sleep 2
		createTable
	fi	
}

#listing tables inside selected database
function listTable {
	echo -e "your current tables are:\n"
	ls ./MyDataBases/$database/ 2>> /dev/null
}

# Remove the table 
function dropTable {
	#list available tables & send errors to /dev/null
	listTable 2> /dev/null
	echo $'Table name to be deleted:\t'
	read tablename 2> /dev/null
	cd ./MyDataBases/$database/ 2> /dev/null
	if [[ -f $tablename ]]
	then 
		rm $tablename
		echo "$tablename is deleted!"	
	else
		echo "No matching table name"

	fi
	cd ../..
	table_menu
}

#insert records to the selected table
function insertRecord {
	listTable 2> /dev/null
	cd ./MyDataBases/$database/ 2> /dev/null
	echo "Please enter table name to insert data: "
	read table 2> /dev/null
	if [[ -f $table ]]
		then
			# grep [-o] Print only the matched (non-empty) parts of a matching line, with each such part on a separate output line.
			# get number of fields that contain the word PK (header)
			x=`grep 'PK' $table | grep -o ";" | wc -l` 
			for ((i=1;i<=x;i++)) 
			do      
				# cut to return fileds of the header
				columnName=`grep PK $table | cut -f$i -d";"`
				echo $'\n'
				echo $"Please enter data for field no.$i [$columnName]"
				read data 2> /dev/null
				checkType $i $data
				# if [checkType $i $data ] is false so result will be any number except 0
				if [[ $? != 0 ]]
				then
					(( i = $i - 1 ))
			        # if [checkType $i $data ] is true we will add the data to the column then seperate using ;
				else	
					echo -n $data";" >> $table
				fi
			done	
			echo $'\n' >> $table #end of record
			echo "insert done into $table"
		else
			echo "Table doesn't exist"
			echo "Do you want to create it? [y/n]"
			read answer 2> /dev/null
			case $answer in
				y) createTable
					;;
				n) insertRecord
					;;
				*) echo "Incorrect response. Redirecting to main menu..." ;
					sleep 2;
				cd ../..;
				. ./opening_menu.sh
				;;
			esac
			
		fi
		cd ../..
		table_menu
}


function selectRecord {
	cd ./MyDataBases/$database/ 2> /dev/null
	echo "Please enter table name to select data: "
	read table 2> /dev/null
	if [[ -f $table ]]
	then
		echo $'\n'
			#to print the header of the selected table
			awk 'BEGIN{FS=";"}{if (NR==1) {for(i=1;i<=NF;i++){printf "----||----"$i}{printf "----|"}}}' $table
			echo $'\nWould you like to print all records? [y/n]'
			read printall 2> /dev/null
			if [[ $printall == "Y" || $printall == "y" || $printall == "yes" ]]
			then
				echo $'\nWould you like to print a specific field? [y/n]'
				read cut1 2> /dev/null
				if [[ $cut1 == "Y" || $cut1 == "y" || $cut1 == "yes" ]]
				then
					echo $'\nPlease specify field number: '
					read fieldnumber 2> /dev/null
					echo $'------------------------------'
					#print all records for the selected column
					awk $'{print $0\n}' $table | cut -f$fieldnumber -d";" 2> /dev/null
					echo $'------------------------------'
				else
					echo $'\n'
					echo $'------------------------------'
					#print the content of the table in the form of coulmns (display as a table)
					column -t -s ';' $table 2> /dev/null
					echo $'------------------------------\n'
				fi
			else
				echo $'\nPlease enter a value you want to search to select record(s): '
				read value 2> /dev/null
				echo $'\nWould you like to print a specific field? [y/n]'
				read cut 2> /dev/null
				if [[ $cut == "Y" || $cut == "y" || $cut == "yes" ]]
				then
					echo $'\nPlease specify field number: '
					read field 2> /dev/null
					echo $'------------------------\n'
					# find the pattern in records |> for that specific field
					awk -v pat=$value $'$0~pat{print $0\n}' $table | cut -f$field -d";"
					
				else
					echo $'------------------------\n'
					# find the pattern in records |> for all fields |> as a table display 
					awk -v pat=$value '$0~pat{print $0}' $table | column -t -s ';'
						
				fi
		fi
		echo $'\nWould you like to make another query? [y/n]'
		read answer 2> /dev/null
		if [[ $answer == "Y" || $answer == "y" || $answer == "yes" ]]
		then
			selectRecord
		elif [[ $answer == "N" || $answer == "n" || $answer == "no" ]]
		then	
			
			cd ../..
			. ./connecting_database.sh
		else
			echo $'Invalid choice\n'
			echo "Redirecting to main menu..."
			cd ../..
			sleep 2
			. ./opening_menu.sh
		fi
	else
		echo "Table doesn't exist"
		echo "Do you want to create it? [y/n]"
		read answer 2> /dev/null
		case $answer in
			y)
			createTable;;
			n)
			selectRecord;;
			*)
			echo "Incorrect answer. Redirecting to main menu..." ;
			sleep 2;
			cd ../..;
			. ./opening_menu.sh;;
		esac
	fi
	cd ../..
	table_menu
}


# Delete Record

function deleteRecord {
	listTable 2> /dev/null
	cd ./MyDataBases/$database/ 2> /dev/null
	echo "Please enter table name to delete from: "
	read table 2> /dev/null
	if [[ -f $table ]]
	then
			#print table header
			awk 'BEGIN{FS=";"}{if (NR==1) {for(i=1;i<=NF;i++){printf "----||----"$i}{print "---|"}}}' $table
			echo  "Enter Column name:"
			read field 2>> /dev/null

			# get the field number
			fieldNumber=$(awk 'BEGIN{FS=";"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i }}}' $table )
			if [[ $fieldNumber == "" ]]
			then
				echo "Not Found"
				table_menu
			else
				echo "Enter Value:"
				read value 2>> /dev/null
				result=$(awk 'BEGIN{FS=";"}{if ($'$fieldNumber'=="'$value'") print $'$fieldNumber'}' $table 2>> /dev/null)

				if [[ $result == "" ]]
				then
					echo "Value Not Found"
					table_menu
				else
					# get the record number to be deleted
					NR=$(awk 'BEGIN{FS=";"}{if ($'$fieldNumber'=="'$value'") print NR}' $table 2>> /dev/null)
					# delete the record
					sed -i ''$NR'd' $table 2>> /dev/null
					echo "Row Deleted Successfully"
					table_menu
				fi
			fi
	else
		echo "Table doesn't exist"
	fi
	cd ../..
	table_menu
}

function updateRecord {
	listTable 2> /dev/null
	cd ./MyDataBases/$database/ 2> /dev/null
	echo "Enter Table Name:"
	read table 2> /dev/null
	#print table header
	awk 'BEGIN{FS=";"}{if (NR==1) {for(i=1;i<=NF;i++){printf "----||----"$i}{print "---|"}}}' $table
	echo "Enter Column name: "
	read field 2> /dev/null
	#get field Number
	fieldNumber=$(awk 'BEGIN{FS=";"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i }}}' $table )
	if [[ $fieldNumber == "" ]]
	then
		echo "Not Found"
		table_menu
	else
		echo "Enter Value:"
		read value 2> /dev/null
		#if the field number = user value store field number in result
		result=$(awk 'BEGIN{FS=";"}{if ($'$fieldNumber'=="'$value'") print $'$fieldNumber'}' $table 2>> /dev/null)
		if [[ $result == "" ]]
		then
		echo "Value Not Found"
		table_menu
		else
			echo "Enter new Value to set:"
			read newValue 2>> /dev/null
			NR=$(awk 'BEGIN{FS=";"}{if ($'$fieldNumber' == "'$value'") print NR}' $table 2>> /dev/null)
			echo $recordNumber
			oldValue=$(awk 'BEGIN{FS=";"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$fieldNumber') print $i}}}' $table 2>> /dev/null)
			echo $oldValue
			#substitute globally the oldvalue with the newvalue
			sed -i ''$NR's/'$oldValue'/'$newValue'/g' $table 2>> /dev/null
			echo "Row Updated Successfully"
			table_menu
		fi
	fi
	cd ../..
	table_menu
}

# checktype --> fieldnumber data_for_that_field
function checkType {
	#cut to return the header field datatype 
	datatype=`grep PK $table | cut -f$1 -d";"` 2>> /dev/null

	# colname(int) => get in the () only
	# tests if the contents of $datatype contains an *int* 
	if [[ "$datatype" == *"int"* ]]
	then
	
		num='^[0-9]+$'
		if ! [[ $2 =~ $num ]]
		then
		#if it is not number
			echo "Invalid input: Not a number!"
			return 1
		else
		# if enterd a number check is this a PK field or not
			checkPK $1 $2
		fi
	# colname(varchar) => get in the () only
	# tests if the contents of $datatype contains an *varchar* 
	elif [[ "$datatype" == *"varchar"* ]] 
	then
		# check if the data enterd by user is string or not
		varchar='^[a-zA-Z]+$'
		if ! [[ $2 =~ $varchar ]]
		then
		#if it is not string
			echo "Invalid input: Not a valid string!"
			return 1
		# if enterd a string check is this a PK field or not
		else
			checkPK $1 $2
		fi
	fi
}

# check the existence of the PK --> fieldnumber  data_For_That_Field

function checkPK {
#cut to return the header field datatype
header=`grep PK $table | cut -f$1 -d";"` 2>> /dev/null

#*PK* zero or more of any charachter followed by the excact sequence PK 
#tests if the contents of $header contains an *PK*
if [[ "$header" == *"PK"* ]]
then
# cut to check if there is a value in the PK column matches the value that user enter.
	if [[ `cut -f$1 -d";" $table | grep -w $2` ]]
	then
		echo $'\nPrimary Key already exists. no duplicates allowed!' 
		return 1
	fi
fi
}
table_menu

