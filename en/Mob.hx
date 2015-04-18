package en;

class Mob extends Entity {
	public var monsterType:String;
	public var speed = 1;

	public function new() {
		super();
		monsterType = "boy";
		anim("boy_idle");
		flipped = true;
		xx = 300;

		yy = trackPos();
	}

	override public function tick() {
		super.tick();
		xx -= speed;
	}
}
