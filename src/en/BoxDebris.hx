package en;

class BoxDebris extends Entity {
    public var origin : Null<LPoint>;
    public var type : Boxes;
    
	public function new(x,y,type,debris) {
        super(x, y-1);
        game.cd.setS("notsafetorestart",Const.INFINITE);
        gravityMul*=0.20;
        frictX = frictY = 0.96;
        origin = makePoint();
        dy = rnd(-0.1,-0.2);
        dx = rnd(-0.1,0.1);
		switch type {
            case Type1: 
                switch debris {
                    case 0: 
                        spr.set("box1Debris0");
                    case 1: 
                        spr.set("box1Debris1");
                    case 2: 
                        spr.set("box1Debris2");		
                    case 3: 
                        spr.set("box1Debris3");	                				
                }
            case Type2: 
                switch debris {
                    case 0: 
                        spr.set("box2Debris0");
                    case 1: 
                        spr.set("box2Debris1");
                    case 2: 
                        spr.set("box2Debris2");		
                    case 3: 
                        spr.set("box2Debris3");	                				
                }    
            case Type3: 
                switch debris {
                    case 0: 
                        spr.set("box3Debris0");
                    case 1: 
                        spr.set("box3Debris1");
                    case 2: 
                        spr.set("box3Debris2");		
                    case 3: 
                        spr.set("box3Debris3");	                				
                }                              
        }
        game.scroller.add(spr, Const.DP_BG);
		game.delayer.addS(()->{
			delayedDie();
		}, 1);        
	}


	public function delayedDie() {
        super.onDie();
        game.cd.unset("notsafetorestart");
	}

	override function dispose() {
		super.dispose();
	}

	override function postUpdate() {
		super.postUpdate();
	}

	override function update() {
        super.update();
    }
}
