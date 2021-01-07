package ui;

class BigText extends Entity {
	public static var ALL : Array<BigText> = [];
	var wrapper : h2d.Object;
	var tf : h2d.Text;

	public function new(str:String, ?c = 0xFFFFFF) {
		super(cx, cy);
		ALL.push(this);

		wrapper = new h2d.Object();
		game.scroller.add(wrapper, Const.DP_UI);
		tf = new h2d.Text(Assets.fontPixel, wrapper);
		tf.scale(Const.SCALE*2);
		tf.text = str;
		tf.textColor = c;
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);		
		wrapper.remove();
	}

	override function postUpdate() {
		spr.set("pixel");
		spr.visible = false;
		spr.alpha = 0;
		wrapper.x = (level.level.pxWid/2)-tf.textWidth*2;
		wrapper.y = ((level.level.pxHei/2)-tf.textHeight*2)-Const.GRID*2;			
		super.postUpdate();
	}

	override function update() {
		super.update();
	}
}