#!/bin/bash

PSQL="psql -X -d periodic_table -U freecodecamp -t -c"

if [[ ! $1 ]]; then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]; then
    read ATOMIC_NUMBER _ SYMBOL _ NAME < <(echo $($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number=$1"))
  elif [[ $1 =~ ^[[:alpha:]]+$ ]]; then
    read ATOMIC_NUMBER _ SYMBOL _ NAME < <(echo $($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol='$1' OR name='$1'"))
  else  
    echo "I could not find that element in the database."
    exit 1
  fi

  if [[ -z $ATOMIC_NUMBER || -z $SYMBOL || -z $NAME ]]; then
    echo "I could not find that element in the database."
  else
    read ATOMIC_MASS _ MELTING_POINT _ BOILING_POINT _ TYPE < <(echo $($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER"))
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi