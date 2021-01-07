import dn.heaps.HParticle;

class Fx extends dn.Process {
	var game(get,never) : Game; inline function get_game() return Game.ME;
	var level(get,never) : Level; inline function get_level() return Game.ME.level;

	public var pool : ParticlePool;

	public var bgAddSb		: h2d.SpriteBatch;
	public var bgNormalSb   : h2d.SpriteBatch;
	public var topAddSb     : h2d.SpriteBatch;
	public var topNormalSb  : h2d.SpriteBatch;

	public function new() {
		super(Game.ME);

		pool = new ParticlePool(Assets.tiles.tile, 2048, Const.FPS);

		bgAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bgAddSb, Const.DP_FX_BG);
		bgAddSb.blendMode = Add;
		bgAddSb.hasRotationScale = true;

		bgNormalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bgNormalSb, Const.DP_FX_BG);
		bgNormalSb.hasRotationScale = true;

		topNormalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(topNormalSb, Const.DP_FX_FRONT);
		topNormalSb.hasRotationScale = true;

		topAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(topAddSb, Const.DP_FX_FRONT);
		topAddSb.blendMode = Add;
		topAddSb.hasRotationScale = true;
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();
		bgAddSb.remove();
		bgNormalSb.remove();
		topAddSb.remove();
		topNormalSb.remove();
	}

	public function clear() {
		pool.killAll();
	}

	public inline function allocTopAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topAddSb, t, x, y);
	}

	public inline function allocTopNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topNormalSb, t,x,y);
	}

	public inline function allocBgAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgAddSb, t,x,y);
	}

	public inline function allocBgNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgNormalSb, t,x,y);
	}

	public inline function getTile(id:String) : h2d.Tile {
		return Assets.tiles.getTileRandom(id);
	}

	public function killAll() {
		pool.killAll();
	}

	public function markerEntity(e:Entity, ?c=0xFF00FF, ?short=false) {
		#if debug
		if( e==null )
			return;

		markerCase(e.cx, e.cy, short?0.03:3, c);
		#end
	}

	public function markerCase(cx:Int, cy:Int, ?sec=3.0, ?c=0xFF00FF) {
		#if debug
		var p = allocTopAdd(getTile("fxCircle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.lifeS = sec;

		var p = allocTopAdd(getTile("pixel"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.lifeS = sec;
		#end
	}

	public function markerFree(x:Float, y:Float, ?sec=3.0, ?c=0xFF00FF) {
		#if debug
		var p = allocTopAdd(getTile("fxDot"), x,y);
		p.setCenterRatio(0.5,0.5);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		p.lifeS = sec;
		#end
	}

	public function markerText(cx:Int, cy:Int, txt:String, ?t=1.0) {
		#if debug
		var tf = new h2d.Text(Assets.fontTiny, topNormalSb);
		tf.text = txt;

		var p = allocTopAdd(getTile("fxCircle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.colorize(0x0080FF);
		p.alpha = 0.6;
		p.lifeS = 0.3;
		p.fadeOutSpeed = 0.4;
		p.onKill = tf.remove;

		tf.setPosition(p.x-tf.textWidth*0.5, p.y-tf.textHeight*0.5);
		#end
	}

	inline function collides(p:HParticle, offX=0., offY=0.) {
		return level.hasCollision( Std.int((p.x+offX)/Const.GRID), Std.int((p.y+offY)/Const.GRID) );
	}

	public function flashBangS(c:UInt, a:Float, ?t=0.1) {
		var e = new h2d.Bitmap(h2d.Tile.fromColor(c,1,1,a));
		game.root.add(e, Const.DP_FX_FRONT);
		e.scaleX = game.w();
		e.scaleY = game.h();
		e.blendMode = Add;
		game.tw.createS(e.alpha, 0, t).end( function() {
			e.remove();
		});
	}


	public function jumpingDust(x:Float, y:Float, dir: Int) {
		var c = C.interpolateInt(0xffcc00, 0xff643e, 0.5);

		for(i in 0...4) {
			var p = allocBgNormal(getTile("fxDust"), x+rnd(0,1,true), y-rnd(0,2));
			p.alpha = rnd(0.3,0.7);
			p.gy = -rnd(0.007,0.010);
			if (dir == 1)
				p.gx = rnd(0.007,0.012);
			else 
				p.gx = -rnd(0.007,0.012);
			p.frict = rnd(0.97,0.98);
			p.scaleX*=rnd(0.6,0.9,true);
			p.scaleY*=rnd(0.6,0.9,true);
			p.lifeS = rnd(0.1,0.3);
			p.setFadeS(rnd(0.5,1), 0.2, 0.5);
		}
	}


	function _bloodPhysics(p:HParticle) {
		if( collides(p) && p.data0!=1 ) {
			p.dx = p.dy = 0;
			p.gy *= rnd(0.,0.2);
			p.frict *= 0.7;
			p.data0 = 1;
			p.scaleX*=rnd(1,2,true);
			p.scaleY*=rnd(1,2,true);
			p.scaleMul = rnd(0.98,0.999);
		}
	}

	public function gibs(x:Float,y:Float, dir:Int) {
		for(i in 0...10) {
			var p = allocTopNormal(getTile("fxGib"), x+rnd(0,4,true), y+rnd(0,8,true));
			p.colorize(0x951d1d);
			p.setFadeS(rnd(0.6,1), 0, rnd(1,3));
			p.dx = dir*rnd(3,7);
			p.dy = rnd(-1,0);
			p.gy = rnd(0.07,0.10);
			p.rotation = rnd(0,M.PI2);
			p.frict = rnd(0.92,0.96);
			p.lifeS = rnd(3,10);
			p.onUpdate = _bloodPhysics;
		}
	}

	function oscilate(p:HParticle) {
		p.dx = Math.cos(ftime*p.data0 + p.data1) * p.data2;
	}

	override function update() {
		super.update();

		pool.update(game.tmod);
	}
}