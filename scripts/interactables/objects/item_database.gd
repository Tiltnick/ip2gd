extends Node


# für alle Items
var DATA := {
	
	"photo": {
		"name_en": "Photo",
		"name_de": "Foto",
		"description_en": "An old photo of Oris' and Sam's mission back in august. Back when they were happy.",
		"description_de": "Ein altes Foto von Oris’ und Sams Mission im August, als sie noch glücklich waren.",
		"icon": "res://assets/sprites/photos/Photo_Front.jpg",
		"icon_size": Vector2(55, 55),
		"world_scene": "res://scenes/interactables/objects/photo.tscn"
	},
	
	
	
	"stonepanel": {      # used for the hotbar
		"name_de": "Steinpanel",
		"name_en": "Stone Panel",
		"icon": "res://assets/sprites/selfmade/Piece2.png",
		"icon_size": Vector2(55,55)
	},

	"stone_piece_1": {
		"name_de": "Stück 1",
		"name_en": "Piece 1",
		"description_de": "Oh, ein Steinstück! Wie spannend!",
		"description_en": "Oh, a piece of a stone panel! How exciting!",
		"icon": "res://assets/sprites/selfmade/stonesForInven/Piece1.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_1.tscn"
	},
	
	"stone_piece_2": {
		"name_de": "Stück 2",
		"name_en": "Piece 2",
		"description_de": "Oh, ein Steinstück! Wie spannend!",
		"description_en": "Oh, a piece of a stone panel! How exciting!",
		"icon": "res://assets/sprites/selfmade/Piece2.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_2.tscn"
	},
	
	"stone_piece_3": {
		"name_de": "Stück 3",
		"name_en": "Piece 3",
		"description_de": "Oh, ein Steinstück! Wie spannend!",
		"description_en": "Oh, a piece of a stone panel! How exciting!",
		"icon": "res://assets/sprites/selfmade/Piece3.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_3.tscn"
	},
	
	"stone_piece_4": {
		"name_de": "Stück 4",
		"name_en": "Piece 4",
		"description_de": "Oh, ein Steinstück! Wie spannend!",
		"description_en": "Oh, a piece of a stone panel! How exciting!",
		"icon": "res://assets/sprites/selfmade/stonesForInven/Piece4.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_4.tscn"
	},
	
	"stone_piece_5": {
		"name_de": "Stück 5",
		"name_en": "Piece 5",
		"description_de": "Oh, ein Steinstück! Wie spannend!",
		"description_en": "Oh, a piece of a stone panel! How exciting!",
		"icon": "res://assets/sprites/selfmade/Piece5.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_5.tscn"
	},
	
	"stone_piece_6": {
		"name_de": "Stück 6",
		"name_en": "Piece 6",
		"description_de": "Oh, ein Steinstück! Wie spannend!",
		"description_en": "Oh, a piece of a stone panel! How exciting!",
		"icon": "res://assets/sprites/selfmade/stonesForInven/Piece6.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_6.tscn"
	},

	
	"empty": {
		"name_en": "Empty Slot",
		"name_de": "Leerer Slot",
		"description_en": "Oops, this slot has not been filled with anything yet. Nothing to see here, just an empty slot!",
		"description_de": "Ups, dieser Slot wurde noch mit nichts gefüllt. Hier gibt es nichts zu sehen, nur ein leerer Slot!",
		"icon": "res://assets/sprites/selfmade/EmptySlot.png",
		"icon_size": Vector2(55, 55)
	},
	
	
	
	"flashlight": {
		"name_de": "Taschenlampe",
		"name_en": "Flashlight",
		"description_en": "This is a flashlight. You can use it to light the way (but don't look into it, it's very bright.)",
		"description_de": "Das ist eine Taschenlampe. Du kannst sie benutzen, um den Weg zu erleuchten (bitte schau nicht rein, sie ist sehr hell.)",
		"icon": "res://assets/sprites/selfmade/flashlight.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/flashlight.tscn"
},

	"shovel": {
		"name_de": "Schaufel",
		"name_en": "Shovel",
		"description_en": "This is a shovel. You can use it to dig up things. Please don't step on it, that might be dangereous and hurt.",
		"description_de": "Das ist eine Schaufel. Du kannst sie benutzen, um Dinge auszugraben. Bitte tritt nicht auf sie drauf, das könnte wehtun und gefährlich werden.",
		"icon": "res://assets/sprites/selfmade/shovel.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/shovel.tscn"
},


}
