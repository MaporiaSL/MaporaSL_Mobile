@echo off
echo --- Git Status --- > git_sync_log.txt
git status >> git_sync_log.txt 2>&1
echo --- Git Stash List --- >> git_sync_log.txt
git stash list >> git_sync_log.txt 2>&1
echo --- Git Pull --- >> git_sync_log.txt
git pull origin main >> git_sync_log.txt 2>&1
echo --- Git Stash Pop --- >> git_sync_log.txt
git stash pop >> git_sync_log.txt 2>&1
echo --- End --- >> git_sync_log.txt
