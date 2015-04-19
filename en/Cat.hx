package en;

class Cat extends Pet {
	static public var cost = 1000;

	public function new() {
		super();
		petType = "cat";
		anim("cat_idle");
	}
}