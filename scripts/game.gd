extends Node3D

@onready var lasers = $lasers
@onready var enemies = $enemies
@onready var playerscene = $player
@onready var enemy1 = preload("res://scenes/enemy_1.tscn")
@onready var turretbombs = $turretbombs
@onready var turretbombscene = preload("res://scenes/turretbomb.tscn")
@onready var splosions = $splosions
@onready var splosionscene = preload("res://scenes/splosions.tscn")
@onready var healthbar = $CanvasLayer/HealthBar
@onready var boomsound = $BoomSound
@onready var timermusic = $TimerMusic
@onready var countdown = $Countdown
@onready var boomtimer = $CanvasLayer/BoomTimer
@onready var boomcount = $CanvasLayer/BoomTimer/Count

@export var max_enemies = 3
@export var healthbar_inset := 3.0   # keep in sync with the bars' border width
@export var boom_danger_at := 3
@export var boom_danger_color := Color(1, 0.15, 0.05)
var boom_fill: StyleBoxFlat
var boom_fill_danger: StyleBoxFlat
var boom_left := -1


# ProgressBar paints its fill across the whole rect, which covers the border at full value.
# Has to be done here - the inspector won't take a negative expand margin.
func inset_fill(sb: StyleBoxFlat):
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		sb.set_expand_margin(side, -healthbar_inset)


func _ready():
	inset_fill(healthbar.get_theme_stylebox("fill"))

	boom_fill = boomtimer.get_theme_stylebox("fill")
	inset_fill(boom_fill)
	boom_fill_danger = boom_fill.duplicate()   # duplicate so the danger box keeps the borders and margins
	boom_fill_danger.bg_color = boom_danger_color
	boomtimer.max_value = countdown.wait_time

	healthbar.max_value = playerscene.max_health   # seed here, not from the player - our @onready vars aren't up yet during its _ready
	healthbar.value = playerscene.health
	spawn_enemy1()
	await get_tree().create_timer(2.0).timeout
	timermusic.play()


func _process(_delta):
	var left := ceili(countdown.time_left)
	if left == boom_left:
		return   # only touch the UI when the whole number ticks over
	boom_left = left
	boomtimer.value = left
	boomcount.text = str(left)
	boomtimer.add_theme_stylebox_override("fill", boom_fill_danger if left <= boom_danger_at else boom_fill)


func _on_turret_laser_shot(laser, gp, gr):
	lasers.add_child(laser)   # must be in tree before setting global_*
	laser.global_rotation = gr
	laser.global_position = gp   # gp is already the muzzle position
	laser.direction = Vector3(cos(gr.z), sin(gr.z), 0)
	
func spawn_enemy1():
	while true:
		await enemies.get_tree().create_timer(5).timeout
		if enemies.get_child_count() < max_enemies:
			var enemy = enemy1.instantiate()
			var gp: Vector3
			var redo = true
			while redo:
				gp = Vector3(randf_range(-7,7),randf_range(-4,4),0)
				if gp.distance_to(playerscene.global_position) > 1:
					redo = false
				else:
					continue
				for i in enemies.get_children():
					if gp.distance_to(i.global_position) < 1:
						redo = true
						break
			enemies.add_child(enemy)
			enemy.turret.laser_shot.connect(_on_turret_laser_shot)   # spawned enemies aren't editor-wired
			enemy.global_position = gp


func _on_player_throw_turret(zrotation: float, pos: Vector3):
	var tb = turretbombscene.instantiate()
	turretbombs.add_child(tb)
	tb.rotate(Vector3(0,0,1),zrotation)
	tb.global_position = pos
	tb.scale=Vector3(0.4,0.4,0.4)
	tb.velocity=Vector3(5,0,0).rotated(Vector3(0,0,1),zrotation)
	tb.move_and_slide()

func _on_player_health_changed(current):
	healthbar.value = current

func boom(pos):
	var ss = splosionscene.instantiate()
	splosions.add_child(ss)
	ss.global_position = pos

func _on_countdown_timeout():
	boomsound.play()
	print("Boom")
	if playerscene.has_turret:
		boom(playerscene.global_position)
	else:
		var tbomblocation: Vector3
		for i in turretbombs.get_children():
			if i is tbomb:
				tbomblocation=i.global_position
		boom(tbomblocation)
	await get_tree().create_timer(2.0).timeout
	timermusic.play()
