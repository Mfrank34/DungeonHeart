extends Node

# global player data.
var Player_Alive = false
var Player_Max_Health = 300
var Player_Health = 300

# combat system.
var player_current_attack = false
var Player_Damage_Output = 20

# enemy tracking
var amount_enemys = 0

# buffs system
var extra_health = 0
var extra_damage = 0 # impleted on enemys
var extra_movement = 0 

# diffcultiy level
var difficulty_level = 0
