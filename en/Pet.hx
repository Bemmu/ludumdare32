package en;

class Pet extends Entity {
	public var following:Entity = null;
	public var petType:String;

	public function new() {
		super();
		petType = "dash";
	}

	public function availableForAttacking() {
		return true;
	}

	public function attack() {
	}

	override public function tick() {
		super.tick();

		yy = yy * 0.80 + following.yy * 0.20;
	}
}
