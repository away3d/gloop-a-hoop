package com.away3d.gloop.effects
{

	import away3d.containers.Scene3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;

	import flash.geom.Vector3D;

	public class DecalSplatter
	{
		public var numRays:uint = 1;
		public var apertureX:Number = 0;
		public var apertureY:Number = 0;
		public var apertureZ:Number = 0;
		public var sourcePosition:Vector3D;
		public var splatDirection:Vector3D;
		public var decals:Vector.<Mesh>;
		public var zOffset:Number = 1;
		public var targets:Vector.<Mesh>;
		public var maxDistance:Number = 50;
		public var minScale:Number = 1;
		public var maxScale:Number = 1;

		private var _meshCollider:MeshCollider;

		public function DecalSplatter() {
			_meshCollider = new MeshCollider();
			sourcePosition = new Vector3D();
			splatDirection = new Vector3D( 0, 1, 0 );
		}

		// TODO: manage decal mesh reuse
		// TODO: implement projective zOffset, clip decals on edges, use circular random position instead of square, improve performance
		public function evaluate():void {

			_meshCollider.updateTarget( targets );

			var rayPosition:Vector3D;
			var rayDirection:Vector3D;
			for( var i:uint; i < numRays; ++i ) {
				// update ray position // TODO: apply randomization
				rayPosition = sourcePosition.clone();
				rayDirection = splatDirection.clone();
				if( numRays > 1 ) {
					rayDirection.x += rand( -apertureX, apertureX );
					rayDirection.y += rand( -apertureY, apertureY );
					rayDirection.z += rand( -apertureZ, apertureZ );
				}
				_meshCollider.updateRay( rayPosition, rayDirection );
				// test
				if( _meshCollider.evaluate() ) {

					// evaluate decal position
					var position:Vector3D = _meshCollider.collidingMesh.sceneTransform.transformVector( _meshCollider.collisionPoint );
					var distance:Number = position.subtract( sourcePosition ).length;
					if( distance > maxDistance ) continue;

					// evaluate normal and place decal with an offset
					var normal:Vector3D = _meshCollider.collidingMesh.sceneTransform.deltaTransformVector( _meshCollider.collisionNormal );
					normal.scaleBy( zOffset );
					position = position.add( normal );
					placeDecalAt( position, normal, rand( minScale, maxScale ) );
				}
			}
		}

		private function placeDecalAt( position:Vector3D, normal:Vector3D, scale:Number = 1 ):void {
			var scene:Scene3D = _meshCollider.collidingMesh.scene;
			var randDecalIndex:uint = Math.floor( Math.random() * decals.length );
			var decal:Mesh = decals[ randDecalIndex ].clone() as Mesh;
			decal.scale( scale );
			decal.position = position;
			var offsetPosition:Vector3D = position.add( normal );
			decal.lookAt( offsetPosition, new Vector3D( rand( -1, 1 ), rand( -1, 1 ), rand( -1, 1 ) ) );
			scene.addChild( decal );
		}

		private function rand( min:Number, max:Number ):Number {
			return (max - min) * Math.random() + min;
		}
	}
}
