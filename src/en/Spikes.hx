package en;

class Spikes extends Entity {
	public static var ALL : Array<Spikes> = [];
	public var origin : Null<LPoint>;
	public var type : Enum_Spikes;
	var data : Entity_Spikes;

	public function new(e:Entity_Spikes) {
		super(e.cx, e.cy);
		ALL.push(this);
		data = e;
		type = e.f_spikes;	
		origin = makePoint();
		circularCollisions = true;
		set_hei(7);
		switch type {
            case Top: 
				spr.anim.registerStateAnim("spikesTop",0, ()-> isAlive());
			case Down: 
				spr.anim.registerStateAnim("spikesDown",0, ()-> isAlive());
			case Left: 
				spr.anim.registerStateAnim("spikesLeft",0, ()-> isAlive());	
			case Right: 
				spr.anim.registerStateAnim("spikesRight",0, ()-> isAlive());		
		}
	}

	override function postUpdate() {
		super.postUpdate();
	}

	override function update() {
		super.update();
		gravityMul = 0.;
		dy = 0.;	
    }
}
