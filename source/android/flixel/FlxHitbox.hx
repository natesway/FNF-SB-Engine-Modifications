package android.flixel;

import android.flixel.FlxButton;
import openfl.utils.Assets;

/**
 * A zone with 4 buttons (A hitbox).
 * It's easy to customize the layout.
 *
 * @author: Saw (M.A. Jigsaw)
 */
class FlxHitbox extends FlxSpriteGroup {
	public var buttonLeft:FlxButton = new FlxButton(0, 0);
	public var buttonDown:FlxButton = new FlxButton(0, 0);
	public var buttonUp:FlxButton = new FlxButton(0, 0);
	public var buttonRight:FlxButton = new FlxButton(0, 0);

	/**
	 * Create the zone.
	 */
	public function new() {
		super();

		scrollFactor.set();

		add(buttonLeft = createHint(0, 0, 'left', ClientPrefs.arrowHSV[0][0]));
		add(buttonDown = createHint(FlxG.width / 4, 0, 'down', ClientPrefs.arrowHSV[0][1]));
		add(buttonUp = createHint(FlxG.width / 2, 0, 'up', ClientPrefs.arrowHSV[0][2]));
		add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, 'right', ClientPrefs.arrowHSV[0][3]));
	}

	/**
	 * Clean up memory.
	 */
	override function destroy() {
		super.destroy();

		buttonLeft = null;
		buttonDown = null;
		buttonUp = null;
		buttonRight = null;
	}

	private function createHint(X:Float, Y:Float, Graphic:String, Color:Int = 0xFFFFFF):FlxButton {
		var hintTween:FlxTween = null;
		var hint:FlxButton = new FlxButton(X, Y);
		hint.loadGraphic(FlxGraphic.fromFrame(FlxAtlasFrames.fromSparrow(Assets.getBitmapData('assets/android/hitbox.png'),
			Assets.getText('assets/android/hitbox.xml'))
			.getByName(Graphic)));
		hint.setGraphicSize(Std.int(FlxG.width / 4), FlxG.height);
		hint.updateHitbox();
		hint.solid = false;
		hint.immovable = true;
		hint.scrollFactor.set();
		hint.color = Color;
		hint.alpha = 0.00001;
		hint.onDown.callback = hint.onOver.callback = function() {
			if (hint.alpha != ClientPrefs.hitboxAlpha)
				hint.alpha = ClientPrefs.hitboxAlpha;
		}
		hint.onUp.callback = hint.onOut.callback = function() {
			if (hint.alpha != 0.00001)
				hint.alpha = 0.00001;
		}
		hint.onOver.callback = hint.onDown.callback;
		hint.onOut.callback = hint.onUp.callback;
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}
}
