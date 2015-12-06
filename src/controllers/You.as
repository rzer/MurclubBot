package controllers {
	
	import common.GifUploader;
	import elements.Console;
	import elements.Server;
	import common.StringUtils;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.system.System;
	import simplify.Call;
	
	/**
	 * Действия к боту
	 * @author rzer & reraider
	 */
	
	public class You {
		
		private static var roomStack:Array = [];
		
		public static function init():void {
			
			Console.registerCommand("/join", join);
			Console.registerCommand("/nick", changeNickname);
			Console.registerCommand("/jump", jump);
			Console.registerCommand("/prv", privateMessage);
			Console.registerCommand("/pub", publicMessage);
			Console.registerCommand("/say", say);
			Console.registerCommand("/shoot", shoot);
			Console.registerCommand("/heal", heal);
			Console.registerCommand("/audio", audio);
			Console.registerCommand("/song", song);
			Console.registerCommand("/advertisment", advertisment);
			Console.registerCommand("/speak", speak);
			Console.registerCommand("/gif", gif);
			
			Console.info("Бот:");
			
			Console.tip(
				"/join #room - Войти в комнату, " +
				"/nick nickname - Сменить ник, /jump value - переместиться, " +
				"/prv, /pub mID message - приватное/публичное сообщение игроку, " + 
				"/say message - сообщение в комнате, " +
				"/shoot, /heal mID - стрельба, лечение, " +
				"/audio url - отправка айдио в чат, " +
				"/advertisment message - отправка всем людям в комнате приватного сообщения"
			);

			
			sendNext();
		}
		
		static public function gif(path:String):void {
			var uploader:GifUploader = new GifUploader(path);
		}
		
		static public function speak(text:String):void {
			
			Login.createLoader("http://www.linguatec.de/onlineservices/vrs15_getmp3?text=" + text + "&voiceName=yuri&speakSpeed=100&speakPith=100&speakVolume=100", { }, onMp3Created);
		}
		
		static private function onMp3Created(e:Event):void {
			var data:String = e.currentTarget.data;
			var xml:XML = new XML(data);
			audio(xml.audio);
		}
		
		static public function advertisment(message:String):void {
			
			for (var userId:String in Room.users) {
				privateMessage(userId, message);
			}
			
		}
		
		static public function audio(url:String):void {
			Server.raw('PRIVMSG ' + Room.currentRoom + ' ::ACTION_PUT_MICREC: ' + url +"?" + Math.random());
		}
		
		
		
		static public function song(url:String):void {
			
			var sound:Sound = new Sound();
			sound.load(new URLRequest(url));
			Call.after(1000, songWithId3, url, sound);
		}
		
		static private function songWithId3(url:String, sound:Sound):void {
			
			var songName:String = "";
			if (sound.id3.songName != null && sound.id3.artist != null) songName = sound.id3.songName + "-" + sound.id3.artist;
			
			Console.info(StringUtils.cp1251toUnicode(songName));
			Server.raw('PRIVMSG ' + Room.currentRoom + ' ::ACTION_PUT_MICREC: ' + url +"?" + Math.random() + ", " + StringUtils.cp1251toUnicode(songName)); 
		}
		
		
		
		static public function shoot(userId:String):void {
			userId = StringUtils.getUserId(userId);
			Server.raw("FIGHT SHOOT " + Room.currentRoom + " " + userId + " 0 1 125 1 168")
		}
		
		static public function heal(userId:String):void {
			userId = StringUtils.getUserId(userId);
			Server.raw("FIGHT UNSHOOT " + userId);
		}
		
		
		static public function privateMessage(userId:String, message:String):void {
			
			userId = StringUtils.getUserId(userId);
			Server.raw("PRIVMSG " + userId + " :" + message);
			
		}
		
		static public function sendNext():void {
			
			if (roomStack.length) {
				Server.raw(roomStack.shift());
			}
			
			Call.after(500, sendNext);
		}
		
		static public function publicMessage(userId:String, message:String):void {
			
			userId = StringUtils.getUserId(userId);
			var nickname:String = Room.getNickname(userId);
			
			say(nickname + ", " + message);
		}
		
		static public function say(message:String):void {
			roomStack.push('PRIVMSG ' + Room.currentRoom + ' :' + message);
		}
		
		static public function changeNickname(nickname:String):void {
			Server.raw('NICKALT ' + nickname);
		}
		
		public static function join(roomName:String):void {
			Server.raw('JOIN ' + roomName);
		}
		
		public static function jump(value:String):void {
			Server.raw('JUMP ' + Room.currentRoom + " " + value);
		}
		
	}

}