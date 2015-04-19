package en;

class Cat extends Pet {
	static public var cost = 1000;

	public function new() {
		super();
		fightDelay = 50;
		healingSpeed = 0.005;
		criticalAttackStrength = 100;
		petType = "cat";
		anim("cat_idle");
	}
}