#!/usr/bin/env python2
# coding=utf8
import json
import csv
import os
import argparse
import string
import re
from collections import defaultdict
import locale
from jekyll import Markdown


locale.setlocale(locale.LC_ALL, 'en_GB')

# Convert a document from CSV to JSON


def cleanFinanceNumber(financeNumber):
    matches = re.findall('[0-9,]+', financeNumber)
    if(len(matches) == 0):
        return 0
    else:
        numbers = []
        for match in matches:
            try:
                numbers.append(int(match.replace(",", "")))
            except ValueError:
                pass
        return sum(numbers) / len(matches)
        

def cleanBool(boolStr):
    has_yes = "yes" in boolStr.lower()
    has_no = "no" in boolStr.lower()
    if has_yes and not has_no:
        return True
    elif has_yes and has_no:
        return False
    else:
        return False
def cleanNumber(numStr):
    numStr = numStr.replace('*', '')
    try:
        return int(numStr)
    except ValueError:
        if '-' in numStr:
            return 0
        else:
            nums = re.findall('[0-9]+', numStr)
            if nums:
                return sum([int(num) for num in nums])
        raw_input("Error: " + numStr)
        return 0
def csvToRecords(fn):
    '''Convert a document into a list of dicts'''
    with open(fn, 'r') as csvFile:
        dictReader = csv.DictReader(csvFile)
        records = [cleanRecord(record) for record in dictReader]
        d = defaultdict(list)
        for record in records:
            d[record['department']].append(record)

        return d

def cleanMoney(monStr):
    return cleanFinanceNumber(monStr)

def cleanClassification(classStr):
    if classStr == 'Executive NDPB':
        return 'executive'
    elif classStr == 'Advisory NDPB':
        return 'advisory'
    elif classStr == 'Tribunal NDPB':
        return 'tribunal'
    else:
        return 'other'

def cleanPbReform(s):
    if "Merge" in s:
        return "merge"
    elif "No longer an NDPB" in s:
        return "abolish"
    elif "Retain" in s:
        return "retain"
    elif "Under Consideration" in s:
        return "under_consideration"
    else:
        return "retain"
    
def cleanRecord(record):
    '''Clean up the record'''
    record = {cleanName(k):v for k,v in record.items()} #puts all names into lower-case-hyphenated-format for ease of use

    renamed_record = dict()
    # Clean up the booleans
    renamed_record["_public-meetings"] = record["public-meetings"]
    renamed_record["_regulatory-function"] = record["regulatory-function"]
    renamed_record["_public-minutes"] = record["public-minutes"]
    renamed_record["_ocpa-regulated"] = record["ocpa-regulated"]
    renamed_record["_register-of-interests"] = record["register-of-interests"]

    renamed_record["public-meetings"] = cleanBool(record["public-meetings"])
    renamed_record["regulatory-function"] = cleanBool(record["regulatory-function"])
    renamed_record["public-minutes"] = cleanBool(record["public-minutes"]) 
    renamed_record["ocpa-regulated"] = cleanBool(record["ocpa-regulated"])
    renamed_record["register-of-interests"] = cleanBool(record["register-of-interests"])

    # Clean up the plain numbers
    renamed_record["_staff-employed-fte"] = record["staff-employed-fte"]
    renamed_record["staff-employed-fte"] = cleanNumber(record["staff-employed-fte"])
    
    renamed_record["_count"] = record["count"]
    renamed_record["body-count"] = cleanNumber(record["count"])
    renamed_record["_multiple-bodies"] = record["multiple-bodies"]

    # Clean up the money
    renamed_record["_total-gross-expenditure"] = record["total-gross-expenditure"]
    renamed_record["_government-funding"] = record["government-funding"]
    renamed_record["_chief-executive-secretart-remuneration"] = record["chief-executive-secretart-remuneration"]
    renamed_record["_chairs-remuneration-pa-unless-otherwise-stated"] = record["chairs-remuneration-pa-unless-otherwise-stated"]

    renamed_record["total-gross-expenditure"] = cleanMoney(record["total-gross-expenditure"])
    renamed_record["government-funding"] = cleanMoney(record["government-funding"])
    renamed_record["chief-executive-remuneration"] = cleanMoney(record["chief-executive-secretart-remuneration"])
    renamed_record["chairs-remuneration"] = cleanMoney(record["chairs-remuneration-pa-unless-otherwise-stated"])

    # Transfer verbatim fields
    renamed_record["name"] = record["name"]
    renamed_record["clean-name"] = cleanName(record["name"])
    renamed_record["description"] = record["description-terms-of-reference"]
    renamed_record["chair"] = record["chair"]
    renamed_record["chief-executive"] = record["chief-executive-secretary"]
    
    renamed_record["department"] = record["department"]
    renamed_record["clean-department"] = cleanName(record["department"])
    renamed_record["email"] = record["email"]
    renamed_record["website"] = record["website"]
    renamed_record["phone"] = record["phone"]
    renamed_record["address"] = record["address"]
    renamed_record["notes"] = record["notes"]
    
    renamed_record["last-review"] = record["last-review"]#Todo, parse into something more useful (remember some of these are just years, or explanations for why they feel they are immune from review)
    renamed_record["last-annual-report"] = record["last-annual-report"]#Todo, parse into something more useful (takes a vast number of forms, despite it being an 'annual' report)
    
    renamed_record["classification"] = cleanClassification(record["classification"])
    renamed_record["pb-reform"] = cleanPbReform(record["pb-reform"])
    renamed_record["ombudsman"] = record["ombudsman"]
    renamed_record["audit-arrangements"] = record["audit-arrangements"]

    return renamed_record
    
