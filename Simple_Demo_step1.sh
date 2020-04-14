#!/bin/bash

set -e

echo "PREPARING IDENTICAL SOURCE DIRECTORIES 'test_source' AND 'test_source_orig'"

mkdir "test_source"
touch -t 201901010101 "test_source/file_to_remove"
echo "x" > "test_source/file_unchanged"
touch -t 201901010101 "test_source/file_unchanged"
echo "x" > "test_source/file_to_update"
touch -t 201901010101 "test_source/file_to_update"

mkdir "test_source_orig"
touch -t 201901010101 "test_source_orig/file_to_remove"
echo "x" > "test_source_orig/file_unchanged"
touch -t 201901010101 "test_source_orig/file_unchanged"
echo "x" > "test_source_orig/file_to_update"
touch -t 201901010101 "test_source_orig/file_to_update"

# prepare also 'test_backup'
mkdir "test_backup"
