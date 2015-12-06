package controllers {
	
	import common.ArrayUtils;
	import elements.Console;
	import elements.Server;
	import simplify.Call;
	import simplify.WebLoader;
	import common.StringUtils;
	
	/**
	 * Угадайка слов
	 * @author rzer & reraider
	 */
	public class Quiz {
		
		private static var numQuestion:int = 0;
		
		private static var question:String = "";
		private static var answer:String = "";
		
		static private var nextQuestion:String = "";
		static private var nextAnswer:String = "";
		
		private static var closed:Array;
		private static var opened:Array;

		private static var winner:String;
		
		
		static public var isStarted:Boolean = false;
		
		public static function init():void {
			
			Console.registerCommand("/startQuiz", start);
			Console.registerCommand("/stopQuiz", stop);
			Console.registerCommand("/setQuestion", setQuestion);
			
			Console.info("Quiz:");
			Console.tip("/startQuiz, /stopQuiz - запускаем/останавливаем викторину");
			
		}
		
		static private function setQuestion(answer:String, question:String):void {
			nextQuestion = question;
			nextAnswer = answer;
		}
		
		public static function start():void {
			
			if (isStarted) return;
			isStarted = true;
			
			Console.info("Quiz bot активирован");
			You.say("Quiz bot активирован");
			
			Server.bind("PRIVMSG", onMessage);
			selectQuestion();
			
		}
		
		public static function stop():void {
			
			if (!isStarted) return;
			isStarted = false;
			
			Console.info("Викторина остановлена");
			You.say("Викторина остановлена");
			
			Server.unbind("PRIVMSG", onMessage);
			gameOver();
		}
		
		private static function onMessage(e:Object):void {
			
			var phrase:String = StringUtils.getPhrase(e.data);
			var userId:String = StringUtils.extractUserId(e.data[0]);
			
			checkAnswer(userId, phrase);
		}
		
		
		
		public static function selectQuestion():void {
			numQuestion++;
			WebLoader.json("http://reactive.cloudapp.net/api/trivia/randomQuestion?i=" + numQuestion, onQuestion);
		}
		
		private static function onQuestion(data:Object):void {
			
			question = data.question;
			answer = data.answer;
			
			if (nextQuestion != "") {
				question = nextQuestion;
				answer = nextAnswer;
				nextQuestion = "";
				nextAnswer = "";
			}
			
			Console.info("Ответ в викторине: " + answer);
			
			closed = [];
			opened = [];
			
			for (var i:int = 0; i < answer.length; i++) {
				closed.push(i);
			}
			
			closed = ArrayUtils.shuffle(closed);
			
			You.say("Вопрос: " + question);
			Call.after(10000, getTip);
		}
		
		private static function getTip():void {
			
			var tip:String = "";
			
			if (closed.length == 0) {
				lose();
				return;
			}
			
			for (var i:int = 0; i < answer.length; i++) {
				if (opened.indexOf(i) != -1) {
					tip += answer.charAt(i).toUpperCase() + " ";
				}else {
					tip += "_ ";
				}
			}
			
			You.say("Подсказка: " + tip);
			openLetter();
			Call.after(10000, getTip);
		}
		
		private static function lose():void {
			You.say("Никто не угадал! Загаданое слово: " + answer);
			gameOver();
			Call.after(10000, selectQuestion);
		}
		
		private static function openLetter():void {
			opened.push(closed.pop());
		}
		
		public static function gameOver():void {
			
			question = "";
			answer = "";
			closed = null;
			opened = null;
			
			Call.forget(getTip);
			Call.forget(selectQuestion);
		}
		
		
		public static function checkAnswer(userId:String, phrase:String):void {
			
			if (answer == "") return;
			
			if (phrase.toLowerCase() == answer.toLowerCase()) {
				win(userId);
			}
		}
		
		private static function win(userId:String):void {
			winner = userId;
			gameOver();
			numQuestion++;
			
			Console.info("Игрок " + Room.getNickname(userId) + " угадал!");
			
			WebLoader.json("http://reactive.cloudapp.net/api/trivia/addScore?id=" + userId + "&points=1&i=" + numQuestion, onUserInfo);
		}
		
		private static function onUserInfo(data:Object):void {
			
			trace(JSON.stringify(data));
			
			var list:Array = [
				"Да детка, это правильный ответ! +1 бал тебе.",
				"Умница, быстрее всех! Так держать",
				"И это правильный ответ. Держи бал"
			]
			
			var randomPhrase:String = list[Math.floor(list.length * Math.random())];
			
			You.publicMessage(winner, randomPhrase + " Всего: " + data.points);
			
			Call.after(10000, selectQuestion);
		}
		
		
		
	}

}