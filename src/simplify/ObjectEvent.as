package simplify {
	
	import flash.events.Event;
	
	/**
	 * Событие c полем data
	 * @author rzer & reraider
	 * @version 1.0
	 * @see http://atflash.ru/simplify
	 *  
	 */
	public class ObjectEvent extends Event {
		
		public var data:Array;
		
		public function ObjectEvent(type:String, data:Array = null, bubbles:Boolean = false, cancelable:Boolean = false) { 
			
			super(type, bubbles, cancelable);
			this.data = data;
			
		} 
		
		public override function clone():Event { 
			return new ObjectEvent(type,data, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ObjectEvent", "type","data", "bubbles", "cancelable", "eventPhase"); 
		}
		
		
	}
	
}