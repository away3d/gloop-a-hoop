package com.away3d.gloop.level
{
	import away3d.containers.Scene3D;
	import com.away3d.gloop.gameobjects.DefaultGameObject;
	
	import com.away3d.gloop.gameobjects.GameObject;
	
	import wck.World;

	public class Level
	{
		private var _scene : Scene3D;
		private var _world : World;
		
		private var _objects : Vector.<DefaultGameObject>;
		
		public function Level()
		{
			_scene = new Scene3D();
			_world = new World();
			_world.gravityY = 1;
		}
		
		public function add(object:DefaultGameObject):DefaultGameObject {
			_objects.push(object);
			if (object.physics) world.addChild(object.physics);
			if (object.mesh) scene.addChild(object.mesh);
			return object;
		}
		
		public function get scene() : Scene3D
		{
			return _scene;
		}
		
		public function get world() : World
		{
			return _world;
		}
	}
}