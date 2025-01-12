package uk.co.awamedia.gloop.levels
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import uk.co.awamedia.gloop.events.LevelInteractionEvent;
	import uk.co.awamedia.gloop.gameobjects.Hoop;
	

	public class Level extends EventDispatcher
	{
		private var _w : uint;
		private var _h : uint;
		private var _grid_size : uint;
		
		private var _back_plane : Mesh;
		private var _container:ObjectContainer3D;
		private var _hoop_mat:ColorMaterial;
		private var _hoop_top_mat:ColorMaterial;
		
		internal var _bmp : BitmapData;
		
		internal var _spawn_point : Point;
		internal var _walls : Vector.<Rectangle>;
		internal var _hoops : Vector.<Hoop>;
		
		
		public function Level(w : uint, h : uint)
		{
			_w = w;
			_h = h;
			_walls = new Vector.<Rectangle>();
			_hoops = new Vector.<Hoop>();
		}
		
		
		public function get spawnPoint() : Point
		{
			return _spawn_point;
		}
		
		public function get hoops():Vector.<Hoop> {
			return _hoops;
		}

		public function update(timeDelta : Number = 1) : void
		{
			var i : uint;
			
			for (i=0; i<_hoops.length; i++) {
				_hoops[i].update(timeDelta);
			}
		}
		
		
		public function construct(lights : Array, gridSize : Number = 20) : ObjectContainer3D
		{
			_container = new ObjectContainer3D();
			
			var r : Rectangle;
			var hoop : Hoop;
			var mesh : Mesh;
			var back_mat : ColorMaterial;
			var wall_mat : ColorMaterial;
			
			_grid_size = gridSize;
			
			wall_mat = new ColorMaterial(0x888888);
			wall_mat.lightPicker = new StaticLightPicker(lights);
			wall_mat.gloss = 0.2;
			wall_mat.specular = 0.6;
			
			_hoop_mat = new ColorMaterial(0x00ff00);
			_hoop_mat.lightPicker = new StaticLightPicker(lights);
			
			_hoop_top_mat = new ColorMaterial(0xff0000);
			_hoop_top_mat.lightPicker = new StaticLightPicker(lights);
					
			for each (r in _walls) {
				var cube : CubeGeometry;
				
				cube = new CubeGeometry(r.width * gridSize, r.height * gridSize, 6 * gridSize);
				mesh = new Mesh(cube, wall_mat);
				mesh.x = r.x * gridSize + r.width * gridSize/2;
				mesh.y = -r.y * gridSize - r.height * gridSize/2;
				_container.addChild(mesh);
			}
			
			for each (hoop in _hoops) {
				constructHoop(hoop);
			}
			
			back_mat = new ColorMaterial(0xcccccc);
			back_mat.gloss = 0.2;
			back_mat.specular = 0.6;
			
			_back_plane = new Mesh(new PlaneGeometry(_w * gridSize, _h * gridSize, 1, 1, false), back_mat);
			_back_plane.x = _w/2 * gridSize;
			_back_plane.y = -_h/2 * gridSize;
			_back_plane.z = gridSize*3;
			_back_plane.material.lightPicker = new StaticLightPicker(lights);
			_container.addChild(_back_plane);
			
			_back_plane.mouseEnabled = true;
			_back_plane.addEventListener(MouseEvent3D.MOUSE_DOWN, onPlaneMouseDown);
			_back_plane.addEventListener(MouseEvent3D.MOUSE_UP, onPlaneMouseUp);
			_back_plane.addEventListener(MouseEvent3D.MOUSE_MOVE, onPlaneMouseMove);
			
			return _container;
		}
		
		
		private function dispatchInteractionEvent(type : String, sceneX : Number, sceneY : Number) : void
		{
			var grid_x : int, grid_y : int;
			
			grid_x = (sceneX + (_w * _grid_size)/2)/_grid_size;
			grid_y = _h - (sceneY + (_h * _grid_size)/2)/_grid_size;
			dispatchEvent(new LevelInteractionEvent(type, grid_x, grid_y));
		}
		
		
		private function onPlaneMouseDown(ev : MouseEvent3D) : void
		{
			dispatchInteractionEvent(LevelInteractionEvent.DOWN, ev.localX, ev.localY);
		}
		
		
		private function onPlaneMouseUp(ev : MouseEvent3D) : void
		{
			dispatchInteractionEvent(LevelInteractionEvent.RELEASE, ev.localX, ev.localY);
		}
		
		
		private function onPlaneMouseMove(ev : MouseEvent3D) : void
		{
			dispatchInteractionEvent(LevelInteractionEvent.MOVE, ev.localX, ev.localY);
		}
		
		public function constructHoop(hoop:Hoop):void {
			var top : Mesh;
			var cylinder : CylinderGeometry;
			
			cylinder = new CylinderGeometry(hoop.radius * _grid_size, hoop.radius * _grid_size, 0.1 * _grid_size);
			var mesh:Mesh = new Mesh(cylinder, _hoop_mat);
			mesh.x = hoop.position.x * _grid_size;
			mesh.y = -hoop.position.y * _grid_size;
			
			top = new Mesh(cylinder, _hoop_top_mat);
			top.y = _grid_size*0.05;
			mesh.addChild(top);
				
			hoop.mesh = mesh;
			_container.addChild(mesh);
		}
		
		
		public function testCollision(gameX : Number, gameY : Number) : Boolean
		{
			var gridx:int = Math.floor(gameX);
			var gridy:int = Math.floor(gameY);
			
			if (gridx >= _bmp.width || gridx < 0 || gridy < 0 || gridy > _bmp.height-1)
				return true;
			
			return _bmp.getPixel(gridx, gridy) == 0;
		}
		
				
		public function get width():uint {
			return _w;
		}
		
		public function get heigth():uint {
			return _h;
		}
		
	}
}