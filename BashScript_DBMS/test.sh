#!/bin/bash


read -p "Enter the database name: " DataBaseName
read -p "Enter the : " sec

#checking the existence of the database
    select i in "number" "char"; do
        case $i in
        number)
            ColumnType="number"
            break;;
        char)
            ColumnType="char"
            break;;
        *)
            echo Choose either int or string;;
        esac
    done
    i+=$i
    echo $i
