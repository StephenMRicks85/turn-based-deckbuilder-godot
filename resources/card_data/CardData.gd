# File: CardData.gd
extends Resource
class_name CardData

@export var id: String
@export var display_name: String
@export var description: String
@export var energy_cost: int = 1
@export var damage_amount: int
@export var target: String = "enemy" #target
@export var type: String # "Attack", "Skill", "Status"
@export var theme: String # "Evidence", "Manipulation", "Diplomacy"
@export var rarity: String # "Common", "Rare", etc
@export var requires_target: bool = true
@export var effect: CardEffect
