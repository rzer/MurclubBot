package controllers {
	import common.StringUtils;
	import elements.Console;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import mx.utils.StringUtil;
	import simplify.MD5;
	import simplify.WebLoader;
	
	/**
	 * Пользовательские команды
	 * @author rzer & reraider
	 */
	public class UserCommands {
		
		public static const MAFIA:String = "Запустить Мафию";
		public static const QUIZ:String = "Запустить Викторину";
		public static const WORDS:String = "Запустить Слова";
		
		public static const STOP:String = "Остановить все текущие игры";
		
		public static var startVotes:int = 7;
		public static var voteInterval:uint = 5 * 60000;
		
		public static var votes:Object = { };
		
		public static function init():void {
			Console.registerCommand("!онлайн", online);
			Console.registerCommand("!кто", who);
			Console.registerCommand("!инфометр", infometer);
			Console.registerCommand("!мафия", wantMafia);
			Console.registerCommand("!слова", wantWords);
			Console.registerCommand("!викторина", wantQuiz);
			Console.registerCommand("!стоп", wantStop);
			Console.registerCommand("!бан", voteBan);
			Console.registerCommand("!?", commands);
			Console.registerCommand("!факт", getFact);
		}
		
		static private function getFact():void {
			Console.success("FACT");
			WebLoader.bytes("http://getfact.ru/ajax/getfact.php?r=" + Math.random(), onFactLoaded);
			
		}
		
		static private function onFactLoaded(ba:ByteArray):void {
			var text:String = ba.readMultiByte(ba.length, "windows-1251");
			You.say(text);
		}
		
		static public function commands():void {
			You.publicMessage(Remote.userId,
				"Доступные команды: !онлайн - онлайн | !кто имя - ip адрес | !бан имя - забанить пользователя | !инфометр инфа - проверяет инфу | !мафия, !слова, !викторина - голосование за старт игр | !стоп - голосование за выключение игр"
			);
		}
		
		static public function voteBan(userId:String):void {
			
			userId = StringUtils.getUserId(userId);
			want(userId);
		}
		
		static public function wantStop():void {
			want(STOP);
		}
		
		static public function wantMafia():void {
			if (Mafia.isStarted) return;
			want(MAFIA);
		}
		
		static public function wantWords():void {
			if (Words.isStarted) return;
			want(WORDS);
		}
		
		static public function wantQuiz():void {
			if (Quiz.isStarted) return;
			want(QUIZ);
		}
		
		static public function want(item:String):void {
			votes[Remote.userId] = {time: getTimer(), item: item};
			check(item);
		}
		
		
		static public function check(item:String):void {
			
			var now:uint = getTimer();
			var numVotes:int = 0;
			var userId:String;
			var vote:Object;
			
			for (userId in votes) {
				
				vote = votes[userId];
				
				if (vote.item == item && now - vote.time < voteInterval) {
					
					numVotes++;
					
					if (numVotes >= startVotes) {
						
						//Очистит голоса за этот объект голосования
						for (userId in votes) {
							if (votes[userId].item == item) delete votes[userId];
						}
						
						start(item);
						return;
					}
				}
			}
			
			if (item.charAt(0) == "m") {
				You.say("Забанить пользователя " + Room.getNickname(item) + ": " + numVotes + " из " + startVotes + " необходимых голосов!");
			}else {
				You.say(item + ": " + numVotes + " из " + startVotes + " необходимых голосов!");
			}
			

			
		}
		
		static public function start(item:String):void {
			
			if (item.charAt(0) == "m") {
				Moderator.ban(item, "Коллектив Вас выгнал :(");
				return;
			}
			
			if (item == MAFIA) Mafia.start();
			if (item == QUIZ) Quiz.start();
			if (item == WORDS) Words.start();
			if (item == STOP) {
				Words.stop();
				Quiz.stop();
				Mafia.stop();
			}
		}
		
		static public function infometer(str:String):void {
			
			
			
			str = str.toUpperCase();
			
			var lastChar:String = "";
			var phrase:uint = 0;
			
			//Только русские буквы в большом регистре без повторений считаем сумму
			for (var i:int = 0; i < str.length; i++) {
				
				var char:String = str.charAt(i);
				var code:int = str.charCodeAt(i);
				
				//не выкидываем букву следующего слова
				if (char == " ") lastChar = "";
				
				if (char == lastChar) continue;
				if ((code < 1040 || code > 1071) && (code < 65 || code > 90)) continue;
				
				lastChar = char;
				phrase += code;	
			}
			
			
			var value:int = parseInt(MD5.hash(String(phrase)).substr(0, 2), 16);
			value = value * 100 / 255;
			

			You.publicMessage(Remote.userId, "Инфа: " + value + "%"); 
			
		}
		
		static public function who(userId:String):void {
			Room.who(userId);
		}
		
		static public function online():void {
			Room.online();
		}
		
	}

}