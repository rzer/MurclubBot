package {
	
	import commands.LongCommand;
	import common.QuizQuestions;
	import common.StringUtils;
	import controllers.ChatBot;
	import controllers.Custom;
	import controllers.Login;
	import controllers.Mafia;
	import controllers.Moderator;
	import controllers.Quiz;
	import controllers.Remote;
	import controllers.Room;
	import controllers.RoomFilter;
	import controllers.UserCommands;
	import controllers.Voter;
	import controllers.Words;
	import controllers.You;
	import simplify.Console;
	import elements.Server;
	import flash.display.Sprite;
	import flash.sampler._setSamplerCallback;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import simplify.Call;
	
	/**
	 * Мурклуб бот
	 * Свободная лицензия
	 * @author rzer & reraider
	 */
	public class Main extends Sprite {
		
		
		public function Main():void {
			
			Console.init(this);
			Console.write("MurClubBot v2.1. Авторы: rzer, fieign" + "A".charCodeAt(0) + ", " + "Z".charCodeAt(0));
			Console.toggle();
			
			QuizQuestions.init();
			Login.init();
			Server.init();
			Room.init();
			Moderator.init();
			You.init();
			Quiz.init();
			Words.init();
			Mafia.init();
			Remote.init();
			RoomFilter.init();
			UserCommands.init();
			ChatBot.init();
			Voter.init()
			
			
			//Login.login("0ldera1337@gmail.com", "220170");

			//Custom.init();
		
			
		}
		
		
		

		
	}
	
}