package en;

class Dog extends Pet {
	static public var cost = 100;

	public function new() {
		super();
		petType = "dog";
		anim("dog_idle");
	}
}