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
	
	"mushrooms": {      # used for the hotbar
		"name_de": "Pilze",
		"name_en": "mushrooms",
		"icon": "res://assets/sprites/selfmade/mushrooms/brown_mush.png",
		"icon_size": Vector2(55,55)
	},
	
	"blue_mush": {
		"name_de": "blauer Pilz",
		"name_en": "blue mushroom",
		"description_de": "Ein blauer Pilz.",
		"description_en": "A blue mushroom.",
		"icon":"res://assets/sprites/selfmade/mushrooms/blue_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/blue_mush.tscn"
	},
	
	"brown_mush": {
		"name_de": "brauner Pilz",
		"name_en": "brown mushroom",
		"description_de": "Ein blauer Pilz.",
		"description_en": "A blue mushroom.",
		"icon":"res://assets/sprites/selfmade/mushrooms/brown_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/brown_mush.tscn"
	},
	
	"green_mush": {
		"name_de": "grüner Pilz",
		"name_en": "green mushroom",
		"description_de": "Ein grüner Pilz.",
		"description_en": "A green mushroom.",
		"icon":"res://assets/sprites/selfmade/mushrooms/green_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/green_mush.tscn"
	},
	
	"orange_mush": {
		"name_de": "orangener Pilz",
		"name_en": "orange mushroom",
		"description_de": "Ein blauer Pilz.",
		"description_en": "A blue mushroom.",
		"icon":"res://assets/sprites/selfmade/mushrooms/orange_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/orange_mush.tscn"
	},
	
	"red_mush": {
		"name_de": "roter Pilz",
		"name_en": "red mushroom",
		"description_de": "Ein roter Pilz.",
		"description_en": "A red mushroom.",
		"icon":"res://assets/sprites/selfmade/mushrooms/red_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/red_mush.tscn"
	},
	
	"yellow_mush": {
		"name_de": "gelber Pilz",
		"name_en": "yellow mushroom",
		"description_de": "Ein gelber Pilz.",
		"description_en": "A yellow mushroom.",
		"icon":"res://assets/sprites/selfmade/mushrooms/yellow_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/yellow_mush.tscn"
	},
	
	"stonepanel": {      # used for the hotbar
		"name_de": "Steinpanel",
		"name_en": "Stone Panel",
		"icon": "res://assets/sprites/selfmade/Piece2.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/stone pieces/view_all_pieces_hb.tscn"

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
	
	"fluxomat": {
		"name_de": "Fluxomat",
		"name_en": "Fluxomat",
		"description_de": "Der Fluxomat synchronisiert oszillierende Schiffszustände über quantenähnliche Umwege und repariert das Schiff – irgendwie.",
		"description_en": "The Fluxomat synchronizes oscillating ship states via quantum-like detours, leaving the ship fully repaired afterward.",
		"icon": "res://assets/sprites/selfmade/Fluxomat.png",
		"icon_size": Vector2(32,32),
		"world_scene": "res://scenes/interactables/objects/fluxomat.tscn"
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

	"telescope": {
		"name_de": "Teleskop",
		"name_en": "Telescope",
		"description_en": "TEST",
		"description_de": "TEST",
		"icon": "res://assets/sprites/selfmade/telescope.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/telescope.tscn"
},


}
