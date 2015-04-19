package en;

class Salaryman extends Mob {
	public function new(track:Int) {
		super(track);
		anim("salaryman_walk");
		monsterType = "salaryman";
	}
}