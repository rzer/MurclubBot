package controllers {
	import simplify.Console;
	import elements.Server;
	import common.StringUtils;
	
	/**
	 * Функции модератора
	 * @author rzer & reraider
	 */
	
	public class Moderator {
		
		public static function init():void {
			
			Console.register("/ban", ban);
			Console.register("/unban", unban);
			Console.register("/prison", prison);
			Console.register("/unprison", unprison);
			
			Console.info("Модератор:");
			Console.tip("/ban, /unban mID reason time - Забанить/Разбанить пользователя");
		}
		
		static public function unprison(userId:String):void {
			userId = StringUtils.getUserId(userId);
			Server.raw("UNPRISON " + userId);
		}
		
		static private function prison(userId:String, reason:String = "оскорбления.", time:uint = 86400):void {
			userId = StringUtils.getUserId(userId);
			Server.raw("PRISON " + userId + " " + time + " :" + reason);
		}
		
		public static function ban(userId:String, reason:String = "Вам тут не место", time:uint = 3600):void {
			userId = StringUtils.getUserId(userId);
			Server.raw('BANE ' + Room.currentRoom + ' ' + userId + ' 00m' + time + 's :' + reason);
		}
		
		public static function unban(userId:String):void {
			userId = StringUtils.getUserId(userId);
			Server.raw('UNBANE ' + Room.currentRoom + ' ' + userId);
		}
		
	}

}