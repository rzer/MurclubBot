package simplify {
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * Загрузчик данных 
	 * 
	 * @example http://atflash.ru/simplify/src/samples/FlickrCarousel.as
	 *
	 * addChild(WebLoader.crossBitmap("http://domain.without.crossdomain.xml/image.png").center(100,100));
	 * 
	 * WebLoader.json("path/to.json", onJSONLoaded);
	 * private function onJSONLoaded(data:Object):void{
	 *    //в эту функцию будет передан загруженный объект
	 * }
	 * 
	 * 
	 * @author rzer & reraider
	 * @version 1.1
	 * @see http://atflash.ru/simplify
	 */
	
	public class WebLoader extends Sprite {
		
		public static var startLocaly:Boolean = false;
		
		//////////////////   STATIC   ////////////////////
		
		public static const BITMAP:String = "bitmap";
		public static const CROSS_BITMAP:String = "crossbitmap";
		public static const LOADER:String = "loader";
		public static const XML_DATA:String = "xml";
		public static const JSON_DATA:String = "json";
		public static const TEXT:String = "text";
		public static const SWF:String = "swf";
		static public const BYTE_ARRAY:String = "byteArray";
		
		private static var webs:Array = [];
		private static var loaders:Dictionary = new Dictionary();
		
		public static function init(stage:Stage):void {
			startLocaly = stage.loaderInfo.url.indexOf("file") == 0;
		}
		
		/**
		 * Загрузка картинки
		 * @param	path - путь до картинки
		 * @param	handler - функция окончания загрузки (arg:Bitmap)
		 * @return 	загрузчик WebLoader
		 */
		public static function bitmap(path:String, handler:Function = null):WebLoader {
			return createLoader(path, BITMAP, handler);
		}
		
		/**
		 * Загрузка картинки с домена без crossdomain.xml
		 * @param	path - путь до картинки
		 * @param	handler - функция окончания загрузки (arg:Bitmap)
		 * @return 	загрузчик WebLoader
		 */
		public static function crossBitmap(path:String, handler:Function = null):WebLoader {
			return createLoader(path, CROSS_BITMAP, handler);
		}
		
		/**
		 * Загрузка xml файла
		 * @param	path - путь до XML файла
		 * @param	handler - функция окончания загрузки (arg:XML)
		 * @return	загрузчик WebLoader
		 */
		public static function xml(path:String, handler:Function):WebLoader {
			return createLoader(path, XML_DATA, handler);
		}
		
		/**
		 * Возвращает объект Loader для загружаемого содержимого
		 * @param	path - путь до визуального контента
		 * @param	handler - функция окончания загрузки (arg:Loader)
		 * @return 	загрузчик WebLoader
		 */
		public static function loader(path:String, handler:Function = null):WebLoader {
			return createLoader(path, LOADER, handler);
		}
		
		/**
		 * Возвращает данные в виде объекта ранее десериализованные из json
		 * @param	path - путь до json содержимого
		 * @param	handler - функция окончания загрузки (arg:Object)
		 * @return	загрузчик WebLoader
		 */
		public static function json(path:String, handler:Function = null):WebLoader {
			return createLoader(path, JSON_DATA, handler);
		}
		
		
		/**
		 * Возвращает данные в виде текста
		 * @param	path - путь до текстового содержимого
		 * @param	handler - функция окончания загрузки (arg:String)
		 * @return	загрузчик WebLoader
		 */
		public static function text(path:String, handler:Function = null):WebLoader {
			return createLoader(path, TEXT, handler);
		}
		
		/**
		 * Возвращает из SWF объект класса единственного ребёнка лежащего на сцене с одним кадром, или контент в противном случае
		 * @param	path - путь до SWF
		 * @param	handler - функция окончания загрузки (arg:DisplayObject)
		 * @return	загрузчик WebLoader
		 */
		public static function swf(path:String, handler:Function = null):WebLoader {
			return createLoader(path, SWF, handler);
		}
		
		/**
		 * Возвращает массив байт
		 * @param	path - путь до файла
		 * @param	handler - функция окончания загрузки (arg:ByteArray)
		 * @return	загрузчик WebLoader
		 */
		public static function bytes(path:String, handler:Function):WebLoader {
			return createLoader(path, BYTE_ARRAY, handler);
		}
		
		/**
		 * Уничтожить загрузчик
		 * @param	webLoader	загрузчик WebLoader
		 */
		public static function remove(webLoader:WebLoader):void {
			
			var loader:ContentLoader = loaders[webLoader.path];
			
			if (loader) {
				loader.destroy();
			}
			
			delete loaders[webLoader.path];
			
		}
		
		
		
		
		
		
		private static function createLoader(path:String, type:String, handler:Function = null):WebLoader {
			var web:WebLoader = new WebLoader();
			web.load(path, type, handler);
			webs.push(web);	
			return web;
		}
		
		
		//////////////////////////////////////////////////
		
		private var loaded:Boolean = false;
		private var isCentered:Boolean = false;
		private var path:String;
		private var handler:Function;
		private var type:String;
		
		private var display:DisplayObject;
		private var cX:int = 0;
		private var cY:int = 0;
		
		public function get content():*{
			var loader:ContentLoader = loaders[path];
			return loader.getContent(type);
		}
		
		
		
		public function bitmap(path:String, handler:Function = null):void {
			load(path,BITMAP,handler);
		}
		
		public function xml(path:String, handler:Function = null):void {
			load(path, XML_DATA, handler);
		}
		
		public function loader(path:String, handler:Function = null):void {
			load(path, LOADER, handler);
		}
		
		public function crossBitmap(path:String, handler:Function = null):void {
			load(path, CROSS_BITMAP, handler);
		}
		
		public function json(path:String, handler:Function = null):void {
			load(path, JSON_DATA, handler);
		}
		
		public function text(path:String, handler:Function = null):void {
			load(path, TEXT, handler);
		}
		
		public function swf(path:String, handler:Function = null):void {
			load(path, SWF, handler);
		}
		
		
		
		
		public function center(cX:int = 0, cY:int = 0):WebLoader {
			
			this.cY = cY;
			this.cX = cX;
			
			isCentered = true;
			
			centerContent();
			return this;
		}
		
		public function blend(value:String):WebLoader {
			this.blendMode = value;
			return this;
		}
		
		public function getBitmap():Bitmap {
			return display as Bitmap;
		}
		
		
		private function load(path:String, type:String, handler:Function = null):void {
			
			this.type = type;
			this.handler = handler;
			this.path = path;
			
			var loader:ContentLoader = loaders[path];
			
			if (!loader) {
				loader = new ContentLoader();
				loader.start(path, type);
				loaders[path] = loader;
			}
			
			if (!loader.loaded){
				loader.addEventListener(Event.COMPLETE, onLoaded);
			}else {
				onLoaded();
			}
			
		}
		
		
		private function onLoaded(e:Event = null):void {
			
			loaded = true;

			var loader:ContentLoader = loaders[path];
			
			if (type == LOADER || type == BITMAP || type == CROSS_BITMAP || type == SWF) {
				
				display = loader.getContent(type) as DisplayObject;
				
				if (display){
					addChild(display);
					
					if (handler != null) {
						handler(display);
					}
				}
				
				
				
			}else if (type == XML_DATA) {
				
				var xml:XML = loader.getContent(type) as XML;
				handler(xml);
				
			}else if (type == JSON_DATA) {
				
				var obj:Object = loader.getContent(type) as Object;
				handler(obj);
				
			}else if (type == TEXT) {
				
				var str:String = loader.getContent(type) as String;
				handler(str);
				
			}else if (type == BYTE_ARRAY) {
				var ba:ByteArray = loader.getContent(type) as ByteArray;
				handler(ba);
			}
			
			clear();
			centerContent();
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function clear():void {
			var anIndex:int = webs.indexOf(this);
			
			if (anIndex != -1) {
				webs.splice(anIndex, 1);
			}
			
			handler = null;
		}
		
		private function centerContent():void {
			if (!isCentered) return;
			if (!loaded) return;
			
			if (display) {
				display.x = int(-display.width / 2) + cX;
				display.y = int(-display.height / 2) + cY;
			}
		}
		
		
		
		
	}

}

/////////////	INTERNAL


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;
import flash.utils.ByteArray;
import simplify.WebLoader;

internal class ContentLoader extends EventDispatcher {
	
	private var cross:Boolean;
	private var type:String;
	private var path:String;
	
	public var loaded:Boolean = false;
	
	private var visualLoader:Loader;
	private var dataLoader:URLLoader;
	private var bitmap:Bitmap;
	private var crossContent:DisplayObject;
	
	
	public function start(path:String, type:String):void {

		this.path = path;
		this.type = type;
		this.cross = (type == WebLoader.CROSS_BITMAP);
		
		var request:URLRequest = new URLRequest(path);
		
		if (type == WebLoader.BITMAP || type == WebLoader.LOADER || type == WebLoader.CROSS_BITMAP || type == WebLoader.SWF) {
			visualLoader = new Loader();
			
			if (cross) {
				visualLoader.addEventListener(Event.ADDED, onCrossComplete, true, int.MAX_VALUE);
			}else{
				visualLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onVisualComplete);
			}
			
			visualLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			visualLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			//Загружаем всё в свой секьюрити домен
			
			var securityDomain:SecurityDomain;
			
			if (path.split(".").pop() == "swf" && !WebLoader.startLocaly) {
				securityDomain = SecurityDomain.currentDomain;
			}
			
			var context:LoaderContext = new LoaderContext(true, new ApplicationDomain(),securityDomain);
			visualLoader.load(request, context);
			
		}else if (type == WebLoader.XML_DATA || type == WebLoader.JSON_DATA || type == WebLoader.TEXT || type == WebLoader.BYTE_ARRAY) {
			dataLoader = new URLLoader();
			
			if (type == WebLoader.BYTE_ARRAY) {
				dataLoader.dataFormat = URLLoaderDataFormat.BINARY;
			}
			
			dataLoader.addEventListener(Event.COMPLETE, onDataComplete);
			dataLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			dataLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			dataLoader.load(request);
		}
		
	}
	
	private function onCrossComplete(e:Event):void {
		
		crossContent = e.target as DisplayObject;
		
		visualLoader.removeEventListener(Event.ADDED, onCrossComplete);
		visualLoader.removeEventListener(Event.COMPLETE, onVisualComplete);
		visualLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
		visualLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		
		loaded = true;
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private function onDataComplete(e:Event):void {
		
		dataLoader.removeEventListener(Event.COMPLETE, onDataComplete);
		dataLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
		dataLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		

		loaded = true;
		dispatchEvent(new Event(Event.COMPLETE));

	}
	
	private function onIOError(e:IOErrorEvent):void {
		trace(e.toString());
	}
	
	private function onProgress(e:ProgressEvent):void {
	}
	
	private function onVisualComplete(e:Event):void {
		
		visualLoader.removeEventListener(Event.COMPLETE, onVisualComplete);
		visualLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
		visualLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		
		loaded = true;
		dispatchEvent(new Event(Event.COMPLETE));
		
	}
	
	public function getContent(type:String):* {
		
		if (type == WebLoader.LOADER) {
			return visualLoader;
		}else if (type == WebLoader.BITMAP || type == WebLoader.CROSS_BITMAP) {
			
			if (!bitmap) {
				
				if (cross){
					bitmap = crossContent as Bitmap;
				}else {
					try{
						bitmap = visualLoader.content as Bitmap;
					}catch (err:Error){
						//do nothing
					}
				}
				
			}
			
			if (!bitmap) return;
			
			var resultBitmap:Bitmap = new Bitmap();
			resultBitmap.bitmapData = bitmap.bitmapData;
			resultBitmap.smoothing = true;
			return resultBitmap;
			
		}else if (type == WebLoader.XML_DATA) {
			
			var xml:XML = new XML(dataLoader.data);
			return xml;
			
		}else if (type == WebLoader.JSON_DATA) {
			
			var obj:Object = JSON.parse(dataLoader.data);
			return obj;
			
		}else if (type == WebLoader.TEXT) {
			
			var str:String = String(dataLoader.data);
			return str;
			
		}else if (type == WebLoader.BYTE_ARRAY) {
			
			var ba:ByteArray = dataLoader.data as ByteArray;
			return ba;
			
		}else if (type == WebLoader.SWF) {
			
			var content:MovieClip = visualLoader.content as MovieClip;
			
			try {
				
				//Если один кадр, один символ на сцене и у него объявлен класс, то вернуть новый экземпляр этого класса
				if (content.numChildren == 1 && content.totalFrames == 1) {
					
					var child:Object = content.getChildAt(0) as Object;
					var ChildClass:Class = child.constructor as Class;
					
					if (ChildClass != MovieClip && ChildClass != Shape && ChildClass != Sprite) {
						return new ChildClass();
					}
					
				}
				
			}catch (err:Error) {
				
				return content;
			}
			
			
			return content;
		}
	}
	
	public function destroy():void {
		
		if (visualLoader) {
			visualLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onVisualComplete);
			visualLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			visualLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			visualLoader.unloadAndStop();
			visualLoader = null;
		}
		
		if (dataLoader) {
			dataLoader.removeEventListener(Event.COMPLETE, onDataComplete);
			dataLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			dataLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			dataLoader.close();
			dataLoader = null;
		}
	}
}