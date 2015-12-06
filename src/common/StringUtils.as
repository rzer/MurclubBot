package common {
	import controllers.Room;
	/**
	 * Работа со строками
	 * @author rzer & reraider
	 */
	public class StringUtils {
		
		public function StringUtils() {
			
		}
		
		static public function cp1251toUnicode(str:String):String {
			
			var new_str:String="";

			for(var i:int=0; i< str.length; i++){
				if(str.charCodeAt(i)>191){
					new_str+=String.fromCharCode(str.charCodeAt(i)+848);
				} else if(str.charCodeAt(i)==168){
					new_str+="Ё";
				} else if(str.charCodeAt(i)==184){
					new_str+="ё";
				} else{
					new_str+=str.charAt(i);
				}
			}

			return new_str;
		}
		
		public static function extractUserId(str:String):String {
			
			//:m1830204!M@5.18.176.24
			
			return str.substring(1, str.indexOf("!"));
			
		}
		
		public static function extractIP(str:String):String {
			
			//:m1830204!M@5.18.176.24
		
			return str.substr(str.indexOf("@") + 1);
			
		}
		
		public static function getUserId(str:String):String {
			
			//Передали число без буквы m
			if (!isNaN(Number(str))) {
				return "m" + str;
			}
			
			//Число с буквой m вначале
			if (str.charAt(0) == "m" && str.length > 1 && !isNaN(Number(str.substr(1)))) {
				return str;
			}
			
			//Другое - остаётся только никнейм пользователя
			return Room.getUserIdByName(str);
		}
		
		public static function getPhrase(arr:Array):String {
			
			var temp:Array = arr.join(" ").split(":");
			
			temp.shift();
			temp.shift();
			
			return temp.join(":");
		}
		
		
	}

}