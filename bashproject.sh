#!/bin/bash
#2022 Anna Giszczak-pt-np
#Program pobiera obrazki z serwera www

#sprawdź czy argument $1 istnieje
if [ $# -eq 1 ]; then
	echo "Pobieram obrazki z $1"
elif [ $# -eq 0 ]; then
	echo "Nie podano argumentu strony www"
	exit
elif [ $1 == "-h" ]; then
	echo "Skrypt pobiera obrazki z serwera www"
	echo "Użycie: ./bashproject.sh [adres strony]"
	exit
else
	echo "Podano za dużo argumentów"
	exit
fi

#jezeli ma // to zamienia na https://
function change_url {
	if [[ $1 == *//* ]]; then #gwiazdka * oznacza dowolny ciąg znaków
		line=$(echo $1 | sed 's/\/\//https:\/\//')  #s/wyrażenie/łańcuch/ zastępuje podanym łancuchem pierwsze znalezione w buforze wyrażenie
	fi
	return 
}

#Pobiera stronę podaną "z linii komend" do pliku tymczasowego html_file
curl $1 > html_file

#znajduje w niej adresy obrazków i zapisuje je do pliku tymczasowego urls
#-o (only-matching) -E (extended-regexp)
grep -o -E "<img[^<]+>" html_file > img_tags  #zaczyna sie od <img, nie zawiera <, ma co najmniej jeden znak, kończy się na >
grep -o -E "(src=[\"|'])[^\"']+[\"|']" img_tags > src #wydobywa src z img_tags, potem omija znaki w nawiasie z ^ i szuka conajmniej jeden znak a potem kończące się na " lub '
grep -o -E "[\"|'].*[\"|']" src > urls #zaczyna sie " lub ', (.) nie ma nowej linii, (*), ma co najmniej jeden znak, kończy się " lub '

#tworzy katalog o nazwie zapisanej w zmiennej dir
dir=webimage_$(date +%y_%m_%d__%H_%M_%S)
mkdir $dir

#pobiera obrazki z pliku urls do katalogu o nazwie zapisanej w zmiennej dir+liczba
j=1
cat urls | tr -d '\"' | while read line; #tr -d usuwa cudzysłowy
do
	change_url "$line"
	echo $line
	wget -O $dir/image_$j  $line
	let "j += 1"
done

echo "Ukonczono pobieranie obrazkow z $1"

# komunikat jeśli nie da się pobrać zdjęcia - sam sie pojawia
# usuwa pliki z treścią strony
rm html_file img_tags src urls

echo "Usunieto pliki tymczasowe"
