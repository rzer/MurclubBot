package simplify {
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	/**
	 * Консоль отладки (F3)
	 * 
	 * //Инициализируем консоль в document class
	 * Console.init(this);
	 * 
	 * //Регистрируем команду в консоли
	 * Console.register("/send", sendMessage);
	 * 
	 * //Функция выполниться если ввести в консоли /send Hello world!
	 * function sendMessage(message:String):void{
	 *   //Аргументы бьются по пробелу, и в последний аргумент склеиваются все оставшиеся аргументы
	 * }
	 * 
	 */

	public class Console {
		
		[Embed(source = "Console.ttf", fontName="ConsoleFont", embedAsCFF= "false")]
		public var PixelFont:Class;
		
		static public var isPaused:Boolean  = false;
		
		static public const INFO:uint = 0xD0EB14;
		static public const COMMAND:uint = 0x00FFFF;
		static public const ERROR:uint = 0xFF8080;
		static public const SUCCESS:uint = 0x80FF00;
		static public const DEBUG:uint = 0xCCCCCC;
		
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
		
		private static var history:Array = [];
		private static var historyIndex:int = -1;
		
		
		public static function init(topmost:Sprite):void {
			
			Console.stage = topmost.stage;
			
			
			parent = new Sprite();
			stage.addChild(parent);
			
			parent.visible = false;
			
			topmost.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			
			container = new Sprite();
			overlay = new Sprite();
			parent.addChild(overlay);
			parent.addChild(container);
			
			
			line = new Sprite();
			overlay.addChild(line);
			
			
			input = new TextField();
			input.defaultTextFormat = new TextFormat("ConsoleFont", 8, 0x00ff00);
			input.antiAliasType = AntiAliasType.ADVANCED;
			input.embedFonts = true;
			input.addEventListener(KeyboardEvent.KEY_DOWN, onTextChange);
			
			input.type = TextFieldType.INPUT;
			input.x = 10;
			
			input.height = 20;
			
			parent.addChild(input);
			
			stage.focus = input;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown,false,99);
			stage.addEventListener(Event.RESIZE, redraw);
			
			redraw();
			
			Console.info("Console v1.1");
			Console.info("Write /? to get list of commands");
			Console.register("/?", outputCommands);
			
		}
		
		static private function onTextChange(e:KeyboardEvent):void {
			
			if (e.keyCode == Keyboard.ENTER) return;
			historyIndex = -1;
		}
		
		static private function outputCommands():void {
			
			var result:Array = [];
			
			for (var command:String in commands) {
				result.push(command);
			}
			
			Console.write(result.join(", "));
		}
		
		private static function redraw(e:Event = null):void {
			
			var canvas:Graphics = overlay.graphics;
			
			canvas.clear();
			
			canvas.beginFill(0x000000, 0.8);
			canvas.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			canvas.endFill();
			
			canvas.beginFill(0x151515);
			canvas.drawRect(5, stage.stageHeight-35, stage.stageWidth-10, 30);
			canvas.endFill();
			
			canvas = line.graphics;
			
			canvas.clear();
			
			canvas.lineStyle(1, 0x00ff00);
			canvas.lineTo(stage.stageWidth, 0);
			
			input.y = stage.stageHeight - 30;
			input.width = stage.stageWidth-20;
		}
		
		static private function onUncaughtError(e:UncaughtErrorEvent):void {
			trace("UNCAUUUUUGHT", e.toString());
			
			if (e.error) Console.error(e.error.getStackTrace());
			e.preventDefault();
		}
		
		static private function onKeyDown(e:KeyboardEvent):void {
			
			if (e.keyCode == Keyboard.F3) {
				e.stopImmediatePropagation();
				toggle();
				return;
			}
			
			if (!parent.visible) return;
			
			if (e.keyCode == Keyboard.UP) {
				e.stopImmediatePropagation();
				showHistory(1);
				return;
			}
			
			if (e.keyCode == Keyboard.DOWN) {
				e.stopImmediatePropagation();
				showHistory( -1);
				return;
			}
			
			
			if (e.keyCode == Keyboard.ENTER) {
				if (input.text.length > 0) exec(input.text);
				input.text = "";
				stage.focus = input;
			}
			
		}
		
		private static function showHistory(value:Number):void {
			
			historyIndex += value;
			
			//В истории больше нет пунктов
			if (historyIndex < 0 || historyIndex >= history.length) {
				historyIndex -= value;
				return;
			}
			
			input.text = history[historyIndex];
		}
		
		static public function toggle():void {
			parent.visible = !parent.visible;
		}
		
		static public function exec(message:String):void {
			
			//Удаляем enter
			message = message.split("\n").join("");
			
			//Записываем в историю
			if (historyIndex == -1) {
				history.unshift(message);
			}
			
			historyIndex = -1;
			
			var list:Array = message.split(" ");
			
			var command:String = list.shift();
			var func:Function = commands[command];
			
			if (func != null) {
				
				tip(message);
				
				if (list.length > 0) {
					
					if (list.length > func.length) {
						var temp:Array = list.splice(func.length-1, list.length - func.length+1);
						list.push(temp.join(" "));
					}
					
				}
				
				try {
					func.apply(null, list);
				}catch (err:Error){
					Console.error(err.getStackTrace());
				}
				
				
			}else {
				error("Command " + command + " not found!");
			}
		}
		
		public static function info(text:String):void {
			write(text, INFO);
		}
		
		public static function error(text:String):void {
			trace(text);
			write(text, ERROR);
		}
		
		static public function debug(text:String):void {
			trace(text);
			
			CONFIG::debug {
				write(text, DEBUG);
			}
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
			
			msg.defaultTextFormat = new TextFormat("ConsoleFont", 8, color);
			msg.antiAliasType = AntiAliasType.ADVANCED;
			msg.sharpness = 1000;
			msg.embedFonts = true;
			
			msg.multiline = true;
			msg.wordWrap = true;
			
			msg.x = 10;
			msg.y = offset;
			msg.autoSize = TextFieldAutoSize.LEFT;
			
			msg.width = stage.stageWidth-20;
			msg.text = text;
			
			offset += msg.height + 1;
			
			line.y = offset;
			
			if (offset > stage.stageHeight-60) offset = 10;
			
			
			msgBounds = msg.getBounds(parent);
			msgs = msgs.filter(removeIntersect);
			
			msgs.push(msg);
		}
		
		public static function registerAll(obj:Object):void {
			for (var command:String in obj) {
				register(command, obj[command]);
			}
		}
		
		public static function register(command:String, func:Function):void {
			commands[command] = func;
		}
		
		
		public static function unregister(command:String):void {
			delete commands[command];
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