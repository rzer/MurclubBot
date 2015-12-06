package common {
	import controllers.Mafia;
	import controllers.Room;
	/**
	 * Игрок мафии
	 * @author rzer & reraider
	 */
	public class MafiaPlayer {
		
		public var role:String;
		public var userId:String;
		public var nickname:String;
		
		//Может ли ночью стрелять
		public var isGunner:Boolean = false;
		
		//Может ли дважды выбирать одного и того же персонажа
		public var canSelectTwoTimes:Boolean = false;
		
		//Выставлен ли на голосование
		public var inVoting:Boolean = true;
		
		//Проголосовал против
		public var vote:String = "";
		
		//Собрал голосов против себя
		public var numVotes:int = 0;
		
		//Полечил доктор
		public var isHealed:Boolean = false;
		
		//Пущена пуля мафии
		public var isKilled:Boolean = false;
		
		//Отравлен девушкой по вызову
		public var isPoisoned:Boolean = false;
		
		//Заблокирован боссом мафии
		public var isBlocked:Boolean = false;
		
		//Выбор предыдущей ночи (чтобы нельзя было выбирать одного и того же игрока две ночи подряд)
		public var lastNightVote:String = "";
		
		//Активная позитивная роль - чтобы вошёл комсомолец при первом убийстве
		public var isActiveCivilian:Boolean = false;
		
		public var isNeutral:Boolean = false;
		
		public function MafiaPlayer(userId:String, role:String) {
			this.role = role;
			this.userId = userId;
			this.isGunner = (role == Mafia.MAFIA);
			this.nickname = Room.getNickname(userId);
			this.canSelectTwoTimes = (role == Mafia.MIRROR || role == Mafia.OPER || role == Mafia.JUDGE || role == Mafia.JOURNALIST);
			this.isActiveCivilian  = (role == Mafia.DOCTOR || role == Mafia.OPER || role == Mafia.JUDGE || role == Mafia.JOURNALIST);
			this.isNeutral = (role == Mafia.MIRROR || role == Mafia.MANIAC);
		}
		
		public function startVoting():void {
			vote = "";
			numVotes = 0;
			inVoting = true;
			
		}
		
		public function clearBuffs():void {
			isKilled = false;
			isHealed = false;
			isPoisoned = false;
			isBlocked = false;
		}
		
		public function endVoting():void {
			inVoting = false;
		}
		
		public function isMafia(isMeeting:Boolean = false):Boolean {
			return (role == Mafia.BOSS || role == Mafia.MAFIA || role == Mafia.SLUT);
		}
		
	}

}