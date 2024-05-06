import base64
from cryptography.fernet import Fernet, MultiFernet
import hashlib


class IdCardDecrypt:
    def __init__(self, filename):
        with open(filename, 'rb') as file:
            self.file_content = file.read()
            self.filename = filename

    def decrypt(self):
        # First decryption uses plain text as key
        hashed = hashlib.sha256("key1".encode('utf-8')).hexdigest()[:32]
        fernet_key = Fernet(base64.urlsafe_b64encode(str.encode(hashed)))

        # Second encryption uses the filename (hashed) as key
        hashed_filename = hashlib.sha256(self.filename.encode('utf-8')).hexdigest()[:32]
        fernet_key_filename = Fernet(base64.urlsafe_b64encode(str.encode(hashed_filename)))

        f_multi_fernet = MultiFernet([fernet_key, fernet_key_filename])

        decrypted_content = f_multi_fernet.decrypt(self.file_content)
        with open(self.filename, 'wb') as file:
            file.write(decrypted_content)
        file.close()
