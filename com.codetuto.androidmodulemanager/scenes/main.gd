tool
extends WindowDialog

const DIALOG_ANDROID_SDK = 0
const DIALOG_ANDROID_NDK = 1
const DIALOG_GODOT_SRC_DIR = 2
const DIALOG_MODULE_DIR = 3
const DIALOG_EXPORT_PATH = 4
const DIALOG_FILE_ADD = 5

onready var dir_chooser_dialog = get_node("FileDialog")

onready var choose_godot_src_button = get_node("vbox/hbox/vbox_left/godot_src_section/hbox/choose_godot_src")
onready var godot_src_path_txt = get_node("vbox/hbox/vbox_left/godot_src_section/hbox/godot_src_txt")

onready var choose_modules_path_button = get_node("vbox/hbox/vbox_left/modules_section/hbox/choose_modules_path")
onready var modules_path_txt = get_node("vbox/hbox/vbox_left/modules_section/hbox/modules_path_txt")

onready var choose_export_path_button = get_node("vbox/hbox/vbox_left/export_template_section/hbox/choose_export_path")
onready var export_path_txt = get_node("vbox/hbox/vbox_left/export_template_section/hbox/export_path_txt")

onready var choose_android_sdk_button = get_node("vbox/hbox/vbox_left/android_sdk_section/hbox/choose_godot_sdk_path")
onready var android_sdk_path_txt = get_node("vbox/hbox/vbox_left/android_sdk_section/hbox/godot_sdk_txt")

onready var choose_android_ndk_button = get_node("vbox/hbox/vbox_left/godot_ndk_section/hbox/choose_godot_ndk_path")
onready var android_ndk_path_txt = get_node("vbox/hbox/vbox_left/godot_ndk_section/hbox/godot_ndk_txt")

onready var filelist = get_node("vbox/hbox/vbox_right/file_list")
onready var newfile_btn = get_node("vbox/hbox/vbox_right/file_buttons/newfilebtn")
onready var removefile_btn = get_node("vbox/hbox/vbox_right/file_buttons/removefilebtn")

onready var generate_button = get_node("vbox/generate_section/generate_button")

var current_dir = ""
var paths_file_path = ""
var files_path = ""

var godot_src_path = ""
var modules_path = ""
var export_path = ""
var android_sdk_path = ""
var android_ndk_path = ""


func _ready():
	current_dir = get_script().get_path().get_base_dir()
	paths_file_path = current_dir+"/paths.json"
	files_path = current_dir+"/files.txt"
	show_window()

func load_old_paths_from_json():
	var f = File.new()
	if(f.file_exists(paths_file_path)):
		f.open(paths_file_path,f.READ)
		var json = {}
		json.parse_json(f.get_as_text())
		android_sdk_path = json["android_sdk_path"]
		android_ndk_path = json["android_ndk_path"]
		godot_src_path = json["godot_src_path"]
		modules_path = json["modules_path"]
		export_path = json["export_path"]
		if json.has("files"):
			for item in json.files:
				filelist.add_item(item.srcfile+"|"+item.destdir)
	android_sdk_path_txt.set_text(android_sdk_path)
	android_ndk_path_txt.set_text(android_ndk_path)
	godot_src_path_txt.set_text(godot_src_path)
	modules_path_txt.set_text(modules_path)
	export_path_txt.set_text(export_path)
	f.close()

func save_paths_to_json():
	var f = File.new()
	var json = {
		"android_sdk_path":android_sdk_path,
		"android_ndk_path":android_ndk_path,
		"godot_src_path":godot_src_path,
		"modules_path":modules_path,
		"export_path":export_path,
		"addon_path":Globals.globalize_path(current_dir)
	}
	var files = []
	for i in range(0,filelist.get_item_count()):
		var split = filelist.get_item_text(i).split("|")
		var file = {
			"srcfile":split[0],
			"destdir":split[1]
		}
		files.append(file)
	json["files"] = files
	f.open(paths_file_path,f.WRITE)
	f.store_string(json.to_json())
	f.close()

func show_window():
	load_old_paths_from_json()
	show()
	choose_godot_src_button.connect("pressed",self,"_show_godot_src_dir_chooser")
	choose_modules_path_button.connect("pressed",self,"_show_modules_dir_chooser")
	choose_export_path_button.connect("pressed",self,"_show_export_dir_chooser")
	choose_android_sdk_button.connect("pressed",self,"_show_android_sdk_chooser")
	choose_android_ndk_button.connect("pressed",self,"_show_android_ndk_chooser")
	generate_button.connect("pressed",self,"_generate")
	newfile_btn.connect("pressed",self,"_show_file_chooser")
	removefile_btn.connect("pressed",self,"_remove_file")

func _show_file_chooser():
	dir_chooser_dialog.set_mode(dir_chooser_dialog.MODE_OPEN_FILE)
	dir_chooser_dialog.set_current_dir(modules_path+"/../")
	dir_chooser_dialog.invalidate()
	dir_chooser_dialog.set_title("Choose source file")
	dir_chooser_dialog.show_modal(true)
	dir_chooser_dialog.connect("file_selected",self,"_file_selected")

