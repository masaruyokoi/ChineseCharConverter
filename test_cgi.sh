#!/bin/bash
set -x
set -e
echo "Simplified -> Traditional, Mandarin"
./print_unihan_reading.cgi << _END_
txt=%e4%b8%ad%e5%8d%8e%e4%ba%ba%e6%b0%91%e5%85%b1%e5%92%8c%e5%9b%bd
type=Mandarin
mode=html
modifier=Traditional
_END_

./print_unihan_reading.cgi << _END_
txt=%e6%a8%aa%e4%ba%95+%e5%8b%9d
type=Mandarin
mode=html
modifier=Traditional
_END_

echo "Simplified -> Traditional, Mandarin, brackets"
./print_unihan_reading.cgi << _END_
txt=%e4%b8%ad%e5%8d%8e%e4%ba%ba%e6%b0%91%e5%85%b1%e5%92%8c%e5%9b%bd 
type=Mandarin
mode=htmlbrackets
modifier=Traditional
_END_


echo "Traditional -> Simplified, Mandarin"
./print_unihan_reading.cgi << _END_
txt=%e4%b8%ad%e8%8f%af%e4%ba%ba%e6%b0%91%e5%85%b1%e5%92%8c%e5%9c%8b
type=Mandarin
mode=html
modifier=Simplified
_END_

echo "Simplified -> Traditional, Cangjie, brackets"
./print_unihan_reading.cgi << _END_
txt=%e4%b8%ad%e5%8d%8e%e4%ba%ba%e6%b0%91%e5%85%b1%e5%92%8c%e5%9b%bd 
type=Cangjie
mode=htmlbrackets
modifier=Traditional
_END_

echo "Simplified -> Traditional, CangjieRadical, brackets"
./print_unihan_reading.cgi << _END_
txt=%e4%b8%ad%e5%8d%8e%e4%ba%ba%e6%b0%91%e5%85%b1%e5%92%8c%e5%9b%bd 
type=CangjieRadical
mode=htmlbrackets
modifier=Traditional
_END_



echo 
