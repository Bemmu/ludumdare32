package en;
import en.Mob;

class Pet extends Entity {
	public var master:Entity = null;
	public var petType:String;
	public var attacking = false;
	public var attackSpeed = 2;
	public var yOff = 0;
	public var homeX = 0;
	public var fightingCounter = 0;
	public var fightDelay = 100;
	static public var cost = 100;
	public var attackStrength = 10;
	public var criticalLikelihood = 0.5;
	public var criticalAttackStrength = 30;
	public var attackDelay = 30;
	public var healingSpeed = 0.01;
	public var enemy:Mob = null;

	public function new() {
		super();
		petType = "what";
	}

	public function availableForAttacking() {
		return !attacking && fightingCounter == 0;
	}

	public function attack(track) {
		attacking = true;
		this.track = track;
		anim(petType + "_run");
	}

	public function recall() {
		attacking = false;
		xx = homeX;
		anim(petType + "_idle");
	}

	override public function tick() {
		super.tick();

		if (!attacking && health < 100 && Math.random() < healingSpeed) {
			health++;
		}

		if (fightingCounter > 0) {
			if (fightingCounter == 1) {
				recall();
			}
			fightingCounter--;
			return;
		}

		if (attacking) {
			xx += attackSpeed;
			yy = yy * 0.80 + trackPos() * 0.20;
		} else {
			yy = yy * 0.80 + (master.yy + yOff) * 0.20;
		}
	}
}
