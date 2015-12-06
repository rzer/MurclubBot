package commands {
	import controllers.Remote;
	import controllers.You;
	import simplify.Call;
	
	/**
	 * Пример команды
	 * @author rzer & reraider
	 */
	public class LongCommand extends Command {
		
		
		public function LongCommand() {
			super();
			
			return;
			//Здесь делаем что-то длинное
			Call.after(3000, onComplete);
		}
		
		private function onComplete():void {
			
			//Ответ туда же откуда он пришёл
			reply("Ответ через 3000 мс");

			//Не забывай вызвать complete, чтобы команда потёрлась
			complete();
		}
		
	}

}