#!/bin/bash

PSQL="psql -U freecodecamp -d number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ $USER_ID ]]; then
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME_GUESSES=$($PSQL "SELECT MIN(guesses_count) FROM games WHERE user_id=$USER_ID")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME_GUESSES guesses."
else
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  _=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
fi

function GUESS_MENU() {
  read GUESS

  until [[ $GUESS =~ ^[0-9]+$ ]]; do
    echo -e "\nThat is not an integer, guess again:"
    GUESS_MENU
  done
}

echo -e "\nGuess the secret number between 1 and 1000:"
GUESS_MENU

GUESSES_COUNT=0  # because needs to be incremented after until loop

NUMBER=$(($RANDOM % 1000 + 1))

until (( $GUESS == $NUMBER )); do
  if (( $NUMBER < $GUESS )); then
    echo -e "\nIt's lower than that, guess again:"
  elif (( $NUMBER > $GUESS )); then
    echo -e "\nIt's higher than that, guess again:" 
  fi

  GUESS_MENU

  GUESSES_COUNT=$(($GUESSES_COUNT + 1))
done

GUESSES_COUNT=$(($GUESSES_COUNT + 1))

_=$($PSQL "INSERT INTO games(user_id, guesses_count) VALUES($USER_ID, $GUESSES_COUNT)")

echo -e "\nYou guessed it in $GUESSES_COUNT tries. The secret number was $NUMBER. Nice job!"
