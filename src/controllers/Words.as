package controllers {
	import common.WordChecker;
	import simplify.Console;
	import elements.Server;
	import simplify.Call;
	import simplify.ObjectEvent;
	import common.StringUtils;
	
	/**
	 * Игра в составление слов
	 * @author rzer & reraider
	 */
	
	public class Words {
		
		private static var mainWords:Array = [
			"делопроизводительница",
			"человеконенавистничество",
			"высокопревосходительство",
			"одиннадцатиклассница",
			"гидролокатор",
			"неудовлетворительно",
			"соответственно",
			"переосвидетельствоваться",
			"субстанционализироваться",
			"интернационализироваться",
			"телеграммааппарат",
			"водоворотоподобно",
			"самообороноспособность",
		];
		
		private static var currentWord:int = -1;
		
		private static var mainWord:String = "";
		private static var availableLetters:Array = [];
		private static var correctWords:Array = [];
		private static var playersWords:Object = { };
		
		private static var isGame:Boolean = false;
		static public var isStarted:Boolean = false;
		
		public static function init():void {
			
			Console.register("/startWords", start);
			Console.register("/stopWords", stop);
			
			Console.info("Слова:");
			Console.tip("/startWords, /stopWords  - запускаем/останавливаем викторину на слова");
			
			
		}
		
		public static function start():void {
			
			if (isStarted) return;
			isStarted = true;
			
			WordChecker.prepareWords();
			
			Console.info("Давайте играть в слова!");
			You.say("Давайте играть в слова!");
			
		
			Server.bind("PRIVMSG", onMessage);
			Call.after(5000, selectWord);
			
		}
		
		public static function stop():void {
			
			if (!isStarted) return;
			isStarted = false;
			
			Console.info("Викторина остановлена");
			You.say("Викторина остановлена");
			
			Server.unbind("PRIVMSG", onMessage);
			isGame = false;
			Call.forget(selectWord);
			Call.forget(onGameEnded); 
			
		}
		
		private static function onMessage(e:ObjectEvent):void {
			
			var phrase:String = StringUtils.getPhrase(e.data);
			
			var userId:String = StringUtils.extractUserId(e.data[0]);
			var target:String = e.data[2];
			
			if (target == Login.userId) {
				checkAnswer(userId, phrase);
			}
			
			
		}
		
		
		
		private static function checkAnswer(userId:String, word:String):void {
			

			if (!isGame) {
				return;	
			}
			
			word = word.toLowerCase();
			
			if (word.length == 0 || word == mainWord) {
				return;
			}
			
			
			
			//Подходит ли слово по буквам
			var letters:Array = availableLetters.concat();
			
			for (var i:int = 0; i < word.length; i++) {
				
				var char:String = word.charAt(i).toLowerCase();
				
				var anIndex:int = availableLetters.indexOf(char);
				
				if (anIndex == -1) {
					return;
				}
				
				letters.splice(anIndex, 1);
				
			}
			
			
			
			//Игрок ещё не называл слова
			if (!playersWords[userId]) {
				playersWords[userId] = [];
			}
			
			var words:Array = playersWords[userId];
			
			//Игрок уже называл это слово
			if (words.indexOf(word) != -1) {
				return;
			}
			
			//Проверяем слово в словаре
			if (!WordChecker.checkWord(word)) {
				return;
			}
			
			if (correctWords.indexOf(word) == -1) {
				correctWords.push(word);
			}
			
			words.push(word);
			You.privateMessage(userId, "Слово \"" + word + "\" засчитано!. Всего: " + words.length);			
		}
		
		
		
	
		
		private static function selectWord():void {
			
			currentWord++;
			if (currentWord == mainWords.length) {
				currentWord = 0;
			}
			mainWord =  mainWords[currentWord];
			mainWord = mainWord.toLowerCase();
			correctWords = [];
			playersWords = { };
			
			availableLetters = mainWord.split("");
			isGame = true;
			
			Call.after(120000, onGameEnded);
			
			You.say("Слово: " + mainWord.toUpperCase() + ". Игра началась! Время 2 минуты. Писать слова в личку");
			Console.info("Новое слово: " + mainWord.toUpperCase());
		}
		
		private static function onGameEnded():void {
			
			isGame = false;
			
			//Определение победителя
			var winnerIds:Array = [];
			var winnerCount:int = 0;
			
			for (var playerId:String in playersWords) {
				var words:Array  = playersWords[playerId];
				
				You.privateMessage(playerId, "Игра завершена");
				
				if (winnerCount < words.length) {
					winnerIds = [playerId];
					winnerCount = words.length;
				}else if (winnerCount == words.length) {
					winnerIds.push(playerId);
				}
			}
			
			
			//id в ники
			var nicks:Array = [];
			
			for (var i:int = 0; i < winnerIds.length; i++) {
				nicks.push(Room.getNickname(winnerIds[i]));
			}
			
			var prefix:String = (winnerIds.length == 1) ? "ь" : "и";
			
			if (nicks.length == 0) {
				You.say("Игра завершена. Победителя нет :(");	
			}else {
				You.say(	
					"Игра завершена. Победител" + prefix + ": " +
					nicks.join(", ") +
					". Слов составлено: " + winnerCount +
					". Всего игроками составлено " + correctWords.length + " cлов: " +
					correctWords.join(", ")
				);
			}
			
			Call.after(10000, selectWord);
		}
		
	}

}