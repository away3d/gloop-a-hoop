package com.away3d.gloop.level
{

	import away3d.containers.Scene3D;
	import away3d.entities.Mesh;
	
	import com.away3d.gloop.Settings;
	import com.away3d.gloop.events.GameEvent;
	import com.away3d.gloop.gameobjects.Button;
	import com.away3d.gloop.gameobjects.DefaultGameObject;
	import com.away3d.gloop.gameobjects.Gloop;
	import com.away3d.gloop.gameobjects.IButtonControllable;
	import com.away3d.gloop.gameobjects.events.GameObjectEvent;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import wck.World;

	public class Level extends EventDispatcher
	{
		private var _scene : Scene3D;
		private var _world : World;
		
		private var _spawn_point :Point;
		private var _all_objects : Vector.<DefaultGameObject>;
		
		private var _buttons : Vector.<Button>;
		private var _btn_controllables : Vector.<IButtonControllable>;
		
		private var _splattables : Vector.<Mesh>;
		
		private var _mode:Boolean = EDIT_MODE;

		private var _dimensionsMin:Vector3D = new Vector3D( -350, -350, 0.001 ); // TODO: set these values from external data
		private var _dimensionsMax:Vector3D = new Vector3D( 350, 350, 3.5 );
		
		public static const EDIT_MODE:Boolean = false;
		public static const PLAY_MODE:Boolean = true;
		
		public function Level()
		{
			_scene = new Scene3D();
			_world = new World();
			_world.timeStep = Settings.PHYSICS_TIME_STEP;
			_world.velocityIterations = Settings.PHYSICS_VELOCITY_ITERATIONS;
			_world.positionIterations = Settings.PHYSICS_POSITION_ITERATIONS;
			trace( "grav: " + Settings.PHYSICS_GRAVITY_Y );
			_world.gravityY = Settings.PHYSICS_GRAVITY_Y;
			_spawn_point = new Point();
			_all_objects = new Vector.<DefaultGameObject>();
			_btn_controllables = new Vector.<IButtonControllable>();
			_buttons = new Vector.<Button>();
			_splattables = new Vector.<Mesh>;
		}
		
		public function setMode(value:Boolean, force:Boolean = false):void {
			if (!force && value == _mode) return;
			
			trace("Level, set mode: " + (value ? "play" : "edit"));
			_mode = value;
			for each(var object:DefaultGameObject in _all_objects) {
				object.setMode(value);
			}
		}
		
		public function get spawnPoint() : Point
		{
			return _spawn_point;
		}
		
		public function get scene() : Scene3D
		{
			return _scene;
		}
		
		public function get world() : World
		{
			return _world;
		}		
		
		public function get splattableMeshes() : Vector.<Mesh>
		{
			return _splattables;
		}
		
		public function get objects():Vector.<DefaultGameObject> {
			return _all_objects;
		}
		
		public function add(object:DefaultGameObject):DefaultGameObject {
			_all_objects.push(object);
			if (object.physics) world.addChild(object.physics);
			if (object.meshComponent) scene.addChild(object.meshComponent.mesh);

			if (object is Button) {
				_buttons.push(Button(object));
			}
			else if (object is IButtonControllable) {
				_btn_controllables.push(IButtonControllable(object));
			}
			
			// Special cases for Gloop
			if (object is Gloop) {
				var gloop : Gloop = Gloop(object);
				
				_scene.addChild(gloop.traceComponent.pathTracer);
			}

			object.addEventListener(GameObjectEvent.LAUNCHER_CATCH_GLOOP, onLauncherCatchGloop);
			object.addEventListener(GameObjectEvent.LAUNCHER_FIRE_GLOOP, onLauncherFireGloop);
			object.addEventListener(GameObjectEvent.GLOOP_HIT_GOAL_WALL, onHitGoalWall);
			object.addEventListener(GameObjectEvent.GLOOP_LOST_MOMENTUM, onGloopLostMomentum);
			object.addEventListener(GameObjectEvent.GLOOP_COLLECT_STAR, onGloopCollectStar);

			return object;
		}

		public function setup() : void
		{
			var btn : Button;

			for each (btn in _buttons) {
				var i : uint;

				for (i=0; i<_btn_controllables.length; i++) {
					if (_btn_controllables[i].buttonGroup == btn.buttonGroup)
						btn.addControllable(_btn_controllables[i]);
				}
			}
		}


		public function update() : void
		{
			var i : uint;

			for (i=0; i<_all_objects.length; i++) {
				_all_objects[i].update(1);
			}
		}


		public function dispose() : void
		{
			var obj : DefaultGameObject;
			
			while (obj = _all_objects.pop()) {
				if (obj.meshComponent && obj.meshComponent.mesh && obj.meshComponent.mesh.parent)
					obj.meshComponent.mesh.parent.removeChild(obj.meshComponent.mesh);

				if (obj.physics && obj.physics.parent){
					obj.physics.parent.removeChild(obj.physics);
					obj.physics.destroy();
				}

				obj.removeEventListener(GameObjectEvent.LAUNCHER_CATCH_GLOOP, onLauncherCatchGloop);
				obj.removeEventListener(GameObjectEvent.LAUNCHER_FIRE_GLOOP, onLauncherFireGloop);
				obj.removeEventListener(GameObjectEvent.GLOOP_HIT_GOAL_WALL, onHitGoalWall);
				obj.removeEventListener(GameObjectEvent.GLOOP_LOST_MOMENTUM, onGloopLostMomentum);
					
				obj.dispose();
			}			
		}

		/**
		 * Resets the level to its "pre-play" state, player edits are maintaned, but any toggled items are reset, launchers reloaded and so on
		 */
		public function reset():void {
			for each(var object:DefaultGameObject in _all_objects) {
				object.reset();
			}
			setMode(Level.EDIT_MODE, true);
		}


		private function win() : void
		{
			dispatchEvent(new GameEvent(GameEvent.LEVEL_WIN));
		}


		private function lose() : void
		{
			dispatchEvent(new GameEvent(GameEvent.LEVEL_LOSE));
		}
		
		private function onLauncherCatchGloop(e:GameObjectEvent):void {
			setMode(Level.EDIT_MODE);
		}
		
		private function onLauncherFireGloop(e:GameObjectEvent):void {
			setMode(Level.PLAY_MODE);
		}
		
		private function onHitGoalWall(e:GameObjectEvent):void {
			win();
		}
		
		private function onGloopLostMomentum(e:GameObjectEvent):void {
			lose();
		}
		
		private function onGloopCollectStar(e:GameObjectEvent):void {
			dispatchEvent(new GameEvent(GameEvent.LEVEL_STAR_COLLECT));
		}

		public function get dimensionsMin():Vector3D {
			return _dimensionsMin;
		}

		public function get dimensionsMax():Vector3D {
			return _dimensionsMax;
		}

		public function set dimensionsMin( value:Vector3D ):void {
			_dimensionsMin = value;
		}

		public function set dimensionsMax( value:Vector3D ):void {
			_dimensionsMax = value;
		}
	}
}