package common {
	import simplify.Console;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	/**
	 * Локальная база данных вопросов
	 * @author rzer
	 */
	public class QuizQuestions {
		
		private static var indexPath:String = File.applicationDirectory.nativePath + "/" + "quiz_index.bdb";
		private static var dbPath:String = File.applicationDirectory.nativePath + "/" + "quiz_db.bdb";
		
		private static var indexFile:File = new File(indexPath);
		private static var dbFile:File = new File(dbPath);
		
		private static var index:FileStream;
		private static var db:FileStream;
		
		private static var mode:String = "";
		
		static private var fs:FileStream;
		
		//Парсим вопросы из файла
		public static function parse(path:String, encoding:String = "windows-1251"):void{
			
			var file:File = new File(File.applicationDirectory.nativePath + "/" + path);
			fs = new FileStream();
			fs.open(file, FileMode.READ);
			
			var text:String = fs.readMultiByte(fs.bytesAvailable, encoding);
			fs.close();
			
			var list:Array = text.split("\r\n");
			
			for (var i:int = 0; i < list.length; i++){
				var line:String = list[i];
				var temp:Array = line.split("|");
				add(temp[0], temp[1]);
			}
			
			Console.info("complete parse " + list.length);
			
		}
		
		public static function startMode(newMode:String):void{
			
			if (mode == newMode) return;
			
			stopMode();
			mode = newMode;
			
			index = new FileStream();
			db = new FileStream();
			
			index.open(indexFile, newMode);
			db.open(dbFile, newMode);
		}
		
		
		//Переключаем мод - выключаем предыдущий режим
		static public function stopMode():void {
			
			if (mode == "") return;
			
			mode = "";
			
			index.close();
			db.close();
		}
		
		
		public static function add(question:String, answer:String):void{
			
			startMode(FileMode.WRITE);

			var pos:uint = db.position;
			
			index.writeUnsignedInt(pos);
			db.writeUTF(question + "|" + answer);
				
			
		}
		
		static public function init():void {
			Console.register("/qp", parse);
			Console.register("/qt", test);
		}
		
		static private function test():void {
			Console.info(JSON.stringify(getRandom()));
		}
		
		public static function getRandom():Object{
			
			startMode(FileMode.READ);
			
			var totalQuestions:int = indexFile.size / 4;
			var questionNumber:int = Math.floor(totalQuestions * Math.random());
			
			trace(questionNumber, totalQuestions);
			
			index.position = questionNumber * 4;
			
			var pos:uint = index.readUnsignedInt();
			
			db.position = pos;
			
			var str:String = db.readUTF();
			var list:Array = str.split("|");
			return {question:list[0], answer:list[1]};
		}
		
		
	}

}