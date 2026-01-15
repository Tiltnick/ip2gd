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
	
	"fire_mush": {
		"name_de": "Feuerpilz",
		"name_en": "fire mushroom",
		"description_de": "Ein feuriger Pilz. Achtung, sehr heiß, lass dich nicht verführen.",
		"description_en": "A fire mushroom. Be cautious, it's very hot, don't let yourself be seduced.",
		"icon":"res://assets/sprites/selfmade/mushrooms/fire_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/fire_mush.tscn"
	},
	
	"mushrooms": {      # used for the hotbar
		"name_de": "Pilze",
		"name_en": "mushrooms",
		"icon": "res://assets/sprites/selfmade/mushrooms/brown_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/view_all_mushrooms_hb.tscn",
		"show_in_inventory": false,
  		"show_in_hotbar": true
	},
	
	"blue_mush": {
		"name_de": "Blauer Pilz",
		"name_en": "Blue mushroom",
		"description_de": "Ein blauer Pilz.",
		"description_en": "A blue mushroom.",
		"icon":"res://assets/sprites/selfmade/mushrooms/blue_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/blue_mush.tscn",
		"stack_group": "mushrooms",
		"show_in_inventory": true,
		"show_in_hotbar": false
	},
	
	"brown_mush": {
		"name_de": "Brauner Pilz",
		"name_en": "Brown mushroom",
		"description_de": "Ein brauner Pilz.",
		"description_en": "A brown mushroom.",
		"icon":"res://assets/sprites/selfmade/mushrooms/brown_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/brown_mush.tscn",
		"stack_group": "mushrooms",
		"show_in_inventory": true,
		"show_in_hotbar": false
	},
	
	"green_mush": {
		"name_de": "Grüner Pilz",
		"name_en": "Green mushroom",
		"description_de": "Ein grüner Pilz.",
		"description_en": "A green mushroom.",
		"icon":"res://assets/sprites/selfmade/mushrooms/green_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/green_mush.tscn",
		"stack_group": "mushrooms",
		"show_in_inventory": true,
		"show_in_hotbar": false
	},
	
	"orange_mush": {
		"name_de": "Orangener Pilz",
		"name_en": "Orange mushroom",
		"description_de": "Ein orangener Pilz.",
		"description_en": "A orangener mushroom.",
		"icon":"res://assets/sprites/selfmade/mushrooms/orange_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/orange_mush.tscn",
		"stack_group": "mushrooms",
		"show_in_inventory": true,
		"show_in_hotbar": false
	},
	
	"red_mush": {
		"name_de": "Roter Pilz",
		"name_en": "Red mushroom",
		"description_de": "Ein roter Pilz.",
		"description_en": "A red mushroom.",
		"icon":"res://assets/sprites/selfmade/mushrooms/red_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/red_mush.tscn",
		"stack_group": "mushrooms",
		"show_in_inventory": true,
		"show_in_hotbar": false
	},
	
	"yellow_mush": {
		"name_de": "Gelber Pilz",
		"name_en": "Yellow mushroom",
		"description_de": "Ein gelber Pilz.",
		"description_en": "A yellow mushroom.",
		"icon":"res://assets/sprites/selfmade/mushrooms/yellow_mush.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/mushrooms/yellow_mush.tscn",
		"stack_group": "mushrooms",
		"show_in_inventory": true,
		"show_in_hotbar": false
	},
	
	"stonepanel": {      # used for the hotbar
		"name_de": "Steinpanel",
		"name_en": "Stone Panel",
		"icon": "res://assets/sprites/selfmade/Piece2.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/stone pieces/view_all_pieces_hb.tscn",
		"show_in_inventory": false,
  		"show_in_hotbar": true

	},

	"stone_piece_1": {
		"name_de": "Stück 1",
		"name_en": "Piece 1",
		"description_de": "Oh, ein Steinstück! Wie spannend!",
		"description_en": "Oh, a piece of a stone panel! How exciting!",
		"icon": "res://assets/sprites/selfmade/stonesForInven/Piece1.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_1.tscn",
		"stack_group": "stonepanel",
  		"show_in_inventory": true,
  		"show_in_hotbar": false
	},
	
	"stone_piece_2": {
		"name_de": "Stück 2",
		"name_en": "Piece 2",
		"description_de": "Oh, ein Steinstück! Wie spannend!",
		"description_en": "Oh, a piece of a stone panel! How exciting!",
		"icon": "res://assets/sprites/selfmade/Piece2.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_2.tscn",
		"stack_group": "stonepanel",
  		"show_in_inventory": true,
  		"show_in_hotbar": false
	},
	
	"stone_piece_3": {
		"name_de": "Stück 3",
		"name_en": "Piece 3",
		"description_de": "Oh, ein Steinstück! Wie spannend!",
		"description_en": "Oh, a piece of a stone panel! How exciting!",
		"icon": "res://assets/sprites/selfmade/Piece3.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_3.tscn",
		"stack_group": "stonepanel",
  		"show_in_inventory": true,
  		"show_in_hotbar": false
	},
	
	"stone_piece_4": {
		"name_de": "Stück 4",
		"name_en": "Piece 4",
		"description_de": "Oh, ein Steinstück! Wie spannend!",
		"description_en": "Oh, a piece of a stone panel! How exciting!",
		"icon": "res://assets/sprites/selfmade/stonesForInven/Piece4.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_4.tscn",
		"stack_group": "stonepanel",
  		"show_in_inventory": true,
  		"show_in_hotbar": false
	},
	
	"stone_piece_5": {
		"name_de": "Stück 5",
		"name_en": "Piece 5",
		"description_de": "Oh, ein Steinstück! Wie spannend!",
		"description_en": "Oh, a piece of a stone panel! How exciting!",
		"icon": "res://assets/sprites/selfmade/Piece5.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_5.tscn",
		"stack_group": "stonepanel",
  		"show_in_inventory": true,
  		"show_in_hotbar": false
	},
	
	"stone_piece_6": {
		"name_de": "Stück 6",
		"name_en": "Piece 6",
		"description_de": "Oh, ein Steinstück! Wie spannend!",
		"description_en": "Oh, a piece of a stone panel! How exciting!",
		"icon": "res://assets/sprites/selfmade/stonesForInven/Piece6.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/obj/stone_piece_6.tscn",
		"stack_group": "stonepanel",
  		"show_in_inventory": true,
  		"show_in_hotbar": false
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
		"description_en": "A telescope... but it's a bit too heavy to hold by hand. Maybe I can put it somewhere and then use it to observe the constellations.",
		"description_de": "Ein Teleskop... aber um es alleine in der Hand zu halten ist es etwas zu schwer. Vielleicht kann ich es irgendwo reinsetzen und damit dann die Sternenbilder betrachten.",
		"icon": "res://assets/sprites/selfmade/telescope.png",
		"icon_size": Vector2(55,55),
		"world_scene": "res://scenes/interactables/objects/telescope.tscn"
},

	"map": {
		"name_de": "Karte",
		"name_en": "Map",
		"description_en": "Helps with orientation. Sometimes.",
		"description_de": "Hilft beim Orientieren. Manchmal.",
		"icon": "res://assets/sprites/selfmade/map/map_item.png",
		"icon_size": Vector2(30,30),
		"world_scene": "res://scenes/interactables/objects/map_item.tscn"
},



}
