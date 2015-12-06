package controllers {
	import elements.Console;
	import simplify.Call;
	/**
	 * Голосовалка
	 * @author rzer & reraider 
	 */
	public class Voter {
		
		private static var isStarted:Boolean = false;
		private static var voters:Object = { };
		static private var question:String;
	
		
		public static function init():void {
			
			Console.registerCommand("!голосование", startVoting);
			Console.registerCommand("!за", voteYes);
			Console.registerCommand("!против", voteNo);
			
			Console.info("Voter:");
			Console.tip("!голосование вопрос, !за, !против");
			
		}
		
		public static function startVoting(question:String):void {
			
			
			if (isStarted) {
				You.say("Дождитесь окончания голосования")
				return;
			}
			
			Voter.question = question;
			voters = {}
			isStarted = true;
			
			
			You.say("На повестке дня: " + question);
			You.say("Голосуйте !за или !против");
			
			
			Call.after(30000, stopVoting);
			
		}
		
		static private function voteYes():void {
			voters[Remote.userId] = true;
		}
		
		static private function voteNo():void {
			voters[Remote.userId] = false;
		}
		
		
		static private function stopVoting():void {
			isStarted = false;
			
			var yes:int = 0;
			var no:int = 0;
			
			for each (var vote:Boolean in voters) {
				if (vote) yes++;
				else no++;
			}
			
			You.say("Голосование окончено! За:" + yes +", против:" + no);
		}
		
	}

}