all:	cantonese.db mandarin.db

clean:
	rm *.db *.json

Unihan.zip:
	wget http://www.unicode.org/Public/UNIDATA/Unihan.zip

cantonese.db definition.db mandarin.db:	Unihan_Readings.txt.lzma
	lzma -dc Unihan_Readings.txt.lzma | ruby parse_unihan_readings.rb

Unihan_Readings.txt.lzma: Unihan.zip
	unzip Unihan.zip
	lzma -9v Unihan_*.txt


