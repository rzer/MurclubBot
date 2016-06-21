package controllers {
	import common.StringUtils;
	import simplify.Console;
	import elements.Server;
	import flash.display.TriangleCulling;
	import simplify.ObjectEvent;
	
	/**
	 * Удалённое выполнение команд
	 * @author rzer & reraider
	 */
	public class Remote {
		
		
		public static var userId:String = "";
		public static var target:String = "";
		
		
		public static var allowedUsers:Array = [
			"m1830204", //SaintG
			"m5129563", //Fieign
		];
		
		public static var consoleUsers:Array = [
			
		];
		
		
		public static function init():void {
						
			Console.register("/grant", grant);
			Console.register("/demote", demote);
			Console.register("/console", console);
			Console.register("/?", commandList);
			
			Console.info("Remote:");
			Console.tip("/? - список команд, /console - подключить консоль, /grant, demote mID - разрешить временное выполнение команд на сервере");

			
			Server.bind("PRIVMSG", onMessage);
		}
		
		static public function demote(userId:String):void {
			
			var demoteIndex:int = allowedUsers.indexOf(userId);
			
			if (demoteIndex == -1) {
				You.say("Пользователь не управляет ботом");
				return;
			}
			
			if (Remote.userId != "") {
				
				var adminIndex:int =  allowedUsers.indexOf(Remote.userId);
				
				if (adminIndex > demoteIndex) {
					You.say("Нельзя демоутить тех, кто старше");
					return;
				}
			}
			
			allowedUsers.splice(demoteIndex, 1);
			You.say("Пользователь больше не может управлять ботом!");

		}
		
		static public function console():void {
			
			var anIndex:int = consoleUsers.indexOf(userId);
			
			if (anIndex != -1){
				consoleUsers.splice(anIndex, 1);
			}else{
				consoleUsers.push(userId);
			}
			
			Console.output = output;
		}
		
		static private function output(text:String):void {
			
			Console.isPaused = true;
			
			for (var i:int = 0; i < consoleUsers.length; i++) {
				var userId:String = consoleUsers[i];
				You.privateMessage(userId, text);
			}
			
			Console.isPaused = false;
		}
		
		
		
		static public function commandList():void {
			
			var list:Array = [];
			
			for (var commandName:String in Console.commands) {
				list.push(commandName);
			}
			
			You.say("Доступные команды: " + list.join(", "));
		}
		
		static public function grant(userId:String):void {
			
			if (allowedUsers.indexOf(Remote.userId) >= 2) return;
			
			userId = StringUtils.getUserId(userId);
			
			if (allowedUsers.indexOf(userId) != -1) return;
			allowedUsers.push(userId);
			
			var nickname:String = Room.getNickname(userId);
			if (nickname != "") You.say(nickname + " теперь может выполнять команды!");
		}
		
		private static function onMessage(e:ObjectEvent):void {
			
			var phrase:String = StringUtils.getPhrase(e.data);
			var userId:String = StringUtils.extractUserId(e.data[0]);
			var target:String = e.data[2];
			
			
			if (phrase.charAt(0) == "/" || phrase.charAt(0) == "!") {
			
				if (phrase.charAt(0) == "/" && allowedUsers.indexOf(userId) == -1) {
					
					if (target == Login.userId) {
						You.privateMessage(userId, "Ты кто такой? Давай до свидания!");
					}else {
						You.say("Ты кто такой? Давай до свидания!");
					}
					
					return;
				}
				
				Remote.target = target;
				Remote.userId = userId;
				Console.exec(phrase);
				Remote.userId = "";
			}
			
		}
		
	}

}