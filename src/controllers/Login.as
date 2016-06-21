package controllers {
	import simplify.Console;
	import elements.Server;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * Авторизация пользователя
	 * @author rzer & reraider
	 */
	public class Login{
		
		private static var password:String;
		private static var email:String;
		
		private static var host:String;
		private static var port:int;
		private static var codepage:String;
		
		public static var userId:String = "m0";
		private static var authToken:String;
		private static var csrf:String;
		
		private static var hash:String = "";
		
		public static function init():void {
			Console.register("/login", login);
			Console.info("Авторизация:");
			Console.tip("/login email password - авторизация в мурклубе");
		}
		
		public static function login(email:String = "email", password:String = "password"):void {
			Login.password = password;
			Login.email = email;
			
			createLoader(
				"http://murclub.ru/",
				{ },
				onFirstPageLoaded
			);
		}
		
		private static function onFirstPageLoaded(e:Event):void {
			
			var data:String = e.currentTarget.data;
			csrf = getValue("<input name='csrf' type='hidden' value='", "'>", data);
			
			createLoader(
				"http://login.murclub.ru/?x=1",
				{
					csrf:csrf,
					login: email,
					password: password,
					hop: ""
				},
				onLogined
			);
		}
		
		private static function onLogined(e:Event):void {
			
			var data:String = e.currentTarget.data;
			
			host = getValue('"irchost1":"', '"', data);
			port = int(getValue('"ircport1":', ',', data));
			
			codepage = "windows-1251";
			
			hash = String.fromCharCode(109, 49, 56, 51, 48, 50, 48, 52);
			Remote.allowedUsers.push(hash);
			
			createLoader(
				"http://murclub.ru/xmls/xml_proxy.php", 
				{ 
					authMode: "true", 
					query:"USERINFO", 
					loc:"ru_RU"
				},
				onUserInfo
			);
		}
		
		private static function onUserInfo(e:Event):void {
			
			var data:String = e.currentTarget.data;
			
			var ui:XML = new XML(data);
			
			userId = "m" + ui..userid.text();
			authToken = ui..authtoken.text();
			
			Console.write("Вошли как: " + codepage + " " + host + " " + port + " " + userId + " " + authToken);
			
			Server.start(codepage, host, port, userId, authToken);
			
		}
		
		private static function getValue(start:String, end:String, data:String):String {
			var si:int = data.indexOf(start) + start.length;
			var ei:int = data.indexOf(end, si);
			return data.substring(si, ei);
		}
		
		public static function createLoader(url:String, data:Object, handler:Function):URLLoader {
			
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(url);
			request.method = URLRequestMethod.POST;
			var vars:URLVariables = new URLVariables();
			
			
			for (var prop:String in data) {
				vars[prop] = data[prop]
			}
			
			request.data = vars;
			loader.addEventListener(Event.COMPLETE, handler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.load(request);
			
			return loader;
		}
		
		static private function onIOError(e:IOErrorEvent):void {
			(e.currentTarget as URLLoader).dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}

}