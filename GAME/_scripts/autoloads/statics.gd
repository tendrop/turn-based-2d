class_name Statics

const PIXELS_TO_UNITS_CONVERSION: float = 32
const REACHED_DESTINATION_THRESHOLD: float = 1.0
const MOVEMENT_SPEED: float = 100.0
const UNIT_SCALE: float = 0.5

enum PLAYER_TASK {
	NONE,
	MOVE,
	INFILTRATE
}

enum ENEMY_TASK {
	MOVE
}


enum GROUPS {
	PLAYER_ACTORS,
	ENEMY_MOBS
}


enum COLORS {
	YELLOW,
	ORANGE,
	RED,
	PURPLE,
	BLUE,
	INDIGLO,
	GRAY_85,
	GRAY_75,
	GRAY_66,
	GRAY_50,
	GRAY_33,
	GRAY_25
}

const ColorDict: Dictionary[COLORS, Color] = {
	COLORS.YELLOW: Color("ffb000"),
	COLORS.ORANGE: Color("FE6100"),
	COLORS.RED: Color("DC267F"),
	COLORS.PURPLE: Color("785EF0"),
	COLORS.BLUE: Color("648FFF"),
	COLORS.INDIGLO: Color("00ffb0"),
	COLORS.GRAY_85: Color("262626"),
	COLORS.GRAY_75: Color("404040"),
	COLORS.GRAY_66: Color("545454"),
	COLORS.GRAY_50: Color("808080"),
	COLORS.GRAY_33: Color("A8A8A8"),
	COLORS.GRAY_25: Color("C0C0C0")
}


static func mouse_actions_enabled() -> bool:
	match GameStateManager.current_game_state:
		GameStateManager.GAME_STATE.PLAYER_IDLE, GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			return true
		_:
			return false
			
static func has_reached_current_destination(my_global_pos: Vector2, destination_pos: Vector2) -> bool:
	return my_global_pos.distance_to(destination_pos) <= Statics.REACHED_DESTINATION_THRESHOLD