def generatePublicBodyIndex(record):
    m = Markdown()
    m.yamlHeader(record["name"])
    m.tableStart()

    m.tableRowStart()
    m.tag('th', "Name", dict())
    m.tag('td', record["name"], dict())
    m.tableRowEnd()
    
    m.tableRowStart()
    m.tag('th', "Department", dict())
    m.tag('td', record["department"], dict())
    m.tableRowEnd()
    m.tableEnd()
    
    
    retValue = m.getvalue()
    m.close()
    return retValue

def generateDepartmentIndex(records, d):
    depts = records.keys()
    for department, deptBodies in records.items():
        deptFileName = cleanName(department)
        with open(d + '/' + deptFileName + '/index.json', 'w') as outFile:
            outFile.write(json.dumps({"name" : department,
                                      "bodies": deptBodies}))

def cleanName(name):
    tidied_name = ''.join(ch for ch in name if ch not in set(string.punctuation))
    return '-'.join(tidied_name.lower().split())
    
def outputRecords(records, d):
    '''Output grouped records to subfolders and a master json'''
    for department, deptRecords in records.items():
        deptFileName = cleanName(department)
        if not os.path.isdir(deptFileName):
            os.mkdir(deptFileName)
        for record in deptRecords:
            with open(d + '/' + deptFileName + '/' + cleanName(record["name"]) + ".json", 'w') as outFile:
                outFile.write(json.dumps(record))
        with open('index.json', 'w') as outFile:

            outFile.write(json.dumps({'all_bodies' : [{'name':k, 'values':v} for k,v in records.items()]}))
    generateDepartmentIndex(records, d)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description = "Process NDPB data into json files"
    )
    parser.add_argument('filename')
    parser.add_argument('--json', action='store_true', default=False)
    parser.add_argument('--pretty', action='store_true', default=False)
    parser.add_argument('--csv', action='store_true', default=False)
    args = parser.parse_args()
    data = csvToRecords(args.filename)
    if args.json:
        if args.pretty:
            print(json.dumps(data, indent=4, sort_keys=True))
        else:
            print(json.dumps(data))
    elif args.csv:
        print 'csv'
    else:
        outputRecords(data, os.getcwd())
    
