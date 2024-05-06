import base64
from cryptography.fernet import Fernet, MultiFernet
import hashlib

# Corriger les scripts Python pour que lorsqu'on donne un fichier /le/chemin/de/mon/fichier.txt (self.filename),
# la clé d'encryption doit être juste fichier.txt
class IdCardEncrypt:
    def __init__(self, filename):
        with open(filename, 'rb') as file:
            self.file_content = file.read()
            self.filename = filename

    def encrypt(self):
        # First encryption uses the filename (hashed) as key
        hashed_filename = hashlib.sha256(self.filename.encode('utf-8')).hexdigest()[:32]
        fernet_key_filename = Fernet(base64.urlsafe_b64encode(str.encode(hashed_filename)))

        # Second encryption uses plain text as key
        hashed = hashlib.sha256("key1".encode('utf-8')).hexdigest()[:32]
        fernet_key = Fernet(base64.urlsafe_b64encode(str.encode(hashed)))

        f_multi_fernet = MultiFernet([fernet_key_filename, fernet_key])

        encrypted_content = f_multi_fernet.encrypt(self.file_content)
        with open(self.filename, 'wb') as file:
            file.write(encrypted_content)
        file.close()


    