class_name Statics

const PIXELS_TO_UNITS_CONVERSION: float = 32

enum GROUPS {
	PLAYER_ACTORS,
	ENEMY_ACTORS
}


enum COLORS {
	YELLOW,
	ORANGE,
	RED,
	PURPLE,
	BLUE,
	INDIGLO
}

const ColorDict: Dictionary[COLORS, Color] = {
	COLORS.YELLOW: Color("ffb000"),
	COLORS.ORANGE: Color("FE6100"),
	COLORS.RED: Color("DC267F"),
	COLORS.PURPLE: Color("785EF0"),
	COLORS.BLUE: Color("648FFF"),
	COLORS.INDIGLO: Color("00ffb0")
}
