package en;

class Fruit extends Entity {
	public static var ALL : Array<Fruit> = [];
	public var type : Fruits;
	var data : Entity_Fruit;
	var origin : LPoint;

	public function new(e:Entity_Fruit) {
		super(e.cx, e.cy);
		ALL.push(this);
		data = e;
		type = e.f_Fruits; 
		origin = makePoint();
		initLife(1);
		circularCollisions = true;
		spr.setCenterRatio(0.5,0.75);
		spr.anim.setGlobalSpeed(0.35);
		spr.anim.registerStateAnim("fruitCollected",1, 0.5, ()-> cd.has("collected"));    
		switch type {
            case Apple: 
				spr.anim.registerStateAnim("apple",0, ()-> isAlive());
            case Banana: 
				spr.anim.registerStateAnim("banana",0, ()-> isAlive());
			case Cherry: 
				spr.anim.registerStateAnim("cherry",0, ()-> isAlive());
            case Kiwi: 
				spr.anim.registerStateAnim("kiwi",0, ()-> isAlive());
            case Melon: 
				spr.anim.registerStateAnim("melon",0, ()-> isAlive());
            case Orange:             
				spr.anim.registerStateAnim("orange",0, ()-> isAlive());
            case Pineapple: 
				spr.anim.registerStateAnim("pineapple",0, ()-> isAlive());
            case Strawberry: 
				spr.anim.registerStateAnim("strawberry",0, ()-> isAlive());     
		};
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function onDie() {
		// isCollected = true;
		cd.setS("collected",Const.INFINITE);
		level.fruitCollected += 1;

		// Detect level cleared
		if ( level.fruitToCollect == level.fruitCollected )
			game.levelComplete();

		// Delay death to display popping animation
		game.delayer.addS(()->{
			delayedDie();
		}, 0.3);
	}

	public function delayedDie() {
		super.onDie();
	}

	override function update() {
		super.update();
		gravityMul = 0.;
		dy = 0.;
	}
}