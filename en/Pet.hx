package en;

class Pet extends Entity {
	public var master:Entity = null;
	public var petType:String;
	public var attacking:Bool = false;
	public var attackSpeed = 2;
	public var yOff = 0;

	public var attackStrength = 10;
	public var criticalLikelihood = 0.5;
	public var criticalAttackStrength = 30;

	public function new() {
		super();
		petType = "dash";
	}

	public function availableForAttacking() {
		return !attacking;
	}

	public function attack(track) {
		attacking = true;
		this.track = track;
		anim(petType + "_run");
	}

	public function recall() {
		attacking = false;
		xx = 20;
		anim(petType + "_idle");
	}

	override public function tick() {
		super.tick();

		if (attacking) {
			xx += attackSpeed;
		} else {
			yy = yy * 0.80 + (master.yy + yOff) * 0.20;
		}
	}
}
