package common {
	import controllers.Login;
	import simplify.Console;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import org.bytearray.gif.encoder.GIFEncoder;
	import simplify.PNGEncoder;
	import simplify.URLUploader;
	import simplify.WebLoader;
	/**
	 * Аплоадим анимашки в мурчик
	 * @author rzer & reraider
	 */
	public class GifUploader {
		
		private var uploadUrl:String;
		private var gifPath:String;
		private var gifBytes:ByteArray;
		private var loader:Loader;
		private var pngBytes:ByteArray;
		
		
		public function GifUploader(path:String) {
			Console.info("1. " + path);
			gifPath = path;
			Login.createLoader("http://murclub.ru/gif.php", { }, onGifPath);
		}
		
		private function onGifPath(e:Event):void {
			
			
			var data:String = e.currentTarget.data;
			
			trace("hm" , data);
			
			var startIndex:int = data.indexOf("http://upload2.murclub.ru/upld.php");
			var endIndex:int  = data.indexOf("'", startIndex);
			
			uploadUrl = data.substring(startIndex, endIndex);
			uploadUrl = unescape(uploadUrl);
			Console.info("2. " + uploadUrl);
			
			WebLoader.bytes(gifPath, onGifLoaded);
		}
		
		private function onGifLoaded(ba:ByteArray):void {
			gifBytes = ba;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapLoaded);
			loader.loadBytes(ba);
			
		}
		
		private function onBitmapLoaded(e:Event):void {
			
			var bitmap:Bitmap = loader.content as Bitmap;
			
			var src:BitmapData = bitmap.bitmapData;
			var bd:BitmapData = new BitmapData(185, 139, false, 0xffffff);
			
			var scaleX:Number = 185 / src.width;
			var scaleY:Number = 139 / src.height;
			
			var scale:Number = Math.min(scaleX, scaleY);
			
			var mtx:Matrix = new Matrix();
			mtx.scale(scale, scale);
			mtx.translate((185 - src.width * scale) / 2, (139 - src.height * scale) / 2);
			
			bd.draw(bitmap.bitmapData, mtx);
			
			pngBytes = PNGEncoder.encode(bd);
			
			var encoder:GIFEncoder = new GIFEncoder();
			encoder.start();
			encoder.addFrame(bd); // for each frame
			encoder.finish();
			
			var uploader:URLUploader = new URLUploader();
			uploader.addFile(pngBytes, "png_preview", "png_preview.png");
			uploader.addFile(gifBytes, "big_gif", "big_gif.gif");
			uploader.addFile(encoder.stream, "small_gif", "small_gif.gif");
			uploader.upload(uploadUrl);
		}
		
	}

}