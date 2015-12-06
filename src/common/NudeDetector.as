package common {
	import flash.display.BitmapData;
	/**
	 * Определение порно в фотках
	 * @author rzer & reraider
	 */
	public class NudeDetector {
		static private var skinMap:Array;
		static private var detectedRegions:Array;
		static private var mergeRegions:Array;
		static private var width:int;
		static private var lastFrom:int;
		static private var lastTo:int;
		
		public static function scanImage(imageData:BitmapData):void {
			
			skinMap = [];
			detectedRegions  = [];
			mergeRegions  = [];
			
			width = imageData.width;
			lastFrom = -1,
			lastTo = -1;
		}
		
		private static function addMerge(from:int, to:int):void {
			
			lastFrom = from;
			lastTo = to;
			
			var len:int = mergeRegions.length,
			var fromIndex:int = -1,
			var toIndex:int = -1;
			
			while(len--){
				
					var region:Array = mergeRegions[len],
					var rlen:int = region.length;
					
					while(rlen--){
					
						if(region[rlen] == from){
							fromIndex = len;
						}
						
						if(region[rlen] == to){
							toIndex = len;
						}						
					}
				}
			
				if(fromIndex != -1 && toIndex != -1 && fromIndex == toIndex){
					return;
				}
	
				if(fromIndex == -1 && toIndex == -1){
					mergeRegions.push([from, to]);
					return;
				}
				
				if(fromIndex != -1 && toIndex == -1){
					mergeRegions[fromIndex].push(to);
					return;
				}
				
				if(fromIndex == -1 && toIndex != -1){
					mergeRegions[toIndex].push(from);
					return;
				}
				
				if(fromIndex != -1 && toIndex != -1 && fromIndex != toIndex){
					mergeRegions[fromIndex] = mergeRegions[fromIndex].concat(mergeRegions[toIndex]);
					mergeRegions.splice(toIndex,1);
					return;
				}
		}
		
	}

}