#!/usr/bin/env python2
# coding=utf8
import json
import csv
import os
import argparse
import string
import re
import locale
from jekyll import Markdown


locale.setlocale(locale.LC_ALL, 'en_GB')

# Convert a document from CSV to JSON


def csvToRecords(fn):
    '''Convert a document into a list of dicts'''
    with open(fn, 'r') as csvFile:
        dictReader = csv.DictReader(csvFile)
        return [record for record in dictReader]
            
def cleanRecord(record):
    '''Clean up the record'''
    return record

def generatePublicBodyIndex(record):
    m = Markdown()
    m.yamlHeader(record["Name"])
    headers = ['Name', 'Department']
    m.tableStart()
    for key in headers:
        v = record[key]
        m.tableRowStart()
        m.tag('th', key, dict())
        m.tag('td', v, dict())
        m.tableRowEnd()
    m.tableEnd()
    
    
    retValue = m.getvalue()
    m.close()
    return retValue

def generateDepartmentIndex(records, d):
    depts = set([record["Department"] for record in records])
    for department in depts:
        deptFileName = cleanName(department)
        deptBodies = [record for record in records if record["Department"] == department]
        with open(d + '/' + deptFileName + '/index.json', 'w') as outFile:
            outFile.write(json.dumps(deptBodies))
        with open(d + '/' + deptFileName + '/index.md', 'w') as outFile:
            m = Markdown()
            m.yamlHeader(department, categories='Public Bodies')
            m.tableStart()
            m.tableHeader(['Public Body', "Total Expenditure"])
            for body in deptBodies:
                m.tableRowStart()
                
                m.tableCellStart()
                m.htmlLink(body["Name"], './' + cleanName(body["Name"]) +'.html')
                m.tableCellEnd()

                
                m.tableCellStart()
                m.write("£" + format(cleanFinanceNumber(body["Total Gross Expenditure"]), ',.0f'))
                m.tableCellEnd()

                m.tableRowEnd()
            outFile.write(m.getvalue())
            m.close()

def cleanFinanceNumber(financeNumber):
    matches = re.findall('[0-9,]+', financeNumber)
    if(len(matches) == 0):
        return 0
    elif(len(matches) == 1):
        return int(matches[0].replace(",", ""))
    else:
        return 0
    

def generateMainIndex(records, d):
    depts = set([record["Department"] for record in records])
    with open(d + '/index.md', 'w') as outFile:
        m = Markdown()
        m.yamlHeader("Public Bodies", layout='default-visualised')
        m.tableStart(htmlClass="barchart-table")
        m.tableHeader(['Department', 'Bodies', 'Annual Total Expenditure'])
        for department in depts:
            bodies = [body for body in records if body['Department'] == department]
            totalExpenditure = sum(cleanFinanceNumber(body['Total Gross Expenditure']) for body in bodies)
            deptFileName = cleanName(department)
            deptBodyCount = str(len(bodies))
            deptTotalExpenditure = "£" + format(totalExpenditure, ',.0f')
            deptURL = './' + deptFileName + '/index.html'

            m.tableRowStart({'data-bodies':deptBodyCount, 'data-expenditure':totalExpenditure, 'data-name':department, 'data-url':deptURL})

            m.tableCellStart()
            m.htmlLink(department, deptURL)
            m.tableCellEnd()

            m.tableCellStart()
            m.write(deptBodyCount)
            m.tableCellEnd()
            
            m.tableCellStart()
            m.write(deptTotalExpenditure)
            m.tableCellEnd()

            m.tableRowEnd()
            m.line()
        
        m.tableEnd()
        outFile.write(m.getvalue())
        m.close()    
def cleanName(name):
    tidied_name = ''.join(ch for ch in name if ch not in set(string.punctuation))
    return '-'.join(tidied_name.lower().split())
    
def outputRecords(fn, d):
    '''Output grouped records to subfolders and a master json'''
    records = csvToRecords(fn)
    for record in records:
        deptFileName = cleanName(record["Department"])
        if not os.path.isdir(deptFileName):
            os.mkdir(deptFileName)
        with open(d + '/' + deptFileName + '/' + cleanName(record["Name"]) + ".json", 'w') as outFile:
            outFile.write(json.dumps(record))
        with open(d + '/' + deptFileName + '/' + cleanName(record["Name"]) + ".md", 'w') as outFile:
            outFile.write(generatePublicBodyIndex(record))
    with open('index.json', 'w') as outFile:
        outFile.write(json.dumps(records))
    generateMainIndex(records, d)
    generateDepartmentIndex(records, d)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description = "Process NDPB data into json files"
    )
    parser.add_argument('filename')
    args = parser.parse_args()
    outputRecords(args.filename, os.getcwd())
