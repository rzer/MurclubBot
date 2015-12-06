package common {

	/**
	 * Утилиты массивов
	 * @author rzer & reraider
	 */
	public class ArrayUtils {
			
		//Тусуем элементы масива
		public static function shuffle(arr:Array):Array {
			
			arr = arr.concat();
			
			var arr2:Array = [];
			while (arr.length > 0) {
				arr2.push(arr.splice(Math.round(Math.random() * (arr.length - 1)), 1)[0]);
			}
			
			return arr2;
		}
		
	}

}