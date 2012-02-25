package com.away3d.gloop.gameobjects.components {
	import Box2DAS.Common.V2;
	import com.away3d.gloop.gameobjects.DefaultGameObject;
	import com.away3d.gloop.gameobjects.events.GameObjectEvent;
	import com.away3d.gloop.gameobjects.Gloop;
	import com.away3d.gloop.gameobjects.hoops.GlueHoop;
	import com.away3d.gloop.Settings;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Martin Jonasson, m@grapefrukt.com
	 */
	public class GloopLauncherComponent {
		
		private var _gloop : Gloop;		
		private var _aim : Point;
		private var _fired : Boolean = false;
		private var _gameObject:DefaultGameObject;
		
		public function GloopLauncherComponent(gameObject:DefaultGameObject) {
			_gameObject = gameObject;
			_aim = new Point;
		}
		
		public function reset():void {
			_fired = false;
		}
		
		public function catchGloop(gloop:Gloop):void {
			if (_fired) return;	// don't catch the gloop if we've fired once already
			_gloop = gloop; // catch the gloop
			_gameObject.dispatchEvent(new GameObjectEvent(GameObjectEvent.LAUNCHER_CATCH_GLOOP, _gameObject));
		}
		
		public function onDragUpdate(mouseX:Number, mouseY:Number):void {
			if (_fired) return; // if hoop has fired, disable movement
			if (!_gloop) return;
			
			var hoopPos:V2 = _gameObject.physics.b2body.GetPosition();			
			_aim.x = hoopPos.x * Settings.PHYSICS_SCALE - mouseX;
			_aim.y = hoopPos.y * Settings.PHYSICS_SCALE - mouseY;
			
			_gameObject.physics.b2body.SetTransform(hoopPos, -Math.atan2(_aim.x, _aim.y));
			_gameObject.physics.updateBodyMatrix(null);
		}
		
		public function onDragEnd(mouseX:Number, mouseY:Number):void {
			if (!_gloop) return;
			if (_aim.length < Settings.LAUNCHER_POWER_MIN) return;
			launch();
		}
		
		public function launch() : void
		{
			if (!_gloop)
				return; // can't fire if not holding the gloop
			
			var power:Number = Math.min(_aim.length, Settings.LAUNCHER_POWER_MAX);
			power = (power - Settings.LAUNCHER_POWER_MIN) * Settings.LAUNCHER_POWER_SCALE;
				
			var impulse : V2 = _gameObject.physics.b2body.GetWorldVector(new V2(0, -power));
			_gloop.physics.b2body.ApplyImpulse(impulse, _gameObject.physics.b2body.GetWorldCenter());
			
			_gloop.onLaunch();
			
			_gloop = null; // release the gloop
			_fired = true;
			
			_gameObject.dispatchEvent(new GameObjectEvent(GameObjectEvent.LAUNCHER_FIRE_GLOOP, _gameObject));
		}
		
		public function update(dt:Number):void {
			if (!_gloop) return;
			_gloop.physics.b2body.SetLinearVelocity(new V2(0, 0)); // kill incident velocity
			_gloop.physics.b2body.SetTransform(_gameObject.physics.b2body.GetPosition().clone(), 0); // position gloop on top of launcher
		}
		
		public function get gloop():Gloop {
			return _gloop;
		}
		
		public function get aim():Point {
			return _aim;
		}
		
	}

}