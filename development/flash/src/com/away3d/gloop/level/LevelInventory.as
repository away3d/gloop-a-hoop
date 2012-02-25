package com.away3d.gloop.level
{
	import com.away3d.gloop.events.InventoryEvent;
	import com.away3d.gloop.hud.elements.InventoryButton;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class LevelInventory extends EventDispatcher
	{
		private var _items : Vector.<LevelInventoryItem>;
		
		private var _selectedItem : LevelInventoryItem;
		
		
		public function LevelInventory()
		{
			super();
			
			_items = new Vector.<LevelInventoryItem>();
		}
		
		
		public function get selectedItem() : LevelInventoryItem
		{
			return _selectedItem;
		}
		
		
		public function get items() : Vector.<LevelInventoryItem>
		{
			return _items;
		}
		
		
		public function select(item : LevelInventoryItem) : void
		{
			_selectedItem = item;
			dispatchEvent(new InventoryEvent(InventoryEvent.ITEM_SELECT, item));
		}
		
		
		public function reset() : void
		{
			var i : uint;
			var len : uint;
			
			len = _items.length;
			for (i=0; i<len; i++) {
				_items[i].reset();
			}
		}
		
		
		public function parseXml(xml : XML) : void
		{
			var item_xml : XML;
			
			for each (item_xml in xml.children()) {
				var item : LevelInventoryItem;
				var count : uint;
				
				// Count defaults to one
				count = parseInt(item_xml.@count.toString()) || 1;
				
				item = new LevelInventoryItem(item_xml.name(), item_xml.@variant.toString(), count);
				_items.push(item);
			}
		}
	}
}