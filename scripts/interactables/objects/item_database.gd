extends Node


# für alle Items
var DATA := {
	
	"photo": {
		"name_en": "Photo",
		"name_de": "Foto",
		"description_en": "An old photo of Oris' and Sam's mission back in august.",
		"description_de": "Ein altes Foto von Oris’ und Sams Mission im August.",
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
		"icon_size": Vector2(55,55)
	},

	"stone_piece_1": {
		"name_de": "Steinpanel-Stück",
		"name_en": "Stone panel piece",
		"description_de": "Ein Teil des Steinpanels.",
		"description_en": "A piece of the stone panel.",
		"icon": "res://assets/sprites/selfmade/Piece1.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_1.tscn"
	},
	
	"stone_piece_2": {
		"name_de": "Steinpanel-Stück",
		"name_en": "Stone panel piece",
		"description_de": "Ein Teil des Steinpanels.",
		"description_en": "A piece of the stone panel.",
		"icon": "res://assets/sprites/selfmade/Piece2.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_2.tscn"
	},
	
	"stone_piece_3": {
		"name_de": "Steinpanel-Stück",
		"name_en": "Stone panel piece",
		"description_de": "Ein Teil des Steinpanels.",
		"description_en": "A piece of the stone panel.",
		"icon": "res://assets/sprites/selfmade/Piece3.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_3.tscn"
	},
	
	"stone_piece_4": {
		"name_de": "Steinpanel-Stück",
		"name_en": "Stone panel piece",
		"description_de": "Ein Teil des Steinpanels.",
		"description_en": "A piece of the stone panel.",
		"icon": "res://assets/sprites/selfmade/Piece4.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_4.tscn"
	},
	
	"stone_piece_5": {
		"name_de": "Steinpanel-Stück",
		"name_en": "Stone panel piece",
		"description_de": "Ein Teil des Steinpanels.",
		"description_en": "A piece of the stone panel.",
		"icon": "res://assets/sprites/selfmade/Piece5.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_5.tscn"
	},
	
	"stone_piece_6": {
		"name_de": "Steinpanel-Stück",
		"name_en": "Stone panel piece",
		"description_de": "Ein Teil des Steinpanels.",
		"description_en": "A piece of the stone panel.",
		"icon": "res://assets/sprites/selfmade/Piece6.png",
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
	}

}
