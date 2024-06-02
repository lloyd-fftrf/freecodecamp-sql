#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#######
## ADDING TEAMS DATA TO THE TEAMS TABLE
#######

UNIQUE_TEAMS=()
while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  if [[ $YEAR != 'year' ]]; then
    WINNER_TEAM_EXIST=false
    for team in "${UNIQUE_TEAMS[@]}"; do
      if [[ "$team" = "$WINNER" ]]; then
        WINNER_TEAM_EXIST=true
        break
      fi
    done

    if [[ $WINNER_TEAM_EXIST == "false" ]]; then
      UNIQUE_TEAMS+=("$WINNER")
      echo $($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")
    fi

    OPPONNENT_TEAM_EXIST=false
    for team in "${UNIQUE_TEAMS[@]}"; do
      if [[ "$team" = "$OPPONENT" ]];then
        OPPONNENT_TEAM_EXIST=true
        break
      fi
    done

    if [[ $OPPONNENT_TEAM_EXIST == "false" ]]; then
      UNIQUE_TEAMS+=("$OPPONENT")
      echo $($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")
    fi
  fi
done < games.csv


#######
## ADDING GAMES DATA
#######
while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  if [[ $YEAR != 'year' ]]; then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

    echo $($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done < games.csv