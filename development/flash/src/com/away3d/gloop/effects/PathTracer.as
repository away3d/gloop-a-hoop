package com.away3d.gloop.effects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.DefaultMaterialBase;
	import away3d.primitives.SphereGeometry;
	
	import com.away3d.gloop.Settings;

	public class PathTracer extends ObjectContainer3D
	{
		private var _poolSize : uint;
		
		private var _path : Vector.<Mesh>;
		private var _pointsTraced : uint;
		
		private var _minScale : Number;
		private var _maxScale : Number;
		private var _decayScale : Number;

		public function PathTracer(poolSize : uint = 20)
		{
			super();
			
			_poolSize = poolSize;
			_minScale = Settings.TRACE_MIN_SCALE;
			_maxScale = Settings.TRACE_MAX_SCALE;
			
			init();
		}
		
		private function init() : void
		{
			var i : uint;
			var mat : DefaultMaterialBase;
			var geom : Geometry;
			
			geom = new SphereGeometry( 5 );
			mat = new ColorMaterial( 0xFFFFFF );
			
			_path = new Vector.<Mesh>(_poolSize, true);
			for (i=0; i<_poolSize; i++) {
				_path[i] = new Mesh(geom, mat);
			}
			
			_pointsTraced = 0;
		}
		
		
		public function get hasMore() : Boolean
		{
			return (_pointsTraced < _poolSize);
		}
		
		
		public function reset() : void
		{
			var i : uint;
			
			for (i=0; i<_pointsTraced; i++) {
				removeChild(_path[i]);
			}
			
			_decayScale = 1;
			_pointsTraced = 0;
		}
		

		public function tracePoint( x:Number, y:Number, z:Number ):void {
			var entry : Mesh;
			
			entry = _path[_pointsTraced++];
			entry.x = x;
			entry.y = y;
			entry.z = z;
			entry.scaleX = entry.scaleY = entry.scaleZ = rand(_minScale, _maxScale) * _decayScale;
			addChild( entry );
			
			if ((_poolSize-_pointsTraced) < 10)
				_decayScale -= 0.1;
		}

		private function rand(min:Number, max:Number):Number
		{
		    return (max - min)*Math.random() + min;
		}
	}
}
