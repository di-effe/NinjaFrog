import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;

	/** Game controller (pad or keyboard) **/
	public var ca : dn.heaps.Controller.ControllerAccess;

	/** Particles **/
	public var fx : Fx;

	/** Basic viewport control **/
	public var camera : Camera;

	/** Container of all visual game objects. Ths wrapper is moved around by Camera. **/
	public var scroller : h2d.Layers;

	/** Level data **/
	public var level : Level;

	/** UI **/
	public var hud : ui.Hud;

	/** MISC **/
	var fadeMask : h2d.Bitmap;	

	/** Slow mo internal values**/
	var curGameSpeed = 1.0;
	var slowMos : Map<String, { id:String, t:Float, f:Float }> = new Map();

	/** LDtk world data **/
	public var world : World;
	public var hero: en.Hero;
	public var curLevelIdx = 0;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);
		scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		world = new World();
		camera = new Camera();
		fx = new Fx();
		hud = new ui.Hud();


		fadeMask = new h2d.Bitmap( h2d.Tile.fromColor(Const.DARK_COLOR) );
		root.add(fadeMask, Const.DP_MASK);

		startLevel(0);

		Process.resizeAll();
	}


	public function startLevel(idx=-1, ?data:World_Level) {
		delayer.addS(()->{
			Assets.SLIB.start(0.5);
		}, 0.1);
		curLevelIdx = idx;
		cd.unset("levelComplete");
		cd.unset("OVER");
		fadeIn();

		// Cleanup
		if( level!=null )
			level.destroy();
		for(e in Entity.ALL)
			e.destroy();
		fx.clear();
		gc();
		hud.invalidate();
		tw.terminateWithoutCallbacks(camera.zoom);

		// End game
		if( data==null && idx>=world.levels.length ) {
			destroy();
			new Intro(true);
			return;
		}		

		// Init level
		level = new Level( data!=null ? data : world.levels[curLevelIdx] );
		level.attachMainEntities();
		var levelTitle = "LEVEL "+(curLevelIdx+1); 
		notify(levelTitle, 0xF0BD07);
		camera.shakeS(0.3, 0.7);
		tw.createMs(camera.zoom, 0.9>1, 1500, TEase);
	}

	function fadeIn() {
		tw.terminateWithoutCallbacks(fadeMask.alpha);
		fadeMask.visible = true;
		tw.createMs( fadeMask.alpha, 1>0, 500, TEaseIn ).end( ()->fadeMask.visible = false );
	}

	function fadeOut() {
		tw.terminateWithoutCallbacks(fadeMask.alpha);
		fadeMask.visible = true;
		tw.createMs( fadeMask.alpha, 0>1, 500, TEaseIn );
	}

	public function levelComplete() {
		for(e in en.Mob.ALL) {
			e.destroy();
		}
		if( curLevelIdx+1 == world.levels.length ) 
			notify("YOU WIN!");
		else
			notify("LEVEL CLEARED");
		Assets.SLIB.complete(0.5);
		fx.flashBangS(0xffcc00, 0.4, 1);
		delayer.addS(()->{
			fadeOut();
		}, 2);		
		delayer.addS(()->{
			cd.setS("levelComplete", Const.INFINITE);
		}, 3);
	}		


	function gameover() {
		cd.unset("gameover");
		cd.setS("OVER", Const.INFINITE);

		// That's not a typo, it's a lazy solution for the font outline uglynes -.-'
		new ui.BigText("GAME OVER");
		new ui.BigText("GAME OVER");
		new ui.BigText("GAME OVER");
		#if hl
		new ui.SmallText("ESC to exit -- R to restart", 0xffcc00);
		#end
		#if js
		new ui.SmallText("R to restart", 0xffcc00);
		#end		
	}

	public function notify(str:String, ?slide = true, col=0xFFFFFF) {
		var f = new h2d.Flow();
		root.add(f, Const.DP_UI);
		var tf = new h2d.Text(Assets.fontPixel, f);
		tf.scale(Const.SCALE*2);
		tf.text = str;
		tf.textColor = col;
		f.x = Std.int( w()*0.5 - f.outerWidth*0.5 );
		f.y = Std.int( h()*0.4 - f.outerHeight*0.5 );

		if ( slide ) {
			tw.createMs(f.alpha, 0>1, 400);
			tw.createMs(tf.x, w()*0.5 > 0, TEaseOut, 200).end( ()->{
				tw.createMs(tf.x, 1000 | -w()*0.5, TEaseIn, 200).end( ()->{
					f.remove();
				});
			});
		}
		else {
			cd.setS("waitforrestart",Const.INFINITE);
			tw.createMs(tf.alpha, 0 > 1, TEaseOut, 400).end( ()->{
				tw.createMs(tf.alpha, 1 > 0, TEaseIn, Const.DEATH_DELAY*0.1).end( ()->{
					f.remove();
					cd.unset("waitforrestart");
				});
			});
		}
	}


	public function popText(x:Float, y:Float, str:String, col=0xffcc00) {
		var f = new h2d.Flow();
		scroller.add(f, Const.DP_UI);
		var tf = new h2d.Text(Assets.fontPixel, f);
		tf.text = str;
		tf.textColor = col;
		f.x = Std.int( x - f.outerWidth*0.5 );
		f.y = Std.int( y - f.outerHeight*0.5 );

		tw.createMs(f.alpha, 1>0, 1200).end( f.remove );
		tw.createMs(f.y, f.y-20, TEaseOut, 200);
	}

	/**
		Called when the CastleDB changes on the disk, if hot-reloading is enabled in Boot.hx
	**/
	public function onCdbReload() {
	}

	/**
		Called when LDtk world changes on the disk, if hot-reloading is enabled in Boot.hx
	**/
	public function onLDtkReload() {
		world.parseJson( hxd.Res.world.world_ldtk.entry.getText() );
		startLevel(curLevelIdx);
	}	

	override function onResize() {
		super.onResize();
		scroller.setScale(Const.SCALE);

		fadeMask.scaleX = w()/fadeMask.tile.width;
		fadeMask.scaleY = h()/fadeMask.tile.height;
	}


	function gc() {
		if( Entity.GC==null || Entity.GC.length==0 )
			return;

		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	override function onDispose() {
		super.onDispose();

		fx.destroy();
		for(e in Entity.ALL)
			e.destroy();
		gc();
	}


	/**
		Start a cumulative slow-motion effect that will affect `tmod` value in this Process
		and its children.

		@param sec Realtime second duration of this slowmo
		@param speedFactor Cumulative multiplier to the Process `tmod`
	**/
	public function addSlowMo(id:String, sec:Float, speedFactor=0.3) {
		if( slowMos.exists(id) ) {
			var s = slowMos.get(id);
			s.f = speedFactor;
			s.t = M.fmax(s.t, sec);
		}
		else
			slowMos.set(id, { id:id, t:sec, f:speedFactor });
	}


	function updateSlowMos() {
		// Timeout active slow-mos
		for(s in slowMos) {
			s.t -= utmod * 1/Const.FPS;
			if( s.t<=0 )
				slowMos.remove(s.id);
		}

		// Update game speed
		var targetGameSpeed = 1.0;
		for(s in slowMos)
			targetGameSpeed*=s.f;
		curGameSpeed += (targetGameSpeed-curGameSpeed) * (targetGameSpeed>curGameSpeed ? 0.2 : 0.6);

		if( M.fabs(curGameSpeed-targetGameSpeed)<=0.001 )
			curGameSpeed = targetGameSpeed;
	}


	/**
		Pause briefly the game for 1 frame: very useful for impactful moments,
		like when hitting an opponent in Street Fighter ;)
	**/
	public inline function stopFrame(t=0.2) {
		ucd.setS("stopFrame", t);
	}

	override function preUpdate() {
		super.preUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.preUpdate();
	}

	override function postUpdate() {
		super.postUpdate();


		for(e in Entity.ALL) if( !e.destroyed ) e.postUpdate();
		for(e in Entity.ALL) if( !e.destroyed ) e.finalUpdate();
		gc();

		// Update slow-motions
		updateSlowMos();
		baseTimeMul = ( 0.2 + 0.8*curGameSpeed ) * ( ucd.has("stopFrame") ? 0.3 : 1 );
		Assets.tiles.tmod = tmod;
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.fixedUpdate();
	}

	override function update() {
		super.update();
	
		for(e in Entity.ALL) if( !e.destroyed ) e.update();

		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			#if hl
			// Exit
			if( ca.isKeyboardPressed(Key.ESCAPE) ) {
				if( !cd.hasSetS("exitWarn",3) ) {
					if ( !cd.has("OVER") ) {
						var popup = new ui.Text("Press ESC again to exit");
						Assets.SLIB.popup(0.5);
						delayer.addS(()->{
							popup.dispose();
						}, 3);			
					}
				}		
				else
					hxd.System.exit();
			}
			#end

			#if js
			// Sorry, cannot exit
			if( ca.isKeyboardPressed(Key.ESCAPE) ) {
				var popup = new ui.Text("Close your browser to exit :)");
				Assets.SLIB.popup(0.5);
				delayer.addS(()->{
					popup.dispose();
				}, 3);			
			}
			#end			


			#if debug
			if( ca.isKeyboardPressed(K.N) ) {
				cd.setS("levelComplete", Const.INFINITE);
			}

			if( ca.isKeyboardPressed(K.K) ) {
				for(e in en.Fruit.ALL)
					e.destroy();
				for(e in en.Box.ALL)
					e.destroy();				
				levelComplete();
			}
			#end

			// Restart
			// SHIFT+R or CTRL+R restart from level 0
			// R restart current level
			if( !cd.has("notsafetorestart") && !cd.has("waitforrestart") && ca.selectPressed() ) {
				#if debug
				if( ca.isKeyboardDown(K.SHIFT) || ca.isKeyboardDown(K.CTRL) ) {
					startLevel(0);
				}
				else
				#end
				startLevel(curLevelIdx);
			}
		}

		if( cd.has("levelComplete") )
			if (cd.has("notsafetorestart") )
				delayer.addS(()->{
					startLevel(curLevelIdx+1);
				}, 3);	
			else
				startLevel(curLevelIdx+1);


		if( cd.has("gameover") )
			gameover();
	}
}

