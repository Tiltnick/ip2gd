extends Node

var npc
var sm


func setup(_npc, _sm):
	npc = _npc
	sm = _sm


func enter() -> void:
	npc.velocity = Vector2.ZERO


func physics_update(_delta): pass
func exit(): pass
