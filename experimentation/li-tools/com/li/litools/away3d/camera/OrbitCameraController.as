package com.li.litools.away3d.camera
{

	import away3d.cameras.Camera3D;
	import away3d.core.base.Object3D;

	import com.li.litools.general.input.KeyManager;

	import flash.display.Stage;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	public class OrbitCameraController extends EventDispatcher
	{
		private var _camera:Camera3D;
		private var _dummy:Object3D;
		private var _mouseIsDown:Boolean;
		private var _mouseX:Number;
		private var _mouseY:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		private var _targetRotationX:Number;
		private var _targetRotationY:Number;
		private var _moveEvt:Event;
		private var _motionStartedEvt:Event;
		private var _motionCompleteEvt:Event;
		private var _moving:Boolean;
		private var _center:Vector3D;
		private var _key:KeyManager;

		private var _currentSphericalCoordinates:Vector3D;
		private var _targetSphericalCoordinates:Vector3D;

		private const PI:Number = Math.PI;
		private const TWOPI:Number = 2 * PI;
		private const HALFPI:Number = PI / 2;
		private var _initCameraPosition:Vector3D;
		private var _stage:Stage;

		public var minAzimuth:Number = 0;
		public var maxAzimuth:Number = TWOPI; // Azimuth range should stay within [0, 2Pi].
		public var minElevation:Number = -HALFPI;
		public var maxElevation:Number = HALFPI; // Elevation range should stay within [-Pi/2, Pi/2].
		public var minRadius:Number = 0;
		public var maxRadius:Number = 10000; // Negative values not recommended.
		public var mouseInputFactor:Number = 0.01;

		public function OrbitCameraController( camera:Camera3D, stage:Stage ) {
			_stage = stage;
			_camera = camera;
			_dummy = new Object3D();
			_dummy.position = _camera.position;
			_camera.lookAt( new Vector3D() );
			_targetRotationX = _targetRotationY = 0;
			_center = new Vector3D();
			_motionStartedEvt = new Event( Event.CLEAR );
			_moveEvt = new Event( Event.CHANGE );
			_motionCompleteEvt = new Event( Event.COMPLETE );

			_initCameraPosition = _camera.position.clone();
			reset();

			initStageListeners();
			_key = new KeyManager();
		}

		private function initStageListeners():void {
			_stage.addEventListener( MouseEvent.MOUSE_DOWN, function( event:MouseEvent ):void { mouseDown() } );
			_stage.addEventListener( MouseEvent.MOUSE_UP, function( event:MouseEvent ):void { mouseUp() } );
			_stage.addEventListener( MouseEvent.MOUSE_MOVE, function( event:MouseEvent ):void { mouseMove( event.stageX, event.stageY ) } );
			_stage.addEventListener( MouseEvent.MOUSE_WHEEL, function( event:MouseEvent ):void { mouseWheel( event.delta ) } );
			_stage.addEventListener( KeyboardEvent.KEY_DOWN, function( event:KeyboardEvent ):void { keyDown( event.keyCode ) } );
			_stage.addEventListener( KeyboardEvent.KEY_UP, function( event:KeyboardEvent ):void { keyUp( event.keyCode ) } );
		}

		public function reset():void {
			_camera.position = _initCameraPosition;
			_targetSphericalCoordinates = cartesianToSpherical( _camera.position );
			_currentSphericalCoordinates = _targetSphericalCoordinates.clone();
		}

		public function keyDown( keyCode:uint ):void {
			_key.keyDown( keyCode );
		}

		public function keyUp( keyCode:uint ):void {
			_key.keyUp( keyCode );
		}

		public function mouseDown():void {
			_lastMouseX = _mouseX;
			_lastMouseY = _mouseY;
			_mouseIsDown = true;
		}

		public function mouseUp():void {
			_mouseIsDown = false;
		}

		public function mouseMove( mouseX:Number, mouseY:Number ):void {
			_mouseX = mouseX;
			_mouseY = mouseY;
		}

		public function mouseWheel( delta:Number ):void {
			_targetSphericalCoordinates.z -= 5 * delta;
		}

		public function set azimuth( value:Number ):void {
			_targetSphericalCoordinates.x = value;
		}

		public function get azimuth():Number {
			return _targetSphericalCoordinates.x;
		}

		public function set elevation( value:Number ):void {
			_targetSphericalCoordinates.y = value;
		}

		public function get elevation():Number {
			return _targetSphericalCoordinates.y;
		}

		public function set radius( value:Number ):void {
			_targetSphericalCoordinates.z = value;
		}

		public function get radius():Number {
			return _targetSphericalCoordinates.z;
		}

		public function moveAzimuth( da:Number ):void {
			_targetSphericalCoordinates.x += da;
		}

		public function moveElevation( de:Number ):void {
			_targetSphericalCoordinates.y += de;
		}

		public function moveRadius( dr:Number ):void {
			_targetSphericalCoordinates.z += dr;
		}

		public function update():void {
			var dx:Number;
			var dy:Number;
			var dz:Number;

			// update target orientation
			if( _mouseIsDown ) {
				dx = _mouseX - _lastMouseX; // calculate rotation from mouse deltas
				dy = _mouseY - _lastMouseY;
				_targetSphericalCoordinates.x += dx * mouseInputFactor;
				_targetSphericalCoordinates.y -= dy * mouseInputFactor;
				_lastMouseX = _mouseX; // store current mouse
				_lastMouseY = _mouseY;
			}

			// keys
			if( _key.keyIsDown( _key.RIGHT ) || _key.keyIsDown( _key.D ) ) {
				_targetSphericalCoordinates.x -= 0.1;
			}
			else if( _key.keyIsDown( _key.LEFT ) || _key.keyIsDown( _key.A ) ) {
				_targetSphericalCoordinates.x += 0.1;
			}
			if( _key.keyIsDown( _key.UP ) || _key.keyIsDown( _key.W ) ) {
				_targetSphericalCoordinates.y -= 0.1;
			}
			else if( _key.keyIsDown( _key.DOWN ) || _key.keyIsDown( _key.S ) ) {
				_targetSphericalCoordinates.y += 0.1;
			}
			if( _key.keyIsDown( _key.Z ) ) {
				_targetSphericalCoordinates.z -= 50;
			}
			else if( _key.keyIsDown( _key.X ) ) {
				_targetSphericalCoordinates.z += 50;
			}

//			_targetSphericalCoordinates.x = containValue(_targetSphericalCoordinates.x, _minAzimuth, _maxAzimuth);
			_targetSphericalCoordinates.y = containValue( _targetSphericalCoordinates.y, minElevation, maxElevation );
			_targetSphericalCoordinates.z = containValue( _targetSphericalCoordinates.z, minRadius, maxRadius );

			dx = _targetSphericalCoordinates.x - _currentSphericalCoordinates.x;
			dy = _targetSphericalCoordinates.y - _currentSphericalCoordinates.y;
			dz = _targetSphericalCoordinates.z - _currentSphericalCoordinates.z;
			_currentSphericalCoordinates.x += dx * 0.25;
			_currentSphericalCoordinates.y += dy * 0.25;
			_currentSphericalCoordinates.z += dz * 0.25;
			_camera.position = sphericalToCartesian( _currentSphericalCoordinates );

			_camera.lookAt( _center );

			// report
			if( Math.abs( dx ) < 0.003 && Math.abs( dy ) < 0.003 && Math.abs( dz ) < 1 ) {
				if( _moving ) {
					dispatchEvent( _motionCompleteEvt );
					_moving = false;
				}
			}
			else {
				if( !_moving ) {
					dispatchEvent( _motionStartedEvt );
					_moving = true;
				}
				else
					dispatchEvent( _moveEvt );
			}
		}

		private function sphericalToCartesian( sphericalCoords:Vector3D ):Vector3D {
			var cartesianCoords:Vector3D = new Vector3D();
			var r:Number = sphericalCoords.z;
			cartesianCoords.y = _center.y + r * Math.sin( -sphericalCoords.y );
			var cosE:Number = Math.cos( -sphericalCoords.y );
			cartesianCoords.x = _center.x + r * cosE * Math.sin( sphericalCoords.x );
			cartesianCoords.z = _center.z + r * cosE * Math.cos( sphericalCoords.x );
			return cartesianCoords;
		}

		private function cartesianToSpherical( cartesianCoords:Vector3D ):Vector3D {
			var cartesianFromCenter:Vector3D = new Vector3D();
			cartesianFromCenter.x = cartesianCoords.x - _center.x;
			cartesianFromCenter.y = cartesianCoords.y - _center.y;
			cartesianFromCenter.z = cartesianCoords.z - _center.z;
			var sphericalCoords:Vector3D = new Vector3D();
			sphericalCoords.z = cartesianFromCenter.length;
			sphericalCoords.x = Math.atan2( cartesianFromCenter.x, cartesianFromCenter.z );
			sphericalCoords.y = -Math.asin( (cartesianFromCenter.y) / sphericalCoords.z );
			return sphericalCoords;
		}

		private function containValue( value:Number, min:Number, max:Number ):Number {
			if( value < min )
				return min;
			else if( value > max )
				return max;
			else
				return value;
		}
	}
}
