package en;

class Mob extends Entity {
	public var monsterType:String;
	public var speed = 0.5;
	public var targetX:Float;
	public var totalTicks = 0;

	public function new(track:Int) {
		super();
		this.track = track;
		monsterType = "boy";
		anim("boy_idle");
		flipped = true;
		xx = 300;
		targetX = 300;
		yy = trackPos();
	}

	override public function tick() {
		super.tick();
		totalTicks++;

		if ((totalTicks%80) == 0) {
			targetX -= 20;
		}
		xx = targetX * 0.20 + xx * 0.80;
	}
}
