package controllers {
	import common.StringUtils;
	import elements.Console;
	import elements.Server;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.utils.Dictionary;
	
	/**
	 * Полуразумные ответы на публичные вопросы 
	 * @author rzer & reraider
	 */
	public class ChatBot {
		
		public static var answerTo:Dictionary = new Dictionary();
		
		public static function init():void {
			
			Server.bind("PRIVMSG", onMessage);
			
		}
		
		private static function onMessage(e:Object):void {
			
			var botName:String = Room.getNickname(Login.userId);
			var phrase:String = StringUtils.getPhrase(e.data);
			

			if (phrase.indexOf(botName + ", ") == 0) {
				
				phrase = phrase.substr(botName.length + 2);
				
				Console.success("? " + phrase);
				
				var loader:URLLoader = Login.createLoader("http://xu.su/send.php", { bot:1, text: phrase }, onAnswer);
				answerTo[loader] = StringUtils.extractUserId(e.data[0]);
				
			}
			
		}
		
		static public function onAnswer(e:Event):void {
			
			var loader:URLLoader = e.currentTarget as URLLoader;
			
			Console.success("! " + loader.data);
			
			var data:Object = JSON.parse(loader.data);
			
			if (data.text){
				You.publicMessage(answerTo[loader], data.text);
			}

			delete answerTo[loader];
		}
		
		
		
	}

}