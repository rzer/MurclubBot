package controllers {
	import elements.Console;
	
	
	/**
	 * Класс для написания своих плагинов
	 * @author rzer & reraider
	 */
	public class Custom {
		
		public static function init() {
			
			//Фильтры по умолчанию на комнату
			RoomFilter.filters = {
				"shoot": 1,
				"ip": 1,
				"rating": 1000,
				"guest": 1,
				"ads": 1
			};
			
			
			//Авторизация при заходе
			Login.login();
			
			//Регистрируем функции как команды
			Console.registerCommand("/test", test);
			
			//Ниже добавляй подсказки в консоль
			Console.info("Custom:");
			Console.tip("/test - выводит сообщение This is test");
		}
		
		//А сюда все свои функции
		
		static public function test():void {
			You.say("This is test");
		}
		
	}

}