#!/bin/bash

# Params
PGHOST=${PGHOST:-host.docker.internal}
PGUSER=${PGUSER:-postgres}
PGPASSWORD=${PGPASSWORD:-postgres}
PGDATABASE=${PGDATABASE:-ideahor}

# Params
GIT_REPO=${GITREPO:-"null"}
GIT_BRANCH=${GITBRANCH:-"master"}

DATE=$(date +%s)

# log file
LOG_DIR="/var/log/export_data/moonwalk"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$DATE-script.log"  

# Redirect logs to file
exec > >(tee -a "$LOG_FILE") 2>&1




# git check
if ! git ls-remote --exit-code "$GIT_REPO" > /dev/null; then
  echo "Git error: check your credentials or repository url" 
  exit 1
fi


# Postgres check
psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -c "SELECT 1" > /dev/null
if [ $? -ne 0 ]; then
  echo "Postgres connection failed"
  exit 1 
fi

# Export
pg_dump -U "$PGUSER" -h "$PGHOST" -d "$PGDATABASE" -W -f dump.sql
if [ $? -ne 0 ]; then
  echo "Error pg_dump"
  exit 1
fi


 # Git
  git clone "$GIT_REPO" repo 
  cd repo 
  git checkout "$GIT_BRANCH" 
  git pull origin "$GIT_BRANCH"
  cp ../dump.sql . 
  git add dump.sql 
  git commit -m "New SQL dump $DATE" 
  git push origin "$GIT_BRANCH" 
  rm ../dump.sql


echo "Ended"