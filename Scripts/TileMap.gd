extends TileMap


@onready var player = $"../Player"

@onready var tile_map = $"."

var index = 1
var trapTimer = 0
func _ready():
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		setTrap()
	trapTimer += delta

func remove_specific_tile(atlas_coords: Vector2i):
	var current_tile_id = tile_map.get_cell_alternative_tile(index,atlas_coords)
	
	if current_tile_id != -1:
		
		set_cell(index,atlas_coords)
		
func setTrap():
	print(tile_map.get_layer_name(1))

	var playersGlobalPosition = player.global_position
	
	var cellPosition = tile_map.local_to_map(playersGlobalPosition)
	
	var cellPositionbelow = cellPosition + Vector2i(0,2)
	
	var tile_data = tile_map.get_cell_tile_data(index,cellPositionbelow)
	

	if tile_data != null:
		# Get the tileset source
		var tileset = tile_map.get_tileset()
		var source_id = tile_map.get_cell_source_id(index,cellPositionbelow)
		var atlas_coords = tile_map.get_cell_atlas_coords(index,cellPositionbelow) 
		tile_map.set_cell(index, cellPositionbelow, -1)
		if tileset.has_source(source_id):
			var source = tileset.get_source(source_id)
			
			if source is TileSetAtlasSource:
				var atlas_source = source as TileSetAtlasSource
				# Check if the tile has collision shapes
				var tile_id = tile_map.get_cell_alternative_tile(index,atlas_coords)
						# Get the tile data
				var tile = atlas_source.get_tile_at_coords(atlas_coords)
				remove_specific_tile(atlas_coords)
				
				
				
				
	else:
		print("it is null")
		
		
func _notification(what):
	if (what == NOTIFICATION_PREDELETE):
		print("I am Free")
