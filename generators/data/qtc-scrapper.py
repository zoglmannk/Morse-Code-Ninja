#!/Users/kaz/anaconda3/bin/python3

from bs4 import BeautifulSoup
import requests
import pandas as pd
import csv

# Usage:
# python3 qtc-scrapper.py > Worked-All-Europe-DX-Contest-2022-Results.csv

url = "https://dxhf2.darc.de/~waecwlog/user.cgi?fc=loglist&form=referat&lang=en"
page = requests.get(url)
pagetext = page.text

pricetable = {
    "Callsign" : [],
    "DOK" : [],
    "QSOs" : [],
    "Multi" : [],
    "QTCs" : [],
    "Result" : [],
    "Club" : []
}

soup = BeautifulSoup(pagetext, 'html.parser')

file = open("Worked-All-Europe-DX-Contest-2022-Results.csv", 'w')
table = soup.find('table')

table_num = 0
i = 0
for table in soup.find_all('table'):
    table_num += 1
    if table_num == 4:
        i=0
    for row in table.find_all('tr'):
        for col in row.find_all('td'):
            i += 1
            print(col.text, end="")
            #print(" (i: "+str(i)+" table_num: "+str(table_num)+") ")
            if (i % 7 == 0 and table_num <= 3) or (i % 6 == 0 and table_num > 3):
                print("")
            else:
                print(",", end ="")


