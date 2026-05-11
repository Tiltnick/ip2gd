extends Control

signal photo_confirmed
signal camera_closed

@onready var confirm_button = $DimBackground/PhoneFrameHorizontal/Screen/CameraPreview/HeaderMarginContainer/Header/ConfirmButton
@onready var cancel_button = $DimBackground/PhoneFrameHorizontal/Screen/CameraPreview/HeaderMarginContainer/Header/CancelButton
@onready var close_button = $DimBackground/CloseButton

func _ready():

	visible = false

func _on_confirm_pressed():
	photo_confirmed.emit()

func _on_cancel_pressed():
	camera_closed.emit()

func _on_close_pressed():
	camera_closed.emit()
