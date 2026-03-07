@echo off
set LOG_FILE=d:\Github_projects\gemified-travel-portfolio\git_sync_log_absolute.txt
echo --- Git Status --- > "%LOG_FILE%"
git status >> "%LOG_FILE%" 2>&1
echo --- Git Stash List --- >> "%LOG_FILE%"
git stash list >> "%LOG_FILE%" 2>&1
echo --- Git Pull --- >> "%LOG_FILE%"
git pull origin main >> "%LOG_FILE%" 2>&1
echo --- Git Stash Pop --- >> "%LOG_FILE%"
git stash pop >> "%LOG_FILE%" 2>&1
echo --- End --- >> "%LOG_FILE%"
