package simplify {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * Задержанные вызовы
	 * 
	 * Call.nextFrame(redraw, arg1, arg2);
	 * private function redraw(arg1, arg2):void{
	 *    //Этот метод будет вызван в следующем кадре и только один раз
	 * }
	 * 
	 * Call.after(1000, onNextSecond); //Метод onNextSecond будет вызван через одну секунду
	 * Call.forget(onNextSecond); //А теперь не будет вызван
	 * 
	 * @author rzer & reraider
	 * @version 1.0
	 */
	
	public class Call extends Sprite{
		
		private static var dispatcher:Call = new Call();
		private static var calls:Dictionary = new Dictionary();
		private static var afterCalls:Array = [];
		
		private static var currentTime:uint = 0;
		private static var forgetHandler:Function;
		
		
		public function Call():void {
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private static function onEnterFrame(e:Event):void {
			
			var makeCalls:Dictionary = calls;
			calls = new Dictionary();
			
			for (var func:* in makeCalls) {
				var handler:Function = func as Function;
				handler.apply(null, makeCalls[func]);
			}
			
			currentTime = getTimer();
			
			
			var makeAfterCalls:Array = afterCalls.concat();
			
			for (var i:int = 0; i < makeAfterCalls.length; i++) {
				
				var call:AfterCaller = makeAfterCalls[i];
				
				if (call.time <= currentTime) {
					call.handler.apply(null, call.args);
				}
				
			}
			
			afterCalls = afterCalls.filter(afterCheck);
			
		}
		
		public static function nextFrame(handler:Function, ...args:Array):void {
			calls[handler] = args;
		}
		
		public static function after(time:uint, handler:Function, ...args):void {
			afterCalls.push(new AfterCaller(getTimer()+time, handler, args))
		}
		
		private static function afterCheck(call:AfterCaller, index:int, afterCalls:Array):Boolean {
			
			if (call.time <= currentTime) {
				return false;
			}
			
			return true;
			
		}
		
		
		public static function forget(handler:Function):void {
			delete calls[handler];
			
			forgetHandler = handler;
			
			afterCalls = afterCalls.filter(afterForget);
			forgetHandler = null;
		}
		
		private static function afterForget(call:AfterCaller, index:int, afterCalls:Array):Boolean {
			return !(call.handler == forgetHandler);
		}
	}
	
}

internal class AfterCaller extends Object {
	
	public var time:uint;
	public var handler:Function;
	public var args:Array;
	
	public function AfterCaller(time:uint, handler:Function, args:Array):void {
		
		this.args = args;
		this.handler = handler;
		this.time = time;
		
	}
	
}