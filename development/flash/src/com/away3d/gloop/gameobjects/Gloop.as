package com.away3d.gloop.gameobjects
{

	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.SphereGeometry;
	import Box2DAS.Common.V2;
	
	import com.away3d.gloop.gameobjects.components.MeshComponent;
	import com.away3d.gloop.gameobjects.components.SplatComponent;
	import com.away3d.gloop.Settings;

	public class Gloop extends DefaultGameObject
	{
		private var _splat:SplatComponent;
		private var _spawnX:Number;
		private var _spawnY:Number;
		
		public function Gloop(spawnX:Number, spawnY:Number) {
			super();

			_spawnX = spawnX;
			_spawnY = spawnY;
			_physics = new GloopPhysicsComponent( this );
			_physics.angularDamping = Settings.GLOOP_ANGULAR_DAMPING;
			_physics.friction = Settings.GLOOP_FRICTION;
			_physics.restitution = Settings.GLOOP_RESTITUTION;
			
			_splat = new SplatComponent(_physics);
			
			_mesh = new MeshComponent();
			var colorMaterial:ColorMaterial = new ColorMaterial( 0x00ff00 );
			_mesh.mesh = new Mesh( new SphereGeometry(Settings.GLOOP_RADIUS), colorMaterial );
		}
		
		override public function reset():void {
			super.reset();
			
			_physics.x = _spawnX, 
			_physics.y = _spawnY;
			if (_physics.b2body) {
				_physics.syncTransform();
				_physics.b2body.SetAngularVelocity(0);
				_physics.b2body.SetLinearVelocity(new V2(0, 0));
			}
		}

		override public function update( dt:Number ):void {
			super.update( dt );
			_splat.update( dt );
		}

		override public function get debugColor1():uint {
			return 0x84c806;
		}

		override public function get debugColor2():uint {
			return 0x7da628;
		}
		
		public function get splat():SplatComponent {
			return _splat;
		}
	}
}

import com.away3d.gloop.gameobjects.components.PhysicsComponent;
import com.away3d.gloop.gameobjects.DefaultGameObject;
import com.away3d.gloop.Settings;

class GloopPhysicsComponent extends PhysicsComponent
{

	public function GloopPhysicsComponent( gameObject:DefaultGameObject ) {
		super( gameObject );
		graphics.beginFill( gameObject.debugColor1 );
		graphics.drawCircle( 0, 0, Settings.GLOOP_RADIUS );
		graphics.beginFill( gameObject.debugColor2 );
		graphics.drawRect( -Settings.GLOOP_RADIUS / 2, -Settings.GLOOP_RADIUS / 2, Settings.GLOOP_RADIUS, Settings.GLOOP_RADIUS );

	}

	public override function shapes():void {
		circle( Settings.GLOOP_RADIUS );
	}

	override public function create():void {
		super.create();
		setCollisionGroup( GLOOP );
	}
}