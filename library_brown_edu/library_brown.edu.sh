#!/bin/sh

# Howard P. Lovecraft collection
# https://repository.library.brown.edu/studio/collections/id_680/

#lst=`curl -s https://repository.library.brown.edu/iiif/presentation/bdr:425213/manifest.json | jq -r '.sequences[].canvases[].images[].resource | ."@id"'`
#book="https://repository.library.brown.edu/studio/item/bdr:425213/"

which jq > /dev/null 2> /dev/null
if [[ $? -ne 0 ]] ; then
   echo "jq - JSON парсер - должен быть установлен в системе"
   exit 2
fi

if [ "$#" -ne 1 ]; then
    echo "Укажите адрес книги в качестве параметра запуска как-то так:"
    echo ">\$ ${0} https://repository.library.brown.edu/studio/item/bdr:425213/"
    exit 1
fi

book=$1
url=`echo ${book} | sed -e 's/studio\/item/iiif\/presentation/g' | sed -e 's/$/manifest\.json/'`
lst=`curl -s ${url} | jq -r '.sequences[].canvases[].images[].resource | ."@id"'`
npp=100

bookid=`echo ${book} | awk -F"bdr:" '{print $2}' | awk -F"/" '{print $1}'`
title=`curl -s ${url} | jq -r '.label'`

counter=`echo ${lst} | wc -w`
echo "Страниц по ссылке: ${counter}"

bookdir="${bookid} ${title}"
if [[ ! -d ${bookdir} ]] ; then
   mkdir "${bookdir}"
fi

for i in ${lst}
do
   fname=`echo ${i}| awk -F"bdr:" '{print $2}' | awk -F"/" '{print $1"_"$NF}'`
   echo "${i} => ${bookdir}/${npp}_${fname}"
   wget -q -nc --no-check-certificate ${i} -O "${bookdir}/${npp}_${fname}"
   npp=$((npp + 1))
done
