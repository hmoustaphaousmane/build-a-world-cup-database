#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate the tables
echo $($PSQL "truncate teams, games;")

INSERT_TEAM() {
  # echo $1
  INSERT_TEAM_RESULT=$($PSQL "insert into teams(name) values('$1');")
  if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
  then
    echo Inserted into teams, $1
  fi
}

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    # get team_id

    # get winner_id
    WINNER_ID=$($PSQL "select team_id from teams where name = '$WINNER';")

    # if not found
    if [[ -z $WINNER_ID ]]
    then
      # insert winner team into teams
      INSERT_TEAM "$WINNER"

      # get new winner team_id
      WINNER_ID=$($PSQL "select team_id from teams where name = '$WINNER';")
    fi

    # get opponent_id
    OPPONENT_ID=$($PSQL "select team_id from teams where name = '$OPPONENT';")

    # if not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert opponent team into teams
      INSERT_TEAM "$OPPONENT"

      # get new oppenent team_id
      OPPONENT_ID=$($PSQL "select team_id from teams where name = '$OPPONENT';")
    fi

    # get game_id
    GAME_ID=$($PSQL "select game_id from games where year = $YEAR and round = '$ROUND' and winner_id = $WINNER_ID and opponent_id = $OPPONENT_ID;")

    # if not found
    if [[ -z $GAME_ID ]]
    then
      # insert game
      INSERT_GAME_RESULT=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
      if [[ $INSERT_GAME_RESULT = "INSERT 0 1" ]]
      then
        echo Insert into games, $YEAR - $ROUND $WINNER : $WINNER_GOALS vs. $OPPONENT : $OPPONENT_GOALS
      fi

      # get new game_id
      GAME_ID=$($PSQL "select game_id from games where year = $YEAR and round = '$ROUND' and winner_id = $WINNER_ID and opponent_id = $OPPONENT_ID;")
    fi
  fi
done