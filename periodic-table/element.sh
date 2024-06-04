#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

CHECK_IF_EXIST () {
  if [[ -z $1 ]]; then
    echo "I could not find that element in the database."
    exit 0
  fi
}

WRITE_OUTPUT () {
  echo "The element with atomic number $1 is $2 ($3). It's a $4, with a mass of $5 amu. $2 has a melting point of $6 celsius and a boiling point of $7 celsius."
}

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

REGEX_NUMBER='^[0-9]+$'
REGEX_ELEMENT_SYMBOL='^[A-Z][a-z]?$'
REGEX_ELEMENT_NAME='^[A-Z][a-z]+'

if [[ $1 =~ $REGEX_NUMBER ]]; then
  ELEMENT_DATA=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number = $1")
elif [[ $1 =~ $REGEX_ELEMENT_SYMBOL ]]; then
  ELEMENT_DATA=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE symbol = '$1'")
elif [[ $1 =~ $REGEX_ELEMENT_NAME ]]; then
  ELEMENT_DATA=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE name = '$1'")
fi 

CHECK_IF_EXIST $ELEMENT_DATA
echo "$ELEMENT_DATA" | while read ATOMIC_NUMBER BAR NAME BAR SYMBOL BAR TYPE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT
do
  WRITE_OUTPUT $ATOMIC_NUMBER $NAME $SYMBOL $TYPE $ATOMIC_MASS $MELTING_POINT $BOILING_POINT
  exit 0
done
