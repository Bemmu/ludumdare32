package en;

class Bird extends Pet {
	static public var cost = 500;

	public function new() {
		super();
		petType = "bird";
		anim("bird_idle");
	}
}