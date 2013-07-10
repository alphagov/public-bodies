#!/usr/bin/env python2
# coding=utf8

def testcleanNumber():
    from parse import cleanNumber
    testcases = [
        ('0', 0),
        ('100', 100),
        ('100,000', 100000),
        ('£150,000', 150000),
        ('100,000,000', 100000000),
        ('100, 231, 231', 100231231),
        ('100,00,000.00', 10000000.0)]

    passed = 0
    failed = 0
    
    for test in testcases:
        data = test[0]
        expected = test[1]
        result = cleanNumber(data)
        if result != expected:
            print('Test Failed. Testing cleanNumber with ' + str(data) + ' got ' + str(result) + ' expected ' + str(expected))
            failed = failed + 1
        if result == expected:
            passed = passed + 1
    return (passed, failed)
def testcleanFinanceNumber():
    from parse import cleanFinanceNumber
    passed = 0
    failed = 0
    testcases = [
        ('£0', 0),
        ('£120 a day', 120 * 365),
        ('£100k', 100000),
        ('£100,000', 100000),
        ('£150,000', 150000),
        ('£100,000,000', 100000000),
        ('£100, 231, 231', 100231231),
        ('£100,00,000.00', 10000000.0)]
    for test in testcases:
        data = test[0]
        expected = test[1]
        result = cleanFinanceNumber(data)
        if result != expected:
            print('Test Failed. Testing cleanFinanceNumber with ' + str(data) + ' got ' + str(result) + ' expected ' + str(expected))
            failed = failed + 1
        if result == expected:
            passed = passed + 1
    return (passed, failed)
            
tests = [testcleanNumber, testcleanFinanceNumber]

if __name__ == '__main__':
    passed = 0
    failed = 0
    for test in tests:
        p,f = test()
        passed = passed + p
        failed = failed + f

    print("Test Complete, Passed {0} Failed {1}".format(passed, failed))

    
        
