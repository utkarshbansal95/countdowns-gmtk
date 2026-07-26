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
@onready var scorelabel = $CanvasLayer/Score

@export var max_enemies = 3
@export var healthbar_inset := 3.0   # keep in sync with the bars' border width
@export var boom_danger_at := 3
@export var boom_danger_color := Color(1, 0.15, 0.05)
var boom_fill: StyleBoxFlat
var boom_fill_danger: StyleBoxFlat
var boom_left := -1
var score := 0


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
	scorelabel.text = "Score: 0"
	_warm_explosion_shader()   # not awaited - must never be able to stall the rest of _ready
	spawn_enemy1()
	await get_tree().create_timer(2.0).timeout
	timermusic.play()


# The explosion shader only compiles the first time it's actually drawn, which would be the
# first boom - mid-fight, worst possible moment. Draw one sub-pixel copy now and eat it here.
func _warm_explosion_shader() -> void:
	var w = splosionscene.instantiate()
	w.set_process(false)   # otherwise it runs its lifetime and rewrites the hitbox radius
	splosions.add_child(w)
	w.monitoring = false
	w.scale = Vector3.ONE * 0.001
	w.global_position = playerscene.global_position
	w.get_node("Fire").material_override.set_shader_parameter("progress", 0.4)
	# process_frame, not RenderingServer.frame_post_draw - the latter never fires headless,
	# which left this coroutine hung and leaking the node on every dedicated-server run.
	for _i in 3:
		await get_tree().process_frame
	w.queue_free()


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
			enemy.died.connect(_on_enemy_died)
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

func _on_enemy_died():
	score += 1
	scorelabel.text = "Score: %d" % score

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
