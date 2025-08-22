#!/bin/sh

fuzz_list_cmd="cargo fuzz list"

$fuzz_list_cmd | while read -r target; do
  echo "----- fuzzing $target ------"
  RUST_BACKTRACE=1 cargo fuzz coverage  "$target" 
done
