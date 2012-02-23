package com.away3d.gloop.gameobjects.events {
	import com.away3d.gloop.gameobjects.DefaultGameObject;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Martin Jonasson, m@grapefrukt.com
	 */
	public class GameObjectEvent extends Event {
		
		public static const LAUNCHER_CATCH_GLOOP:String = "gameobjectevent_launcher_catch_gloop";
		public static const LAUNCHER_FIRE_GLOOP	:String = "gameobjectevent_launcher_fire";
		
		public static const GLOOP_HIT_GOAL_WALL	:String = "gameobjectevent_gloop_hit_goal_wall";
		public static const GLOOP_LOST_MOMENTUM	:String = "gameobjectevent_gloop_lost_momentum";
		
		private var _gameObject:DefaultGameObject;
		
		public function GameObjectEvent(type:String, gameObject:DefaultGameObject) { 
			super(type, false, false);
			_gameObject = gameObject;
		} 
		
		public override function clone():Event { 
			return new GameObjectEvent(type, gameObject);
		} 
		
		public override function toString():String { 
			return formatToString("GameObjectEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get gameObject():DefaultGameObject {
			return _gameObject;
		}
		
	}
	
}