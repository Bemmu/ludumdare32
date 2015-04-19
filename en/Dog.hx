package en;

class Dog extends Pet {
	static public var cost = 100;

	public function new() {
		super();
		attackStrength = 2;
		fightDelay = 10;
		healingSpeed = 0.01;
		petType = "dog";
		anim("dog_idle");
	}
}