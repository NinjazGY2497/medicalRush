extends CharacterBody2D

var medicine_count = 0
var max_time: float = 20
var time_left: float = max_time

func _physics_process(delta):
	# Movement
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * 250
	move_and_slide()
	
	# Progress Bar
	$CanvasLayer/ProgressBar.max_value = max_time
	
	time_left -= delta
	$CanvasLayer/ProgressBar.value = time_left
	
	if time_left <= 0: # When time runs out
		get_tree().change_scene_to_file("res://result_menu.tscn")

func _on_pickup_area_area_entered(area):
	if area.is_in_group("medicine") and not $HeldMedicine.visible:
		area.visible = false
		area.set_deferred("monitoring", false)
		$HeldMedicine.visible = true
		
	if area.is_in_group("patient") and $HeldMedicine.visible:
		$HeldMedicine.visible = false
		
#		# Update medicine count
		medicine_count += 1
		$CanvasLayer/MedicineCountDisplay.text = "Medicine: %d" % [medicine_count]
		
		# Update progress bar (increase by 10%)
		time_left = min(time_left + (max_time * 0.1), max_time)
		
		# Spawn new medecine (change its position & make it visible)
		var medecine = get_tree().current_scene.get_node("Medicine")
		
		var screenSize = get_viewport_rect().size
		var margin = 50.0
		var randX = randf_range(0 + margin, screenSize.x - margin)
		var randY = randf_range(0 + margin, screenSize.y - margin)
		
		medecine.global_position = Vector2(randX, randY)
		medecine.visible = true
		medecine.set_deferred("monitored", true)
		
		# Check for victory
		if medicine_count >= 10:
			get_tree().change_scene_to_file("res://victory_menu.tscn")
