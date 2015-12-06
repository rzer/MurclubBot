package commands {
	import controllers.Login;
	import controllers.Remote;
	import controllers.You;
	import flash.events.EventDispatcher;
	
	/**
	 * Долговыполняющаяся команда
	 * @author rzer & reraider
	 */
	public class Command extends EventDispatcher {
		
		private static var cmds:Array = [];
		
		private var target:String;
		private var userId:String;
		
		public function Command() {
			
			//Запоминаем кто вызвал
			this.target = Remote.target;
			this.userId = Remote.userId;
			
			//Кладём команду в массив, чтобы не потерялась
			cmds.push(this);
		}
		
		//Отвечаем куда надо
		public function reply(message:String):void {
			
			if (target == Login.userId) {
				You.privateMessage(userId, message);
			}else {
				You.say(message);
			}
			
			
		}
		
		//Удаляем команду из массива выполяняющихся
		public function complete():void {
			
			var anIndex:int = cmds.indexOf(this);
			
			if (anIndex != -1) {
				cmds.splice(anIndex, 1);
			}
		}
		
	}

}