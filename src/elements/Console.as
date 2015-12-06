package elements {
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	/**
	 * Консоль
	 * @author rzer & reraider
	 */
	public class Console {
		
		static public var isPaused:Boolean  = false;
		
		static public const INFO:uint = 0xD0EB14;
		static public const COMMAND:uint = 0x00FFFF;
		static public const ERROR:uint = 0xFF8080;
		static public const SUCCESS:uint = 0x80FF00;
		
		private static var parent:Sprite;
		private static var container:Sprite;
		private static var overlay:Sprite;
		private static var stage:Stage;
		
		public static var commands:Object = { };
		static public var output:Function = null;
		
		private static var msgs:Array = [];
		private static var msgBounds:Rectangle;
		
		private static var offset:int = 10;
		
		private static var input:TextField;
		
		private static var line:Sprite = new Sprite();
		
		
		public static function init(parent:Sprite):void {
			
			Console.parent = parent;
			stage = parent.stage;
			
			parent.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			
			container = new Sprite();
			overlay = new Sprite();
			parent.addChild(container);
			parent.addChild(overlay);
			
			line = new Sprite();
			container.addChild(line);
			
			var canvas:Graphics = overlay.graphics;
			canvas.beginFill(0x20411D);
			canvas.drawRect(5, 565, 790, 30);
			canvas.endFill();
			
			canvas = line.graphics;
			canvas.lineStyle(1, 0x00ff00);
			canvas.lineTo(800, 0);
			
			input = new TextField();
			input.defaultTextFormat = new TextFormat("PixelFont", 8, 0x00ff00);
			input.antiAliasType = AntiAliasType.ADVANCED;
			input.embedFonts = true;
			
			input.type = TextFieldType.INPUT;
			input.x = 10;
			input.y = 570;
			input.width = 780;
			input.height = 20;
			
			parent.addChild(input);
			
			stage.focus = input;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			
		}
		
		static private function onUncaughtError(e:UncaughtErrorEvent):void {
			if (e.error) Console.error(e.error.getStackTrace());
			
			e.preventDefault();
		}
		
		static private function onKeyDown(e:KeyboardEvent):void {
			if (e.keyCode == 13) {
				if (input.text.length > 0) exec(input.text);
				input.text = "";
				stage.focus = input;
			}
			
		}
		
		static public function exec(message:String):void {
			
			//Удаляем enter
			message = message.split("\n").join("");
			
			var list:Array = message.split(" ");
			
			var command:String = list.shift();
			var func:Function = commands[command];
			
			if (func != null) {
				
				success(message);
				
				if (list.length > 0) {
					
					if (list.length > func.length) {
						var temp:Array = list.splice(func.length-1, list.length - func.length+1);
						list.push(temp.join(" "));
					}
					
				}
				
				try {
					func.apply(null, list);
				}catch (err:Error){
					//do nothing
					Console.error("ARGS ERROR");
				}
				
				
			}else {
				error("Команда " + command + " не найдена!");
			}
		}
		
		public static function info(text:String):void {
			write(text, INFO);
		}
		
		public static function error(text:String):void {
			trace(text);
			write(text, ERROR);
		}
		
		public static function success(text:String):void {
			write(text, SUCCESS);
		}
		
		public static function tip(text:String):void {
			write(text, COMMAND);
		}
		
		public static function write(text:String, color:uint = 0xffffff):void {
			
			if (isPaused) return;
			
			if (output != null) {
				output(text);
			}
			
			var msg:TextField = new TextField();
			container.addChild(msg);
			
			msg.defaultTextFormat = new TextFormat("PixelFont", 8, color);
			msg.antiAliasType = AntiAliasType.ADVANCED;
			msg.sharpness = 1000;
			msg.embedFonts = true;
			
			msg.multiline = true;
			msg.wordWrap = true;
			
			msg.x = 10;
			msg.y = offset;
			msg.autoSize = TextFieldAutoSize.LEFT;
			
			msg.width = 780;
			msg.text = text;
			
			offset += msg.height + 1;
			
			line.y = offset;
			
			if (offset > 540) offset = 10;
			
			
			msgBounds = msg.getBounds(parent);
			msgs = msgs.filter(removeIntersect);
			
			msgs.push(msg);
		}
		
		public static function registerCommand(command:String, func:Function):void {
			commands[command] = func;
		}
		
		
		
		private static function removeIntersect(item:Object, idx:uint, arr:Array):Boolean {
			
			var test:TextField = item as TextField;
			var result:Boolean = test.getBounds(parent).intersects(msgBounds);
			
			if (result) {
				container.removeChild(test);
			}
			
			return !result;
		}

		
		
	}

}