class_name Pixel
extends Node2D

onready var fill = $Polygon2D

func set_color(col):
	fill.modulate = col
