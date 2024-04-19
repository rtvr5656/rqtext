extends Control

### Variables ###
var last_window_size : Vector2i = Vector2i(1152, 648)

var file_path : String = ""
var is_saved : bool = true
var loading_text : bool = false
var is_file_encrypted : bool = false

var key : String = "123456789"

var leaving : bool = false



func _ready():
	### Detecting if it's the first time using the software ###
	if not FileAccess.file_exists("user://data.dat"):
		$Welcome.visible = true
		$Background.visible = true
		$TextEditor.visible = false
	
	$TextEditor/Background/TopBar/FileMenu.get_popup().id_pressed.connect(on_file_item_pressed)
	$TextEditor/Background/TopBar/SettingsMenu.get_popup().id_pressed.connect(on_settings_item_pressed)
	

func _process(delta):
	var window = get_window()
	
	### Detecting if the window was resized ###
	if window.size != last_window_size:
		last_window_size = window.size
		change_window_size(last_window_size)
	



### Function to resize the entire interface ###
func change_window_size(size_value : Vector2i = Vector2i(1152, 648)):
	pass
	#$Background.size = size_value
	#$TextEditor/Background.size = size_value
	#$Welcome/Background.size = size_value



### Function to save file ###
func save_file():
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if is_file_encrypted:
		file = FileAccess.open_encrypted_with_pass(file_path, FileAccess.WRITE, key)
	file.store_string($TextEditor/Background/TextEditor.text)
	file.close()



### Function to detect anytime a button from File Menu is pressed ###
func on_file_item_pressed(id : int = -1):
	### Check if the id was currectly received ###
	if id == -1:
		return
	
	### Execute the functions based on the clicked button ###
	if id == 0: # New
		$TextEditor/Background/TextEditor.text = ""
		is_saved = true
		loading_text = false
		file_path = ""
	elif id == 3: # Save
		if file_path == "":
			on_file_item_pressed(4)
		else:
			save_file()
	elif id == 4: # Save as
		$SaveAsDialog.popup()
	elif id == 2: # Open
		$OpenFileDialog.popup()
	

### Function to detect anytime a button from Settings Menu is pressed ###
func on_settings_item_pressed(id : int = -1):
	### Check if the id was currectly received ###
	if id == -1:
		return
	
	### Execute the functions based on the clicked button ###
	if id == 0: # Key
		$ChangeKey/Background/KeyLine.text = key
		$ChangeKey/Background/EncryptionBox.button_pressed = is_file_encrypted
		$ChangeKey.visible = true
	



### Signal to close the welcome message ###
func _on_close_welcome_message_pressed():
	$Welcome.visible = false
	$Background.visible = false
	$TextEditor.visible = true



### Detect whenever something was changed, unless it was changed by the Load function ###
func _on_text_editor_text_changed():
	if is_saved:
		if not loading_text:
			is_saved = false
		else:
			loading_text = false



### Function to open file ###
func _on_open_file_dialog_file_selected(path):
	if is_saved == true:
		var file = FileAccess.open(path, FileAccess.READ)
		if is_file_encrypted:
			file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, key)
		$TextEditor/Background/TextEditor.text = file.get_as_text()
		file.close()
		is_saved = true
		loading_text = true
	else:
		$SaveAlert.popup()



### Function to save when a save path was selected ###
func _on_save_as_dialog_file_selected(path):
	file_path = path
	save_file()



### If user confirmed to save before leaving or open ###
func _on_save_alert_confirmed():
	save_file()
	is_saved = true
	if leaving:
		await get_tree().create_timer(0.25).timeout
		get_tree().quit()
	else:
		on_file_item_pressed(2)

### If user didn't confirmed to save before leaving or open ###
func _on_save_alert_canceled():
	if leaving:
		get_tree().quit()



### Function to close Key Settings ###
func _on_close_key_settings_pressed():
	$ChangeKey.visible = false

### Change the key whenever the key textbox was changed ###
func _on_key_line_text_changed(new_text):
	key = new_text

### Enables/Disables the key when the check box is clicked ###
func _on_encryption_box_pressed():
	is_file_encrypted = $ChangeKey/Background/EncryptionBox.button_pressed
