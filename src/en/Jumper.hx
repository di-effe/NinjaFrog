package en;

class Jumper extends Entity {
	public static var ALL : Array<Jumper> = [];
	public var origin : Null<LPoint>;
	var data : Entity_Jumper;
    
	public function new(e:Entity_Jumper) {
		super(e.cx, e.cy);
		ALL.push(this);
        origin = makePoint();
		spr.anim.setGlobalSpeed(0.5);
		spr.anim.registerStateAnim("jumperIdle",0, ()-> isAlive());
		spr.anim.registerStateAnim("jumperTriggered",1, 0.5, ()-> cd.has("triggered")); 
		game.scroller.add(spr, Const.DP_BG);
		circularCollisions = true;
		set_hei(11);
		set_radius(8);
	}

	public function triggered() {
		cd.setS("triggered", Const.INFINITE);
		hero.bump(0,-1.51);
		Assets.SLIB.spring(0.5);
		game.delayer.addS(()->{
			cd.unset("triggered");
			hero.cancelVelocities();
		}, 0.5);
	}

	override function update() {
		super.update();
    }
}
