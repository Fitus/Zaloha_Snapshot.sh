#!/bin/bash

echo "RUNNING ZALOHA TO SYNCHRONIZE 'test_backup'"

./Zaloha.sh --sourceDir="test_source" --backupDir="test_backup" --byteByByte --noLastRun
#./Zaloha.sh --sourceDir="test_source" --backupDir="test_backup" --byteByByte --noLastRun --color
