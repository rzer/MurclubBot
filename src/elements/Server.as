package elements {
	import controllers.Room;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.Socket;
	import simplify.Call;
	import simplify.ObjectEvent;
	
	/**
	 * Работа с сервером мурклуба
	 * @author rzer & reraider
	 */
	public class Server {
		
		static private var codepage:String;
		static private var host:String;
		static private var port:int;
		static private var userId:String;
		static private var authToken:String;
		
		private static var socket:Socket;
		static private var buffer:String = "";
		
		public static var o:EventDispatcher = new EventDispatcher();
		
		
		public static function bind(type:String, func:Function):void {
			o.addEventListener(type, func);
		}
		
		public static function unbind(type:String, func:Function):void {
			o.removeEventListener(type, func);
		}
		
		public static function init():void {
			Console.registerCommand("/raw", raw);
			
			Console.info("Сервер:");
			Console.tip("/raw  - отправка 'сырой' команды");
		}
		
		public static function start(codepage:String, host:String, port:int, userId:String, authToken:String):void{
			Server.codepage = codepage;
			Server.host = host;
			Server.port = port;
			Server.userId = userId;
			Server.authToken = authToken;
			
			socket = new Socket();
            socket.addEventListener(Event.CONNECT, onSocketConnect);
            socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketSecurity);
            socket.addEventListener(IOErrorEvent.IO_ERROR, onSocketIOError);
            socket.addEventListener(Event.CLOSE, onSocketClose);
            socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			socket.connect(host, port);

		}
		
		private static function onSocketData(e:ProgressEvent):void {
			
			var data:String = buffer + socket.readMultiByte(socket.bytesAvailable, codepage);
			buffer = "";
			
			var lines:Array = data.split("\r\n");
			
			for (var i:int = 0; i < lines.length; i++) {
				
				var line:String = lines[i];
				
				if (line.indexOf("you cant ban IRCop") != -1) {
					Room.adminCatched();
					Console.error("IRCop detected");
				}
				
				var array:Array = line.split(" ");
				
				if (array.length > 1 && i != lines.length-1) {
					Console.write("<< " + line)
					o.dispatchEvent(new ObjectEvent(array[1], array));
				}else {
					buffer = line;
				}
			}
			
			;
		}
		
		private static function onSocketClose(event:Event) : void {
           Console.write("Соединение c сервером потеряно", Console.ERROR);
        }

        private static function onSocketIOError(event:IOErrorEvent) : void {
            Console.write("Ошибка получения данных из сокета", Console.ERROR);
        }

        private static function onSocketSecurity(event:SecurityErrorEvent) : void {
            Console.write("Ошибка безопасноси сокета", Console.ERROR);
        }

        private static function onSocketConnect(event:Event) : void  {
			
			
			raw("FLVERSION 1");
			raw("PASS " + authToken);
			raw("NICK :" + userId);
			raw("USER M no no :M");
			
			Call.after(10000, onPing);
			Call.after(5000, ready);
        }
		
		private static function onPing():void {
			raw("PING :m2.ru");
			Call.after(10000, onPing);
		}
		
		public static function raw(data:String):void {
			
			Console.write(">> " + data);
			
			if (socket == null) return;
			
			socket.writeMultiByte(data + "\r\n", codepage);
			socket.flush();
		}
		
		private static function ready():void {
			Console.write("Сокет подключился", Console.SUCCESS);
		}
		
	}

}