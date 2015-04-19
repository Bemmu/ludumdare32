package en;

class Mob extends Entity {
	public var monsterType:String;
	public var speed = 0.5;
	public var targetX:Float;
	public var totalTicks = 0;
	public var moneyDrop = 100;
	public var fightCounter = 0;
	public var leaving = false;
	public var damagedBoy = false;
	public var attackStrength = 20;
	public var jumpFreq = 80;
	public var jumpSize = 20;

	public function new(track:Int) {
		super();
		this.track = track;
		monsterType = "boy";
		anim("henro_walk");
		flipped = false;
		xx = 300;
		targetX = 300;
		yy = trackPos();
	}

	override public function tick() {
		super.tick();

		// Passed line
		if (xx < 75) {
//			targetX = -32;
			xx -= 4;
			if (xx < -32) {
				requestRemoval = true;
			}
			return;
		}

		if (fightCounter > 0) {
			fightCounter--;
			return;
		}

		totalTicks++;

		if ((totalTicks%jumpFreq) == 0) {
			targetX -= jumpSize;
		}
		xx = targetX * 0.20 + xx * 0.80;
	}
}
