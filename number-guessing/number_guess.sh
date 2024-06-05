#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo "Enter your username:"
read USERNAME

CHECK_USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ -z $CHECK_USER_ID ]]; then
  IS_NEW_USER="true"

  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ADD_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  USER_ID=$(echo $USER_ID | sed -r 's/^ *| *$//g')
else
  IS_NEW_USER="false"
  USER_ID=$(echo $CHECK_USER_ID | sed -r 's/^ *| *$//g')

  GAME_HISTORY_RESULT=$($PSQL "SELECT games_played, best_game FROM game_history WHERE user_id = $USER_ID")
  IFS='|' read -r GAMES_PLAYED BEST_GAME <<< "$GAME_HISTORY_RESULT"
  GAMES_PLAYED=$(echo $GAMES_PLAYED | sed -r 's/^ *| *$//g')
  BEST_GAME=$(echo $BEST_GAME | sed -r 's/^ *| *$//g')
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

RANDOM_NUMBER=$(( (RANDOM % 1000) + 1 ))
NUMBER_OF_GUESS=0
NUMBER_REGEX='^[0-9]+$'

while true; do
  read USER_INPUT
  ((NUMBER_OF_GUESS++))

  if [[ ! $USER_INPUT =~ $NUMBER_REGEX ]]; then
    echo "That is not an integer, guess again:"
  elif (( $USER_INPUT > $RANDOM_NUMBER )); then
    echo "It's lower than that, guess again:"
  elif (( $USER_INPUT < $RANDOM_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( $USER_INPUT = $RANDOM_NUMBER )); then
    echo "You guessed it in $NUMBER_OF_GUESS tries. The secret number was $RANDOM_NUMBER. Nice job!"
    break
  fi
done

if [[ $IS_NEW_USER = "true" ]]; then
  ADD_GAME_HISTORY_RESULT=$($PSQL "INSERT INTO game_history(user_id, games_played, best_game) VALUES($USER_ID, 1, $NUMBER_OF_GUESS)")
else
  if [[ $NUMBER_OF_GUESS < $BEST_GAME ]]; then
    BEST_GAME=$NUMBER_OF_GUESS
  fi

  ((GAMES_PLAYED++))
  ADD_GAME_HISTORY_RESULT=$($PSQL "UPDATE game_history SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE user_id = $USER_ID")
fi