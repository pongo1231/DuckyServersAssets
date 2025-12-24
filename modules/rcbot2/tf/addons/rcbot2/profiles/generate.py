#!/env/python

### Config ###

names_file = "names.txt"

##############

import random
import sys
import os

def remove_existing_profiles():
	for i in range(1, 999):
		# Current path
		if os.path.isfile(str(i) + ".ini"):
			os.remove(str(i) + ".ini")

def fetch_names():
	with open(sys.path[0]+"/"+names_file) as f:
		return f.read().splitlines()

def gen_bot_profiles(gen_names):
	for i in range(1, len(gen_names)+1):
		# Current path
		with open(sys.path[0]+"/"+str(i)+".ini", "w+") as file:
			file.write("name = " + gen_names[i-1])


def main():
	remove_existing_profiles()
	names = fetch_names()
	gen_bot_profiles(names)

main()
