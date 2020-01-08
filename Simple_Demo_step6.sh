#!/bin/bash

echo "RUNNING ZALOHA TO VALIDATE THAT SNAPSHOT 'test_backup_000' IS IDENTICAL WITH 'test_source_orig': SHOULD DO NOTHING"

./Zaloha.sh --sourceDir="test_source_orig" --backupDir="test_backup_000" --byteByByte --noLastRun
