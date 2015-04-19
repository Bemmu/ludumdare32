package en;

class Deer extends Mob {
	public function new(track:Int) {
		super(track);
		anim("deer_walk");
		jumpFreq = 20;  
		monsterType = "deer";
	}
}