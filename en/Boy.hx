package en;

class Boy extends Entity {
	public var lanes:Int;

	public function new() {
		super();
		anim("boy_idle");
		track = 0;
		xx = 50;
		yy = trackPos();
	}

	public function trackMove(amount:Int) {
		track += amount;
	}

	override public function tick() {
		yy = trackPos() * 0.20 + yy * 0.80;
		if (Math.abs(yy - trackPos()) < 0.5) { // snap to track when close by
			yy = trackPos();
		}
	}
}