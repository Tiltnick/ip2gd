extends Node

signal puzzle_started(puzzle_data: Dictionary)
signal puzzle_ended(puzzle_data: Dictionary)

func started(id: String, title: String = "") -> void:
	puzzle_started.emit({
		"id": id,
		"title": title
	})

func ended(id: String, title: String = "", result: String = "closed") -> void:
	puzzle_ended.emit({
		"id": id,
		"title": title,
		"result": result
	})
