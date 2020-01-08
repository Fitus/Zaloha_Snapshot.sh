#!/bin/bash

echo "SIMULATING USER ACTIONS ON 'test_source'"

rm -f "test_source/file_to_remove"
echo "y" > "test_source/file_to_update"
touch -t 201901010101 "test_source/file_to_update"
touch -t 201901010101 "test_source/file_new"
