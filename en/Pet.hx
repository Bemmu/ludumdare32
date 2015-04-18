package en;

class Pet extends Entity {
	public var master:Entity = null;
	public var petType:String;
	public var attacking:Bool = false;
	public var attackSpeed = 2;

	public function new() {
		super();
		petType = "dash";
	}

	public function availableForAttacking() {
		return true;
	}

	public function attack() {
		anim(petType + "_run");
		attacking = true;
	}

	override public function tick() {
		super.tick();

		if (attacking) {
			xx += attackSpeed;

			if (xx > 200) {
				xx = 20;
				attacking = false;
				anim(petType + "_idle");
			}
		} else {
			yy = yy * 0.80 + master.yy * 0.20;
		}
	}
}
