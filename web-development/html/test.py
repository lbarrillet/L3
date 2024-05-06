from IdCardEncrypt import IdCardEncrypt
from IdCardDecrypt import IdCardDecrypt
import sys

argument_1 = sys.argv[1]
argument_2 = sys.argv[2]

if argument_2 == 'IdCardEncrypt':   
    IdCardEncrypt(argument_1).encrypt()
elif argument_2 == 'IdCardDecrypt':
    IdCardDecrypt(argument_1).decrypt()
