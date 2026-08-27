class_name Interactable
extends Node3D

var interacted = false
@export var Name = "Interactable"

func interact(_player):
	interacted = true
