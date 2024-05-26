from passlib.hash import sha512_crypt
import getpass

password = getpass.getpass('Введите пароль: ')
hashed_password = sha512_crypt.hash(password)
print(f'Хэш пароля: {hashed_password}')
