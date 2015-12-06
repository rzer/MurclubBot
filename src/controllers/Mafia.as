package controllers {
	import common.ArrayUtils;
	import common.MafiaPhrases;
	import common.MafiaPlayer;
	import elements.Console;
	import elements.Server;
	import simplify.Call;
	import simplify.ObjectEvent;
	import common.StringUtils;
	
	/**
	 * http://мафияспб.рф/how-to-play-mafia-peter.html
	 * @author rzer & reraider
	 */
	public class Mafia {
		
		//Промежутки времени между действиями
		public static const TIME_TO_JOIN:int = 90000;
		public static const TIME_TO_NEXT_GAME:int = 30000;
		public static const TIME_INTERVAL:int = 30000;
		public static const TIME_DAY:int = 120000;
		public static const TIME_DESICION:int = 70000;
		
		//Роли
		public static const CIVILIAN:String = "Мирный житель";
		public static const MAFIA:String = "Мафия";
		public static const BOSS:String = "Босс мафии";
		public static const DOCTOR:String = "Доктор";
		public static const OPER:String = "Комиссар";
		public static const MANIAC:String = "Маньяк";
		public static const SLUT:String = "Путана";
		public static const MIRROR:String = "Зеркало";
		public static const WEREWOLF:String = "Оборотень";
		public static const JOURNALIST:String = "Журналист";
		public static const KOMSOMOL:String = "Комсомолец";
		public static const JUDGE:String = "Судья";
		
		//Заменяемые роли
		public static const JUDGE_OR_OPER:String = "judge_or_oper";
		public static const BOSS_OR_SLUT:String = "boss_or_slut";
		public static const MANIAC_OR_MIRROR:String = "maniac_or_miror";
		
		//Команды пользователей
		public static var JOIN_WORD:String = "-in";
		public static var VOTE_WORD:String = "-v";
		public static var ALIVE_WORD:String = "-a";
		
		//Минимальное максимальное число игроков
		public static const MIN_PLAYERS:int = 4;
		public static const MAX_PLAYERS:int = 12;
		
		//Наборы ролей для разного количества игроков
		public static var roleStack:Array;
		
		//Заявки перед игрой, кто играет
		public static var requests:Array = [];
		
		//Игроки с их ролями
		public static var players:Array = [];
		public static var playersById:Object = { };
		
		//Стадии игры
		public static const DUMMY:int = 0;
		public static const JOIN:int = 1;
		public static const INIT_GAME:int = 2;
		public static const GET_ROLES:int = 3;
		public static const MEET_MAFIA:int = 4;
		public static const MORNING:int = 5;
		public static const DAY:int = 6;
		public static const NIGHT:int = 7;
		public static const DAY_VOTING:int = 8;
		public static const NIGHT_VOTING:int = 9;
		public static const DAY_VOTING_RESULTS:int = 10;
		
		//Текущая стадия
		public static var step:int = 0;
		
		//Сколько дней и ночей прожито
		public static var currentDay:int = 0;
		
		//Последовательность хода ролей ночью
		public static var nightSequence:Array = [MAFIA, BOSS, SLUT, MANIAC, OPER, DOCTOR, JUDGE, MIRROR, JOURNALIST];
		
		//Текущий ночной ход
		public static var nightTurn:int = -1;
		public static var activeRole:String = "";
		
		//Дополнительное ли голосование (Когда ничья на голосовании)
		public static var isAdditionalVoting:Boolean = false;
		static public var isStarted:Boolean = false;
		static private var mafiaList:String = "";
		
		static private var numGunners:int = 0;
		static private var numGunnersVotes:int = 0;
		static private var numVotes:int = 0;
		
		
		public static function init():void {
			
			//Роли на игроков
			roleStack = [
				[],	[], [],
				[MAFIA, CIVILIAN, CIVILIAN],
				[MAFIA, WEREWOLF, CIVILIAN, DOCTOR],
				[MAFIA, WEREWOLF, CIVILIAN, DOCTOR, JOURNALIST],
				[MAFIA, MAFIA, CIVILIAN, CIVILIAN, DOCTOR, JOURNALIST],
				[MAFIA, MAFIA, CIVILIAN, CIVILIAN, DOCTOR, JOURNALIST, MIRROR],
				[MAFIA, MAFIA, WEREWOLF, CIVILIAN, KOMSOMOL, DOCTOR, JOURNALIST, JUDGE_OR_OPER],
				[MAFIA, MAFIA, BOSS_OR_SLUT, CIVILIAN, CIVILIAN, KOMSOMOL, DOCTOR, JOURNALIST, JUDGE_OR_OPER],
				[MAFIA, MAFIA, BOSS_OR_SLUT, CIVILIAN, CIVILIAN, KOMSOMOL, DOCTOR, JOURNALIST, JUDGE_OR_OPER, MANIAC],
				[MAFIA, MAFIA, BOSS_OR_SLUT, WEREWOLF, CIVILIAN, CIVILIAN, KOMSOMOL, DOCTOR, JOURNALIST, JUDGE_OR_OPER, MANIAC_OR_MIRROR],
				[MAFIA, MAFIA, BOSS_OR_SLUT, WEREWOLF, CIVILIAN, CIVILIAN, KOMSOMOL, DOCTOR, JOURNALIST, JUDGE, OPER, MANIAC_OR_MIRROR],
			];
			
			Console.registerCommand("/startMafia", start);
			Console.registerCommand("/stopMafia", stop);
			
			Console.info("Mafia:");
			Console.tip("/startMafia, /stopMafia - запускаем/останавливаем мафию");
			
		}
		
		public static function start():void {
			
			if (isStarted) return;
			isStarted = true;
			

			Console.info("Mafia bot активирован");
			You.say("Mafia bot активирован");
			
			MafiaPhrases.init();
			
			Server.bind("PRIVMSG", onMessage);
			
			Server.bind("NICKALT", onLeaveRoom); 
			Server.bind("PART", onLeaveRoom); 
			Server.bind("QUIT", onLeaveRoom); 
			
			Call.after(3000, startJoin);
			
		}
		
		static private function onMessage(e:ObjectEvent):void {
			
			
			var temp:Array;
			var nickname2:String = "";
			var nickname:String = "";
			var victim:MafiaPlayer;
			var activePlayer:MafiaPlayer;
			var targetPlayer:MafiaPlayer;
			var targetPlayer2:MafiaPlayer;
			var voter:MafiaPlayer;
			var target:String;
			
			
			var phrase:String = StringUtils.getPhrase(e.data);
			var userId:String = StringUtils.extractUserId(e.data[0]);
			
			if (phrase == ALIVE_WORD) {
				
				target = e.data[2];
				if (target == Login.userId) {
					inGame(userId);
				}else {
					inGame();
				}
				
				
				return;
			}
			
			if (step == DUMMY) return;
			
			if (step == JOIN) {
				
				if (phrase != JOIN_WORD) return;
				
				//D1zz бех мафии живёт нынче
				/*if (userId == "m5878943") {
					You.publicMessage(userId, " Прости, но мафия не для тебя!");
					return;
				}*/
				
				if (requests.indexOf(userId) == -1) {
					
					requests.push(userId);
					You.publicMessage(userId, "ты в игре! Записалось: " + requests.length);
					
					//Набралось максимальное число участников - раздаём роли
					if (requests.length == MAX_PLAYERS) initGame();
				}
			}else if (step == DAY_VOTING) {
				
				Console.error(phrase);
				
				temp = phrase.split(" ");
				if (temp.length != 2 || temp[0] != VOTE_WORD) return;
				
				voter = getPlayer(userId);
				
				if (voter == null) return;
				
				if (voter.vote != "") {
					You.publicMessage(userId, "Вы уже голосовали в этом раунде!");
					return;
				}
				
				var index:int = temp[1];
				victim = players[index];
				
				if (victim == null) {
					You.publicMessage(userId, "Игрок с номером " +  index + "не найден");
					return;
				}
				
				nickname = victim.nickname;
				
				if (!victim.inVoting) {
					You.publicMessage(userId, "Против этого игрокaа сейчас голосовать нельзя");
					return;
				}
				
				victim.numVotes++;
				voter.vote = victim.userId;
				
				You.publicMessage(userId, "твой голос засчитан! Против " + nickname + " проголосовало " + victim.numVotes + " человек");
				
				numVotes++;
				
				//Все игроки проголосовали - нечего ждать
				if (numVotes == players.length) {
					endDayVoting();
				}
				
			}else if (step == NIGHT) {
				
				if (activeRole == MAFIA) {
					dealMafia(e);
					return;
				}
								
				//Только в личку
				target = e.data[2];
				if (target != Login.userId) return;
				
				//Не голосует а пишет ерунду
				temp = phrase.split(" ");
				if (temp.length < 2 || temp.length > 3 || temp[0] != VOTE_WORD) return;
				
				activePlayer = getPlayer(userId);
				
				//Игрок заблокирован команды не принимаем
				if (activePlayer == null || activePlayer.isBlocked) return;
				
				index = temp[1];
				targetPlayer = players[index];
				
				if (targetPlayer == null) {
					You.privateMessage(activePlayer.userId, "Игрок с номером " + index + " не найден");
					return;
				}
				
				nickname = targetPlayer.nickname;
				
				//Error #1009: Cannot access a property or method of a null object reference.
				if (!activePlayer.canSelectTwoTimes && activePlayer.lastNightVote == targetPlayer.userId) {
					You.privateMessage(activePlayer.userId, "Нельзя ночью выбирать одного и того же персонажа дважды");
					return;
				}
				
				activePlayer.lastNightVote = targetPlayer.userId;
				
				if (activeRole == DOCTOR) targetPlayer.isHealed = true;
				else if (activeRole == SLUT) targetPlayer.isPoisoned = true;
				else if (activeRole == BOSS) targetPlayer.isBlocked = true;
				else if (activeRole == MANIAC) targetPlayer.isKilled = true;
				else if (activeRole == JUDGE) targetPlayer.isKilled = true;
				else if (activeRole == OPER) {
					
					if (targetPlayer.isMafia()) {
						You.privateMessage(activePlayer.userId, "Это плохой персонаж!");
					}else {
						You.privateMessage(activePlayer.userId, "Вы проверили игрока и не нашли ничего подозрительного.");
					}
					
				}else if (activeRole == MIRROR) {
					
					//Перенаправляем поток скилов на другого персонажа
					
					targetPlayer.isHealed = activePlayer.isHealed;
					targetPlayer.isPoisoned = activePlayer.isPoisoned;
					targetPlayer.isKilled = activePlayer.isKilled;
					
					targetPlayer.isHealed = false;
					targetPlayer.isPoisoned = false;
					targetPlayer.isKilled = false;
					
				}else if (activeRole == JOURNALIST) {
					
					//Сравнение двух игроков
					var index2:int = temp[2];
					targetPlayer2 = players[index2];
					
					if (targetPlayer2 == null) {
						You.privateMessage(activePlayer.userId, "Игрок с номером " + index2 + " не найден");
						return;
					}
					
					nickname2 = targetPlayer2.nickname;
					
					if (targetPlayer.role == MIRROR || targetPlayer2.role == MIRROR) {
						You.privateMessage(userId, "Они одинаковые");
					}else if (targetPlayer.role == MANIAC || targetPlayer2.role == MANIAC) {
						You.privateMessage(userId, "Они разные");
					}else if (targetPlayer.isMafia() != targetPlayer2.isMafia()) {
						You.privateMessage(userId, "Они разные");
					}else {
						You.privateMessage(userId, "Они одинаковые");
					}
				}
				
				You.privateMessage(userId, "Выбор сделан, можете спать");
				nextNight();
			}
			
		}
		
		static private function getPlayerByRole(role:String):MafiaPlayer {
			
			for (var i:int = 0; i < players.length; i++) {
				var player:MafiaPlayer = players[i];
				if (player.role == role) return player;
			}
			
			return null;
		}
		
		static private function getPlayerByName(nickname:String):MafiaPlayer {
			
			for (var i:int = 0; i < players.length; i++) {
				var player:MafiaPlayer = players[i];
				if (player.nickname == nickname) return player;
			}
			return null;
		}
		
		
		static private function getPlayer(userId:String):MafiaPlayer {
			return (playersById[userId]) ? playersById[userId] : null;
		}
		
		static private function canPlayerVote(userId:String):Boolean {
			
			for (var i:int = 0; i < players.length; i++) {
				var player:MafiaPlayer = players[i];
				if (player.vote == "") return true;
			}
			
			return false;
		}
		
		static private function startJoin():void {
			
			requests = [];
			players = [];
			playersById = { };
			
			step = JOIN;
			You.say("В течение минуты объявлется набор участников для игры в Мафию. Чтобы участвовать набери " + JOIN_WORD + ". Во время игры выходить из комнаты и менять ник нельзя!");
			Call.after(TIME_TO_JOIN, initGame);
		}
		
		static private function initGame():void {
			
			Call.forget(initGame);
			
			step = INIT_GAME;
			
			You.say("Запись закончена. Чтобы получить список игроков в любой момент напишите " + ALIVE_WORD);
			
			//Игроков не набралось
			
			if (requests.length < MIN_PLAYERS) {
				You.say("Нужно минимум " + MIN_PLAYERS + " участников, чтобы начать игру :(");
				Call.after(TIME_TO_NEXT_GAME, startJoin);
				
			//Набрались - переходим к раздаче ролей
			}else {
				You.say(MafiaPhrases.getPhrase("getRoles"));
				getRoles();
			}
			
			
			inGame();
		}
		
		public static function inGame(userId:String = ""):void {
			
			var nicks:Array = [];
			
			for (var i:int = 0; i < players.length; i++) {
				var player:MafiaPlayer = players[i];
				nicks.push("[" + i + "] " + player.nickname);
			}
			
			if (nicks.length > 0) {
				
				if (userId != "") {
					You.privateMessage(userId, "В игре: " + nicks.join(", "));
				}else{
					You.say("В игре: " + nicks.join(", "));
				}
			}
		}
		
		
		
		private static function getRoles():void {
			
			step = GET_ROLES;
			
			var playerList:Array = ArrayUtils.shuffle(requests);
			
			var roles:Array = roleStack[playerList.length];
			roles = roles.concat();
			
			
			for (var i:int = 0; i < roles.length; i++) {
				
				if (roles[i] == JUDGE_OR_OPER) roles[i] = ((Math.random() > 0.5) ? JUDGE : OPER);
				if (roles[i] == BOSS_OR_SLUT) roles[i] = ((Math.random() > 0.5) ? BOSS : SLUT);
				if (roles[i] == MANIAC_OR_MIRROR) roles[i] = ((Math.random() > 0.5) ? MANIAC : MIRROR);
				
				var userId:String = playerList[i];
				var role:String = roles[i];
				
				var player:MafiaPlayer = new MafiaPlayer(userId, role);
				players.push(player);
				playersById[userId] = player;
				
				You.privateMessage(userId, "Ваша роль: " + role);
				
			}
			
			players = ArrayUtils.shuffle(players);
			
			You.say("Роли на эту игру: " + roles.join(", "));
			
			Call.after(TIME_INTERVAL, meetMafia);
		}
		
		static private function meetMafia():void {
			
			step = MEET_MAFIA;
			You.say(MafiaPhrases.getPhrase("meetMafia"));
			
			//Рассылаем всем мафиози сообщения
			var list:Array = getMafia();
			var nicks:Array = [];
			
			for (var i:int = 0; i < list.length; i++) {
				nicks.push(Room.getNickname(list[i]));
			}
			
			mafiaList = nicks.join(", ");
			
			var message:String = MafiaPhrases.getPhrase("inroduceMafia") + " " + mafiaList;
			
			for (i = 0; i < list.length; i++) {
				var userId:String = list[i];
				You.privateMessage(userId, message);
			}
			
			Call.after(TIME_INTERVAL, startGame);
 		}
		
		static private function startGame():void {
			
			You.say(MafiaPhrases.getPhrase("gameStarted"));
			
			currentDay = 0;
			startDay();
		}
		
		static private function startDay():void {
			
			currentDay++;
			step = DAY;
			
			You.say("Наступил " + currentDay + " день. " + MafiaPhrases.getPhrase("day5min"));
			
			//Очищаем голоса
			for (var i:int = 0; i < players.length; i++) {
				var player:MafiaPlayer = players[i];
				player.clearBuffs();
				player.startVoting();
			}
			
			isAdditionalVoting = false;
			
			Call.after(TIME_DAY, startDayVoting);
		}
		
		static private function startDayVoting():void {
			
			numVotes = 0;
			step = DAY_VOTING;
			You.say(MafiaPhrases.getPhrase("dayVoting"));
			
			inGame();
			
			Call.after(TIME_DESICION, endDayVoting);
		}
		
		static private function endDayVoting():void {
			
			Call.forget(endDayVoting);
			
			var player:MafiaPlayer;
			
			You.say("Голосование завершено");
			
			
			step = DAY_VOTING_RESULTS;
			
			var maxVotes:int = 1;
			var victims:Array = [];
			var victimsNames:Array = [];
			
			for (var i:int = 0; i < players.length; i++) {
				
				player = players[i];
				player.endVoting();
				
				if (maxVotes < player.numVotes) {
					victims = [];
					victimsNames = [];
					maxVotes = player.numVotes;
				}
				
				if (maxVotes == player.numVotes) {
					victims.push(player);
					victimsNames.push(player.nickname);
				}
				
			}
			
			if (victims.length == 0 || (isAdditionalVoting && victims.length > 1)) {
				
				if (victims.length > 1) {
					You.say("Город так и не определился, кого из этих ребят убить. Продолжаем полным составом!");
				}else {
					You.say("Ни одна кандидатура не была выставлена. Продолжаем игру полным составом!");
				}
				
				Call.after(TIME_INTERVAL, startNight);
				
			}else if(victims.length == 1) {
				
				kill(victims[0].userId);
				
				Call.after(10000, startNight);
				
			}else{
				
				isAdditionalVoting = true;
				You.say("В голосовании ничья. Объявляется дополнительный раунд голосования. Голосовать можно против: " + victimsNames.join(", "));
				
				//Голосовать только против жертв
				for (i = 0; i < victims.length; i++) {
					player = victims[i];
					player.startVoting();
				}
				
				//Все могут голосовать
				for (i = 0; i < players.length; i++) {
					player = players[i];
					player.vote = "";
				}
				
				startDayVoting();
			}
			
		}
		
		static private function startNight():void {
			step = NIGHT;
			nightTurn = -1;
			You.say(MafiaPhrases.getPhrase("startNight"));
			
			Call.after(TIME_INTERVAL, nextNight);
		}
		
		static private function nextNight():void {
			
			//Мафия голосовала
			if (activeRole == MAFIA) {
				
				var maxVotes:int = 1;
				var victims:Array = [];
				
				for (var i:int = 0; i < players.length; i++) {
					
					player = players[i];
					player.endVoting();
					
					if (maxVotes < player.numVotes) {
						victims = [];
						maxVotes = player.numVotes;
					}
					
					if (maxVotes == player.numVotes) {
						victims.push(player);
					}
					
				}
				
				if (victims.length == 1) {
					var victim:MafiaPlayer = victims[0];
					victim.isKilled = true;
				}
				
			}
			
			Call.forget(nextNight);
			nightTurn++;
			
			
			//Все сходили
			if (nightTurn >= nightSequence.length) {
				startMorning();
				return;
			}
			
			//Сейчас ходит
			activeRole = nightSequence[nightTurn];
			
			var activePlayer:MafiaPlayer = getPlayerByRole(activeRole);
			
			//Игроков с такой ролью нет
			if (activePlayer == null) {
				nextNight();
				return;
			}
			
			//15 секунд у игрока чтобы выполнить своё предназначение
			You.say("Просыпается " + activeRole + "....");
			
			if (activePlayer.isBlocked) {
				You.privateMessage(activePlayer.userId, "Вы заблокированы. Воспользоваться своей активной ролью в этот ход не получится");
				Call.after(5000 + Math.random() * 20000, nextNight);
			}else {
				
				if (activeRole == MAFIA) {
					
					numGunnersVotes = 0;
					numGunners = 0;
					
					for (i = 0; i < players.length; i++) {
						var player:MafiaPlayer = players[i];
						player.startVoting();
						
						if (player.isGunner) {
							numGunners++;
							You.privateMessage(player.userId, "Мафия голосует!");
							inGame(player.userId);
						}
					}
					
				}else {
					You.privateMessage(activePlayer.userId, "Ваш ход, " + activePlayer.role + "!");
					inGame(activePlayer.userId);
				}
				
				Call.after(TIME_DESICION, nextNight);
			}
			
		}
		
		
		static private function startMorning():void {
			
			step = MORNING;
			You.say(MafiaPhrases.getPhrase("startMorning"));
			
			//Убиваем всех, кто ночью провинился
			var kills:Object = { };
			
			for (var i:int = 0; i < players.length; i++) {
				
				var player:MafiaPlayer = players[i];
				if (player.isPoisoned) kills[player.userId] = true;
				if (player.isKilled && !player.isHealed) kills[player.userId] = true;
				
				//Доктор вылечил - похвалим его
				if (player.isKilled && player.isHealed && !player.isPoisoned) {
					You.say(MafiaPhrases.getPhrase("bestDoctor"));
				}
			}
			
			var noVictims:Boolean = true;
			
			for (var userId:String in kills) {
				kill(userId);
				noVictims = false;
			}
			
			//Жертв после ночи нет - странно)
			if (noVictims) {
				You.say(MafiaPhrases.getPhrase("noVictims"));
			}
			
			Call.after(TIME_INTERVAL, startDay);
		}
		
		//Убийство человека
		static private function kill(userId:String):void {
			
			var player:MafiaPlayer = getPlayer(userId);
			
			You.publicMessage(userId, MafiaPhrases.getPhrase("youKilled"));
			You.say("У игрока " + player.nickname + " была роль: " + player.role);
			
			var anIndex:int = players.indexOf(player);
			
			if (anIndex != -1) {
				players.splice(anIndex, 1);
			}
			
			delete playersById[userId];
			
			if (player.isGunner) {
				
				var werewolf:MafiaPlayer = getPlayerByRole(WEREWOLF);
				
				
				//Оборотень входит в игру - рассылаем всем сообщения о пополнении мафии
				if (werewolf != null) {
					
					You.say(MafiaPhrases.getPhrase("werewolfHere"));
					
					werewolf.isGunner = true;
					werewolf.role = MAFIA;
					
					var list:Array = getMafia();
					
					var nicks:Array = [];
					
					for (var i:int = 0; i < list.length; i++) {
						nicks.push(Room.getNickname(list[i]));
					}
					
					var message:String = MafiaPhrases.getPhrase("werewolfInGame") + " " + nicks.join(", ");
					
					for (i = 0; i < list.length; i++) {
						var userId:String = list[i];
						You.privateMessage(userId, message);
					}
				}
			}else if (player.isActiveCivilian) {
				
				var komsomol:MafiaPlayer = getPlayerByRole(KOMSOMOL);
				
				//Комсомолец заменяет первую добрую активную роль
				if (komsomol != null) {
					
					You.say("Комсомолец теперь исполняет эту роль");
					
					komsomol.role = player.role;
					komsomol.isActiveCivilian = true;
					
					You.privateMessage(komsomol.userId, "У вас новая роль: " + komsomol.role);
				}
			}
			
			
			
			Call.forget(checkVictory);
			Call.after(1000,checkVictory);
		}
		
		//Проверим закончена ли игра
		static private function checkVictory():void {
			
			//TODO: fix сдох до распределения ролей сменив ник
			if (players.length == 0) return;
			
			if (players.length == 0) {
				You.say("В городе больше нет людей - ничья");
				return gameOver();
			}
			
			if (players.length == 1) {
				var player:MafiaPlayer = players[0];
				You.say("Победил " + player.nickname + "! У него была роль: " + player.role);
				return gameOver();
			}
			var numMafia:int = 0
			var numNeutrals:int = 0;
			var numCitizens:int = 0;
			
			for (var i:int = 0; i < players.length; i++) {
				player = players[i];
				if (player.isMafia()) numMafia++;
				if (player.isNeutral) numNeutrals++;
				if (!player.isNeutral && !player.isMafia()) numCitizens++;
			}
			
			if (numMafia > numNeutrals + numCitizens) {
				You.say("Конец игры! Победила мафия! В неё входили: " + mafiaList);
				return gameOver();
			}
			
			if (numNeutrals == 0 && numMafia == 0) {
				You.say("Конец игры! В городе остались только мирные жители!");
				return gameOver();
			}
			
		}
		
		static private function gameOver():void {
			step = DUMMY;
			forgetAll();
			Call.after(TIME_TO_NEXT_GAME, startJoin);
		}
		
		//Возвращает список id людей мафии
		static private function getMafia():Array {
			var list:Array = [];
			
			for (var i:int = 0; i < players.length; i++) {
				var player:MafiaPlayer = players[i];
				
				if (player.isMafia()) list.push(player.userId);
			}
			
			return list;
		}
		
		//Голосование мафии
		static private function dealMafia(e:ObjectEvent):void {
			
			var victim:MafiaPlayer;
			var voter:MafiaPlayer;
			var nickname:String;
			
			var phrase:String = StringUtils.getPhrase(e.data);
			var userId:String = StringUtils.extractUserId(e.data[0]);
			
			
			var temp:Array = phrase.split(" ");
			if (temp.length != 2 || temp[0] != VOTE_WORD) return;
			
			voter = getPlayer(userId);
			
			if (voter == null) return;
			
			if (voter.vote != "") {
				You.privateMessage(userId, "Вы уже голосовали ночью!");
				return;
			}
			
			var index:int = temp[1];
			victim = players[index];
			
			
			if (victim == null) {
				You.privateMessage(userId, "Игрок с именем " + index + " не найден");
				return;
			}
			
			nickname = victim.nickname;
			
			if (!victim.inVoting) {
				You.privateMessage(userId, "Против этого игрока сейчас голосовать нельзя");
				return;
			}
			
			victim.numVotes++;
			voter.vote = victim.userId;
			
			You.privateMessage(userId, "твой голос засчитан! Против " + nickname + " проголосовало " + victim.numVotes + " человек");
			
			numGunnersVotes++;
			
			if (numGunners == numGunnersVotes) {
				nextNight();
			}
		}
		
		public static function forgetAll():void {
			Call.forget(startNight);
			Call.forget(startJoin);
			Call.forget(initGame);
			Call.forget(meetMafia);
			Call.forget(startDayVoting);
			Call.forget(startGame);
			Call.forget(endDayVoting);
			Call.forget(nextNight);
			Call.forget(startDay);
		}
		
		public static function stop():void {
			
			if (!isStarted) return;
			isStarted = false;
			
			Console.info("Mafia bot деактивирован");
			You.say("Mafia bot деактивирован");
			
			forgetAll();
			
			
			Server.unbind("PRIVMSG", onMessage);
			
			Server.unbind("NICKALT", onLeaveRoom); 
			Server.unbind("PART", onLeaveRoom); 
			Server.unbind("QUIT", onLeaveRoom); 
		}
		
		static private function onLeaveRoom(e:ObjectEvent):void {
			
			//:m1830204!M@5.18.176.24 PART #Disneyland :Part выход
			
			var userId:String = StringUtils.extractUserId(e.data[0]);
			
			var player:MafiaPlayer = getPlayer(userId);
			
			if (player != null) {
				
				You.say(player.nickname + " выбывает из игры");
				kill(player.userId);
				
				//Игрок вышел во время голосования - считать его убитым решением большинства
				if (step == DAY_VOTING && player.inVoting) {
					step = DAY_VOTING_RESULTS;
					Call.forget(endDayVoting);
					Call.after(10000, startNight);
				}
				
			}
			
		}
		

		
	}
	
	

}