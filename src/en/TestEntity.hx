package en;

class TestEntity extends Entity {
	public static var ALL : Array<TestEntity> = [];
	public var origin : Null<LPoint>;
	var data : Entity_TestEntity;

	public function new(e:Entity_TestEntity) {
		super(e.cx, e.cy);
		ALL.push(this);
		origin = makePoint();
		circularCollisions = true;
		set_radius(9);
		var g = new h2d.Graphics(spr);
		g.beginFill(0xffffff);
		g.drawRect(-8,0,16,-16);
		game.scroller.add(spr, Const.DP_BG);
	}

	public function delayedDie() {
		super.onDie();
	}	

	override function dispose() {
		super.dispose();
	}

	override function postUpdate() {
		super.postUpdate();
	}

	override function update() {
		super.update();
		gravityMul = 0.;

		level.setExtraCollision(cx,cy, true);
		level.setExtraCollision(cx,cy+1, true);
    }
}
