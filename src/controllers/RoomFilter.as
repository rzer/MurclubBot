package controllers {
	import common.StringUtils;
	import elements.Console;
	import elements.Server;
	import flash.net.SharedObject;
	import simplify.ObjectEvent;
	
	/**
	 * Защитник от спама и не уважительного общения в комнатах
	 * @author rzer & reraider
	 */
	public class RoomFilter {
		
		public static const ROOM_ADS:String = "ads";
		public static const YOUNG:String = "young";
		public static const GUEST:String = "guest";
		public static const RATING:String = "rating";
		public static const IP:String = "ip";
		public static const SHOOT:String = "shoot";
		public static const BAD_WORDS:String = "badwords";
		
		private static var ipSO:SharedObject = SharedObject.getLocal("__ip_filter_ban");
		
		public static var blockedIP:Array = [];
		
		public static var filters:Object = { };
		
		public static function init():void {
			
			//Запониманаем заблокированные IP
			if (ipSO.data.blockedIP) {
				blockedIP = ipSO.data.blockedIP;
			}
			
			Console.registerCommand("/addFilter", addFilter);
			Console.registerCommand("/removeFilter", removeFilter);
			Console.registerCommand("/filtersOn", filtersOn);
			Console.registerCommand("/filtersOff", filtersOff);
			Console.registerCommand("/banIP", banIP);
			
			Console.info("Room filters:");
			Console.tip(
				"/addFilter, /removeFilter [ads, young 18, guest, rating, ip, shoot, badwords] - добавляет фильтр на входе, " +
				"/filtersOn, /filtersOff - фильтры по умолчанию, /banIP ip - забанить IP"
			);

			
			Server.bind("JOIN", onJoin);
			Server.bind("PRIVMSG", onMessage);
			Server.bind("USBG", onShoot);
			Server.bind("CHBG", onShoot);
			Server.bind("GUEST", onGuest);
			Server.bind("777", onRating); 
		}
		
		static public function banIP(ip:String):void {
			if (blockedIP.indexOf(ip) == -1) {
				blockedIP.push(ip);
				
				ipSO.data.blockedIP = blockedIP;
				ipSO.flush();
				
			}

		}
		
		static public function removeFilter(type:String):void {
			delete filters[type];
		}
		
		static public function filtersOn():void {
			addFilter(ROOM_ADS);
			addFilter(RATING, 1000);
			addFilter(GUEST);
			addFilter(SHOOT);
			addFilter(IP);
		}
		
		static public function filtersOff():void {
			filters = { };
			You.say("Фильтры выключены");
		}
		
		static private function onJoin(e:ObjectEvent):void {
			
			if (filters[IP]) {
				
				var ip:String = StringUtils.extractIP(e.data[0]);
				
				if (blockedIP.indexOf(ip) != -1) {
					var userId:String = StringUtils.extractUserId(e.data[0]);
					Moderator.ban(userId, "Вы забанены по IP в этой комнате");
					return;
				}
				
			}
			
		}
		
		static public function onRating(e:ObjectEvent):void {
			
			if (filters[RATING]) {
				
				var rating:int = int(e.data[3]);
				var needRating:int = filters[RATING];
				
				if (rating < needRating) {
					var userId:String = StringUtils.getUserId(e.data[2]);
					Moderator.ban(userId, "В нашей комнате сидят люди выше " + needRating + " рейтинга, как достигните " + needRating + " рейтинга - приходите!");
					return;
				}
			}
			
		}
		
		static private function onGuest(e:ObjectEvent):void {
			
			if (filters[GUEST]) {
				var userId:String = StringUtils.getUserId(e.data[2]);
				Moderator.ban(userId, "Зарегестрируйтесь! Мы вас ждём.");
				return;
			}
		}
		
		static public function onShoot(e:ObjectEvent):void {
			
			if (filters[SHOOT]) {
			
				if (e.data[2] == "ADD") {
					
					var killerId:String = StringUtils.getUserId(e.data[4]);
					var victimId:String = StringUtils.getUserId(e.data[3]);
					
					Moderator.ban(killerId, "Стрельба запрещена, вы забанены");
					You.heal(victimId);
					return;
					
				}
				
			}
			
		}
		
		
		
		private static function onMessage(e:ObjectEvent):void {
			
			//:m5785874!M@176.99.71.9 PRIVMSG #ПоЗнАкОмИмСя??? 77539884 :кукули2
			
			if (filters[ROOM_ADS]) {
				
				var phrase:String = StringUtils.getPhrase(e.data);
				
				if (phrase.indexOf("#") != -1) {
					var userId:String = StringUtils.extractUserId(e.data[0]);
					Moderator.ban(userId, "Реклама других комнат запрещена");
					return;
				}
				
			
				
			}
			
		}
		
		public static function addFilter(type:String, value:uint = 1):void {
			
			filters[type] = value;
			
			if (type == ROOM_ADS) You.say("Реклама в комнате запрещена");
			else if (type == YOUNG) You.say("В комнате действует возрастное ограничение. Минимальный возраст: " + value );
			else if (type == GUEST) You.say("Доступ гостям в комнату закрыт");
			else if (type == RATING) You.say("Минимальный рейтинг для доступа в комнату: " + value);
			else if (type == IP) You.say("Включен фильтр IP адресов");
			else if (type == SHOOT) You.say("Стрельба в комнате запрещена");
			else if (type == BAD_WORDS) You.say("Матные слова запрещены");
		}
		
		
		
		
	}

}