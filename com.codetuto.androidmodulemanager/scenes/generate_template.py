#!/usr/bin/python

import sys
import subprocess
import os
import json
import glob
import shutil
from distutils.dir_util import copy_tree
from distutils.file_util import move_file,copy_file

ADDON_DIR = sys.argv[1]

#Load json data
jsonfile = os.path.join(ADDON_DIR,'paths.json')
data = json.load(open(jsonfile))

#Populate paths from json
ANDROID_HOME = data['android_sdk_path']
ANDROID_NDK_ROOT = data['android_ndk_path']

GODOT_SOURCE_DIR = data['godot_src_path']
GODOT_MODULE_DIR = os.path.join(GODOT_SOURCE_DIR,"modules")
PROJECT_MODULE_DIR = data['modules_path']
EXPORT_TEMPLATE_DIR = data['export_path']


def _copy_module_dirs():
	module_dirs = ""
	for item in os.listdir(PROJECT_MODULE_DIR):
		item_path = os.path.join(PROJECT_MODULE_DIR,item)
		dest_path = os.path.join(GODOT_MODULE_DIR,item)
		if os.path.isdir(item_path):
			module_dirs += dest_path + "\n"
			print("> Copying module " + item_path)
			copy_tree(item_path, dest_path)
	with open(os.path.join(ADDON_DIR,"remove"), "w") as f:
		f.write(module_dirs)


def _copy_files():
	if 'files' in data:
		files = data['files']
		for file in files:
			head,tail = os.path.split(file['srcfile'])
			destfile = os.path.join(file['destdir'],tail)
			print("\n>>Backing up " + destfile)
			copy_file(destfile,destfile + ".bak")
			print(">>Copying file " + file['srcfile'])
			copy_file(file['srcfile'],destfile)
	

def _build():
	os.chdir(ADDON_DIR)
	subprocess.call("./build.sh " + ANDROID_HOME + " " + ANDROID_NDK_ROOT + " " + GODOT_SOURCE_DIR,shell=True)
	bindir = os.path.join(GODOT_SOURCE_DIR,'bin')
	os.chdir(bindir)
	for file in glob.glob(os.path.join(bindir,"*.apk")):
		move_file(file,EXPORT_TEMPLATE_DIR)

def _cleanup():
	with open(os.path.join(ADDON_DIR,"remove"), "r") as ins:
		for line in ins:
			line = line.rstrip()
			print("\n>>Removing module " + line)
			shutil.rmtree(line)
	if 'files' in data:
		files = data['files']
		for file in files:
			head,tail = os.path.split(file['srcfile'])
			destfile = os.path.join(file['destdir'],tail)
			destfilebak = destfile + ".bak"
			if os.path.isfile(destfilebak):
				print("\n>>Removing " + destfile)
				os.remove(destfile)
				print(">>Restoring " + destfilebak)
				move_file(destfilebak,destfile)


_copy_module_dirs()
_copy_files()
try:
	print("\n-----MODULES COPIED-----\n")
	_build()
except Exception as e:
	raise e
finally:
	print("\n-----CLEANING-----\n")
	_cleanup()




raw_input("Press ENTER to exit")
