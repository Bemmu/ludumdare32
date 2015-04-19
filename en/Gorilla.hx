package en;

class Gorilla extends Pet {
	static public var cost = 10000;

	public function new() {
		super();
		petType = "gorilla";
		anim("gorilla_idle");
	}
}