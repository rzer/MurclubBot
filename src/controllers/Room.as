package controllers {
	
	import air.update.events.DownloadErrorEvent;
	import common.StringUtils;
	import simplify.Console;
	import elements.Server;
	import simplify.Call;
	import simplify.ObjectEvent;
	
	
	/**
	 * Список людей в комнате - название комнаты
	 * @author rzer & reraider
	 */
	public class Room {
		
		public static var currentRoom:String = "#room";
		public static var users:Object = {};
		
		public static function init():void {
			
			Console.register("/detectAdmins", detectAdmins);
			Console.register("/userlist", getUserList);
			Console.register("/eusr", emulateUser);
			Console.register("/eprv", emulatePrivateMassage);
			Console.register("/epub", emulatePublicMassage);
			Console.register("/mid", getUserId);
			Console.register("/who", who);
			Console.register("/online", online);
			
			Console.info("Комната:");
			
			Console.tip(
				"/userlist - получить список пользователей в комнате, " +
				"/mid - получить ID пользователя по имени, " +
				"/who mId - инфо о человеке, " + 
				"/online - пользователи в онлайне"
			);

			
			Server.bind("JOIN", onJoin); //Мы зашли
			Server.bind("750", onAddUser); //Зашёл пользователь
			Server.bind("NICKALT", onChangeName); //Пользователь сменил ник
			Server.bind("PART", onLeaveRoom); //Пользователь вышел из комнаты
	
			Server.bind("266", onOnline); //Запросили онлайн
			
		}
		
		static public var lastDetect:String = "";
		static public var admins:Array = [];
		

		static public function adminCatched():void {
			admins.push(lastDetect);
		}
		
		static private function detectAdmins():void {
			
			You.say("Поиск админов...");
			admins = [];
			
			var timeOffset:int = 0;
			
			for (var userId:String in users) {
				
				timeOffset += 1000;
				Call.after(timeOffset, tryBan, [userId]);
				
			}
			
			timeOffset += 1000;
			Call.after(timeOffset, endDetection);
			
		}
		
		static private function endDetection():void {
			You.say("Админы в комнате: " + admins.join(", "));
		}
		
		static private function tryBan(userId:String):void {
			lastDetect = userId;
			Moderator.ban(userId);
		}
		
		static public function onOnline(e:ObjectEvent):void {
			You.say("Всего: " + e.data[6] + " человек онлайн. Максимальный онлайн: " + e.data[9]);
		}
		
		static public function online():void {
			Server.raw("LUSERS");
		}
		
		
		static public function onWhois(e:ObjectEvent):void {
			
			var ip:String = e.data[5];
			var room:String = e.data[3];
			
			You.say("IP: " + ip + " В комнате: " + room);
			Server.bind("352", onWhois);
		}
		
		static public function who(userId:String):void {
			userId = StringUtils.getUserId(userId);
			
			Server.bind("352", onWhois);
			Server.raw("WHO " + userId);
		}
		
		static private function getUserId(nickname:String):void {
			var userId:String = getUserIdByName(nickname);
			Console.info(userId);
		}
		
		static public function emulatePrivateMassage(id:String, message:String):void {
			
			Console.error(message);
			
			id = StringUtils.getUserId(id);
			var data:Array = [":" + id + "!M@1.1.1.1", "PRIVMSG", Login.userId, ":" + message];
			Server.o.dispatchEvent(new ObjectEvent("PRIVMSG", data));
		}
		
		static public function emulatePublicMassage(id:String, message:String):void {
			
			Console.success(message);
			
			id = StringUtils.getUserId(id);
			var data:Array = [":" + id + "!M@1.1.1.1", "PRIVMSG", currentRoom, ":" + message];
			Server.o.dispatchEvent(new ObjectEvent("PRIVMSG", data));
		}
		
		static public function emulateUser(id:String):void {
			id = StringUtils.getUserId(id);
			users[id] = id;
		}
		
		static private function onLeaveRoom(e:ObjectEvent):void {
			
			//:m1830204!M@5.18.176.24 PART #Disneyland :Part выход
			
			var userId:String = StringUtils.extractUserId(e.data[0]);
			var nickname:String = users[userId];
			Console.info(userId + ": " + nickname + " покинул комнату");
			
			delete users[userId];
		}
		
		static private function onChangeName(e:ObjectEvent):void {
			
			//":m1830204!M@5.18.176.24 NICKALT SaintG"
			
			var userId:String = StringUtils.extractUserId(e.data[0]);
			var nickname:String = e.data[2];
			users[userId] = nickname;
			
			Console.info(userId + " сменил имя на " + nickname);
		}
		
		private static function onAddUser(e:ObjectEvent):void {
			
			//:m2.ru 750 m1830204 M,3,4,0,0,0  SaintG 3 120 1822  17_ 3173  _ 1322 1_21 1096 22_23 
			
			var userId:String = e.data[2];
			var nickname:String = e.data[5];
			users[userId] = nickname;
			
			Console.info(userId + ": " + nickname);
			
		}
		
		public static function getUserList():Object {
			
			for (var userId:String in users) {
				Console.write(userId + ": " + users[userId], Console.INFO);
			}
			
			return users;
			
		}
		
		static public function getNickname(userId:String):String {
			userId = StringUtils.getUserId(userId);
			if (users[userId] != null) return users[userId];
			return "Эй";
		}
		
		static public function getUserIdByName(nickname:String):String {
			
			for (var userId:String in users) {
				if (users[userId] == nickname) return userId;
			}
			
			return "";
		}
		
		static public function emulateUsers(count:Number):void {
			for (var i:int = 1; i <= count; i++) {
				emulateUser(String(i));
			}
		}
		
		private static function onJoin(e:ObjectEvent):void {
			
			currentRoom  = e.data[2];
			currentRoom = currentRoom.substr(1);
			
			Console.write("Вы зашли в комнату: " + currentRoom);
		}
		
		
	}

}