#!/bin/bash

# wrapper to run Amazon Reviews downloader in parallel
# Copyright (C) 2016  Dhruv Seth, Vidisha Raj
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# usage: $PWD/run_me.sh
# inputs: Amazon product ID
# inputs: total review pages
# inputs: domain

# example: ./run_me.sh
# Amazon ID: ABCDEFG
# Pages: 220
# Domain (IN or com): com

# output: Will produce a CSV of the amazon reviews in the $PWD directory

THREAD_CAP=5

echo -n "Amazon ID: "
read amazonID;
echo -n "Pages: "
read pages;
echo -n "Domain (IN or com): "
read DOMAIN;
TMP_DIR=$(date +%s)

START_PAGE=1
THREAD_CNT=0
while [ $((START_PAGE+$THREAD_CAP)) -le $pages ]; do
  LAST_PAGE=$((START_PAGE + THREAD_CAP))
  # echo "$START_PAGE - $LAST_PAGE"
  $PWD/review.pl $THREAD_CNT $amazonID $START_PAGE $LAST_PAGE $DOMAIN $TMP_DIR &
  THREAD_CNT=$((THREAD_CNT+1))
  START_PAGE=$((LAST_PAGE+1))
done
START_PAGE=$((LAST_PAGE+1))
if [ $START_PAGE -le $pages ]; then
  # echo "$START_PAGE to $pages"
  $PWD/review.pl $THREAD_CNT $amazonID $START_PAGE $pages $DOMAIN $TMP_DIR &
  THREAD_CNT=$((THREAD_CNT+1))
fi

$PWD/combine.pl $TMP_DIR $amazonID $DOMAIN $THREAD_CNT
TIME_DIFF=$(( $(date +%s) - $TMP_DIR))
MIN_DIFF=$((TIME_DIFF/60))
echo "Total runtime: $MIN_DIFF mins"
exit 0
