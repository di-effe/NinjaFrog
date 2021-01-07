import ui.Window;
import hxd.Key;

class Intro extends dn.Process {
	var logo : HSprite;
	var lines = 0;
	var cm = new dn.Cinematic(Const.FPS);
	var wrapperTop : h2d.Flow;
	var wrapperBottom : h2d.Flow;
	var title : h2d.Flow;
	var texts : h2d.Flow;

	/** Game controller (pad or keyboard) **/
	public var ca : dn.heaps.Controller.ControllerAccess;

	public function new(isEnding:Bool) {
		super(Main.ME);
		createRoot(Main.ME.root);
        ca = Main.ME.controller.createAccess("game");
        
		wrapperTop = new h2d.Flow(root);
		wrapperBottom = new h2d.Flow(root);
		title = new h2d.Flow(wrapperTop);
        texts = new h2d.Flow(wrapperBottom);
		texts.layout = Vertical;


		if( !isEnding ) {
			cm.create({
				tw.createMs(root.alpha, 0>1, 500);
				5000;
				tw.createMs(root.alpha, 0, 1000);
				1000;
				destroy();
				Main.ME.startGame();
			});
			text("This is just a simple puzzle game demo ");
			text("created to learn how to work with HEAPS.io");
			text("and LDtk level editor by Deepnight.");
			text("  ");
			text("--------------[ C R E D I T S ]--------------" ,0xffcc00);
			text("  ");
			text("Pixel Adventure assets by Pixel Frog");
			text("Bitmap Fonts by Herald");
			text("gameBase code by Deepnight");

		}
		else {
			tw.createMs(root.alpha, 0>1, 1500);
			text("Thank you for playing :)", 0xffcc00);
			text("  ");
			text("- David");
			cm.create({
				tw.createMs(root.alpha, 0>1, 500);
				5000;
				tw.createMs(root.alpha, 0, 1000);
				1000;
				destroy();
				hxd.System.exit();
			});			
		}

		dn.Process.resizeAll();
	}

	function text(str:String, c=0xffffff) {
		var tf = new h2d.Text(Assets.fontPixel, texts);
		tf.text = str;
		tf.textColor = c;
		lines++;
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
		
		// Centering logo
		var maxWidth = Std.int(hxd.Window.getInstance().width / Const.SCALE);
		var maxHeight = Std.int(hxd.Window.getInstance().height / Const.SCALE);
		wrapperTop.maxWidth = maxWidth;
		wrapperTop.fillWidth = true;
		// wrapperBottom.horizontalAlign = Middle;
		title.fillWidth = true;
		title.horizontalAlign = Middle;
		title.paddingTop = Std.int(maxHeight/20);
		var logo = Assets.tiles.h_get("logo", title);
		
		// Centering text
		wrapperBottom.maxWidth = maxWidth;
		wrapperBottom.fillWidth = true;
		wrapperBottom.horizontalAlign = Left;
		texts.fillWidth = true;
		texts.horizontalAlign = Middle;
		texts.paddingTop = Std.int(Assets.tiles.h_get("logo").tile.height + Std.int(maxHeight/20)+20);
	}

	override function update() {
		super.update();
		for(e in Entity.ALL) if( !e.destroyed ) e.update();
	}

	override function preUpdate() {
		super.preUpdate();
		cm.update(tmod);
	}
}