tool
extends EditorPlugin

var dock
var refresh = 10
var timer = 0

var current_tab= null
var current_textedit = null
var tab_container = null
var arr_line = []


func refresh_list():
	if current_textedit != null:
		dock.clear()
		var arr=[]
		arr_line.clear()
	
		var string
		for i in range (current_textedit.get_line_count()):
			string = current_textedit.get_line(i)
			if string.find("func ") == 0:
				arr.append(string.substr(5, string.length()) + " - " + str(i))
		arr.sort()
		for i in arr:
			dock.add_item(i)
		
		dock.connect("item_selected", self, "select_item")
	

func get_current_textedit():
	current_textedit = null
	var editor = get_editor_viewport()
	if editor != null:
		var children = editor.get_children()
		var sc
		for i in children:
			if i.get_type() == "ScriptEditor":
				sc = i
		children = sc.get_children()
		var hs 
		for i in children:
			if i.get_type() == "HSplitContainer":
				hs = i
		children = hs.get_children()
		var tab 
		for i in children:
			
			if i.get_type() == "TabContainer":
				tab = i
				
		tab_container = tab
		tab_container.connect("tab_changed", self, "select_tab")
		current_tab = tab_container.get_current_tab_control()
		children = current_tab.get_children()
		var ct
		for i in children:
			if i.get_type() == "TextEdit":
				ct = i
		current_textedit = ct
		current_textedit.connect("text_changed", self, "ct_text_changed")

func ct_text_changed():
	refresh_list()

func _enter_tree():
	# Initialization of the plugin goes here
	dock = preload("res://addons/function_list/Function_List.tscn").instance()
	add_control_to_dock( DOCK_SLOT_LEFT_UL, dock)
	#get_tab_container()
	#get_current_tab()
	get_current_textedit()
	refresh_list()

func move_cursor_to(par):
	current_textedit.cursor_set_line(par, true)

func add_something(par):
	dock.add_item(par)

func _exit_tree():
	remove_control_from_docks( dock ) # Remove the dock
	dock.free() # Erase the control from the memory
	
func select_item(index):
	var text = dock.get_item_text(index)
	var pos = text.rfind("-")
	text = text.substr(pos+2, text.length())
	var newidx = -1
	if text.is_valid_integer():
		newidx = text.to_int()
	if newidx > -1:
		current_textedit.cursor_set_line(newidx, true)


func select_tab(index):
	get_current_textedit()
	refresh_list()