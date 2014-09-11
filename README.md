# Chinese Char Converter

## About this program

This program will show you the Chinese Mandarin,
Cantonese pronounciation and Cangjie key sequence. Supported languages and data
are as following.

* Chinese Mandarin (Putonghua 普通话,) Pinyin 拼音 : Simplified and Traditional 
* Cantonese Yale Pinyin: Simplified and Traditional 
* Simplified/Traditional character conversion (also from Japanese Kanji is supported)
* Cangjie Traditional Chinese characters strokes. It's used to input Traditional Chinese characters.


Original data is from UniHan DB of unicode.org

## How to use it

This package includes 3 ruby scripts and 1 html file.

* mk_unihan_db.rb :
 generate character conversion table from UniHan DB.
 Files of UniHan should be stored in data/ directory. 
 This program will generate unihan.hdb .
* print_unihan_reading.rb :
 command line program to convert chinese characters. It uses unihan.hdb which generated from mk_unihan_db, input from STDIN.
* print_unihan_reading.rb
 CGI program to convert chinese characters. It uses unihan.hdb which generated from mk_unihan_db, input from STDIN.
* index.html
 input form and kick print_unihan_reading.cgi .

## Sample Page

Please visit http://masaru.org/ctp/


