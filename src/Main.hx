// import ui.Window;
import Data;
import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;

	/** Used to create "Access" instances that allow controller checks (keyboard or gamepad) **/
	public var controller : dn.heaps.Controller;

	/** Controller Access created for Main & Boot **/
	public var ca : dn.heaps.Controller.ControllerAccess;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

        createRoot(s);

		// Engine settings
		hxd.Timer.wantedFPS = Const.FPS;
		engine.backgroundColor = 0xff<<24|0x211f30;
        #if( hl && !debug )
        engine.fullScreen = true;
        #end

		// Heaps resources
		#if(hl && debug)
		hxd.Res.initLocal();
        #else
        hxd.Res.initEmbed();
        #end

        // CastleDB hot reloading
		#if debug
        hxd.res.Resource.LIVE_UPDATE = true;
        hxd.Res.data.watch(function() {
            delayer.cancelById("cdb");

            delayer.addS("cdb", function() {
            	Data.load( hxd.Res.data.entry.getBytes().toString() );
            	if( Game.ME!=null )
                    Game.ME.onCdbReload();
            }, 0.2);
        });

        // Hot reloading (LDtk)
        hxd.Res.world.world.watch(function() {
            delayer.cancelById("ldtk");

            delayer.addS("ldtk", function() {
            	if( Game.ME!=null )
                    Game.ME.onLDtkReload();
            }, 0.2);
        });
		#end

		// Assets & data init
		hxd.snd.Manager.get(); // force sound manager init on startup instead of first sound play
		Assets.init();
		new ui.Console(Assets.fontTiny, s);
		Lang.init("en");
		Data.load( hxd.Res.data.entry.getText() );

		// Game controller & default key bindings
		controller = new dn.heaps.Controller(s);
		ca = controller.createAccess("main");
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(X, Key.SPACE, Key.F, Key.E);
		controller.bind(A, Key.UP, Key.Z, Key.W);  // jump
		controller.bind(B, Key.ENTER, Key.NUMPAD_ENTER);
		controller.bind(SELECT, Key.R); // Restart
		controller.bind(START, Key.N);

		#if js
		// Optional helper that shows a "Click to start/continue" message when the game looses focus
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.fontMedium);
		#end		

		// Start with 1 frame delay, to avoid 1st frame freezing from the game perspective
		hxd.Timer.wantedFPS = Const.FPS;
		hxd.Timer.skip();
		#if debug
		// delayer.addF( startGame, 1 );
		delayer.addF( startIntro, 1 );
		#else
		delayer.addF( startIntro, 1 );
		#end

	}

	public function startIntro() {
		new Intro(false);
	}

	/** Start game process **/
	public function startGame() {
		if( Game.ME!=null ) {
			Game.ME.destroy();
			delayer.addF(function() {
				new Game();
			}, 1);
		}
		else
			new Game();
	}

	override public function onResize() {
		super.onResize();

		// Auto scaling
		if( Const.AUTO_SCALE_TARGET_WID>0 )
			Const.SCALE = M.ceil( w()/Const.AUTO_SCALE_TARGET_WID );
		else if( Const.AUTO_SCALE_TARGET_HEI>0 )
			Const.SCALE = M.ceil( h()/Const.AUTO_SCALE_TARGET_HEI );

		Const.UI_SCALE = Const.SCALE;
	}

    override function update() {
		Assets.tiles.tmod = tmod;
        super.update();
    }
}