func _file_selected(path):
	dir_chooser_dialog.disconnect("file_selected",self,"_file_selected")
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(0.2)
	timer.start()
	yield(timer,"timeout")
	timer.queue_free()
	dir_chooser_dialog.clear_filters()
	dir_chooser_dialog.set_current_dir(godot_src_path)
	dir_chooser_dialog.invalidate()
	dir_chooser_dialog.set_mode(dir_chooser_dialog.MODE_OPEN_DIR)
	dir_chooser_dialog.set_title("Choose destination directory")
	dir_chooser_dialog.connect("dir_selected",self,"_set_file_destination",[path])
	dir_chooser_dialog.call_deferred("show_modal",true)
	dir_chooser_dialog.update()

func _set_file_destination(dest,src):
	filelist.add_item(src+"|"+dest)

func _remove_file():
	for i in filelist.get_selected_items():
		filelist.remove_item(i)

func _show_godot_src_dir_chooser():
	dir_chooser_dialog.show_modal(true)
	dir_chooser_dialog.set_mode(dir_chooser_dialog.MODE_OPEN_DIR)
	dir_chooser_dialog.clear_filters()
	dir_chooser_dialog.set_title("Choose Godot Source Directory")
	dir_chooser_dialog.connect("dir_selected",self,"_dir_choosed",[DIALOG_GODOT_SRC_DIR],CONNECT_ONESHOT)

func _show_modules_dir_chooser():
	dir_chooser_dialog.show_modal(true)
	dir_chooser_dialog.set_mode(dir_chooser_dialog.MODE_OPEN_DIR)
	dir_chooser_dialog.clear_filters()
	dir_chooser_dialog.set_title("Choose Modules Directory")
	dir_chooser_dialog.connect("dir_selected",self,"_dir_choosed",[DIALOG_MODULE_DIR],CONNECT_ONESHOT)

func _show_export_dir_chooser():
	dir_chooser_dialog.show_modal(true)
	dir_chooser_dialog.set_mode(dir_chooser_dialog.MODE_OPEN_DIR)
	dir_chooser_dialog.clear_filters()
	dir_chooser_dialog.set_title("Choose Export Directory")
	dir_chooser_dialog.connect("dir_selected",self,"_dir_choosed",[DIALOG_EXPORT_PATH],CONNECT_ONESHOT)


func _show_android_sdk_chooser():
	dir_chooser_dialog.show_modal(true)
	dir_chooser_dialog.set_mode(dir_chooser_dialog.MODE_OPEN_DIR)
	dir_chooser_dialog.clear_filters()
	dir_chooser_dialog.set_title("Choose Android SDK Path")
	dir_chooser_dialog.connect("dir_selected",self,"_dir_choosed",[DIALOG_ANDROID_SDK],CONNECT_ONESHOT)

func _show_android_ndk_chooser():
	dir_chooser_dialog.show_modal(true)
	dir_chooser_dialog.set_mode(dir_chooser_dialog.MODE_OPEN_DIR)
	dir_chooser_dialog.clear_filters()
	dir_chooser_dialog.set_title("Choose Android NDK Path")
	dir_chooser_dialog.connect("dir_selected",self,"_dir_choosed",[DIALOG_ANDROID_NDK],CONNECT_ONESHOT)

func _dir_choosed(path,type):
	if(type == DIALOG_GODOT_SRC_DIR):
		godot_src_path = path
		godot_src_path_txt.set_text(godot_src_path)
	elif(type == DIALOG_MODULE_DIR):
		modules_path = path
		modules_path_txt.set_text(modules_path)
	elif(type == DIALOG_EXPORT_PATH):
		export_path = path
		export_path_txt.set_text(export_path)
	elif(type == DIALOG_ANDROID_SDK):
		android_sdk_path = path
		android_sdk_path_txt.set_text(android_sdk_path)
	elif(type == DIALOG_ANDROID_NDK):
		android_ndk_path = path
		android_ndk_path_txt.set_text(android_ndk_path)

func _generate():
	save_paths_to_json()
	var script_dir = self.get_script().get_path().get_base_dir()
	script_dir = Globals.globalize_path(script_dir) + "/generate_template.py"
	var result = []
	OS.execute("x-terminal-emulator", ["-e",script_dir,Globals.globalize_path(current_dir)],true,result)
	hide_window()

func hide_window():
	dir_chooser_dialog.disconnect("dir_selected",self,"_dir_choosed")
	dir_chooser_dialog.disconnect("file_selected",self,"_file_selected")
	choose_godot_src_button.disconnect("pressed",self,"_show_godot_src_dir_chooser")
	choose_modules_path_button.disconnect("pressed",self,"_show_modules_dir_chooser")
	choose_export_path_button.disconnect("pressed",self,"_show_export_dir_chooser")
	choose_android_sdk_button.disconnect("pressed",self,"_show_android_sdk_chooser")
	choose_android_ndk_button.disconnect("pressed",self,"_show_android_ndk_chooser")
	generate_button.disconnect("pressed",self,"_generate")
	newfile_btn.disconnect("pressed",self,"_show_file_chooser")
	removefile_btn.disconnect("pressed",self,"_remove_file")
	hide()
