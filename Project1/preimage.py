import hashlib 
import random

def has6zeros(string):
    s = string[:6]
    if(s == "000000"):
        return True
    return False

string = 'anow6879-brga0406-nopo4611-'
baseString = 'anow6879'.encode('utf-8')
num = 0
hash = hashlib.sha256(baseString).hexdigest()

while(not has6zeros(hash)):
    num += 1
    newstr = (string + str(num)).encode('utf-8')
    hash = hashlib.sha256(newstr).hexdigest()
    if(num%100000 == 0): print(num)

print("String:",newstr,"\n Hash:", hash)

