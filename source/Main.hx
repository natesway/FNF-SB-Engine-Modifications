package;

#if android
import android.backend.AndroidDialogsExtend;
#end
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;

// crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

import states.MainMenuState;
import states.TitleState;

using StringTools;

class Main extends Sprite {
	var game = {
		width: 1280,
		height: 720,
		initialState: TitleState,
		zoom: -1.0,
		framerate: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public static var fpsVar:FPS;
	public static var changeID:Int = 0;

	public static function main():Void {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage != null) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE)) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void {
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0) {
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
		SUtil.doTheCheck();

		#if android
		addChild(new FlxGame(1280, 720, TitleState, 60, 60, true, false));
		#else
		addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		#end

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		fpsVar.visible = ClientPrefs.showFPS;

		FlxG.autoPause = false;

		#if html5
		FlxG.mouse.visible = false;
		#end

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if desktop
		DiscordClient.start();
		#end
	}

	public function changeFPSColor(color:FlxColor) {
		fpsVar.textColor = color;
	}

	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void {
		var errorMessage:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = SUtil.getPath() + "crash/" + "SB Engine_" + dateNow + ".log";

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errorMessage += file + " (Line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errorMessage += "\nUncaught Error: "
			+ e.error
			+ "\nPlease report this error to the GitHub page: https://github.com/Stefan2008Git/FNF-SB-Engine\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists(SUtil.getPath() + "crash/"))
			FileSystem.createDirectory(SUtil.getPath() + "crash/");

		File.saveContent(path, errorMessage + "\n");

		Sys.println(errorMessage);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errorMessage, "Error! SB Engine v" + MainMenuState.sbEngineVersion);
		#if android
		var toastText:String = '';
		toastText = 'Uncaught Error happends!';
		AndroidDialogsExtend.OpenToast(toastText, 2);
		#end
	
		#if desktop
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}
