package net.antonstepanov.srobotlegs.mvcs
{
	import starling.display.DisplayObjectContainer;

	import org.robotlegs.base.EventMap;
	import org.robotlegs.base.MediatorBase;
	import org.robotlegs.core.IEventMap;
	import org.robotlegs.core.IMediatorMap;

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.IEventDispatcher;



	/**
	 * Abstract MVCS <code>IMediator</code> implementation
	 */
	public class SMediator extends MediatorBase
	{
		[Inject]
		public var contextView:flash.display.DisplayObjectContainer;
		
		[Inject]
		public var mediatorMap:IMediatorMap;
		
		/**
		 * @private
		 */
		protected var _eventDispatcher:flash.events.IEventDispatcher;
		
		/**
		 * @private
		 */
		protected var _eventMap:IEventMap;
		
		public function SMediator()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		override public function preRemove():void
		{
			if (_eventMap)
				_eventMap.unmapListeners();
			super.preRemove();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get eventDispatcher():flash.events.IEventDispatcher
		{
			return _eventDispatcher;
		}
		
		[Inject]
		/**
		 * @private
		 */
		public function set eventDispatcher(value:flash.events.IEventDispatcher):void
		{
			_eventDispatcher = value;
		}
		
		/**
		 * Local EventMap
		 *
		 * @return The EventMap for this Actor
		 */
		protected function get eventMap():IEventMap
		{
			return _eventMap || (_eventMap = new EventMap(eventDispatcher));
		}
		
		/**
		 * Dispatch helper method
		 *
		 * @param event The Event to dispatch on the <code>IContext</code>'s <code>flash.events.IEventDispatcher</code>
		 */
		protected function dispatch(event:Event):Boolean
		{
 		    if(eventDispatcher.hasEventListener(event.type))
 		        return eventDispatcher.dispatchEvent(event);
 		 	return false;
		}
		
		/**
		 * Syntactical sugar for mapping a listener to the <code>viewComponent</code> 
		 * 
		 * @param type
		 * @param listener
		 * @param eventClass
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 * 
		 */		
		protected function addViewListener(type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
		{
			if (viewComponent is starling.display.DisplayObjectContainer) {
				starling.display.DisplayObjectContainer(viewComponent).addEventListener(type, listener);
			} else {
				eventMap.mapListener(flash.events.IEventDispatcher(viewComponent), type, listener, eventClass, useCapture, priority, useWeakReference);
			}
		}

        /**
		 * Syntactical sugar for mapping a listener from the <code>viewComponent</code>
		 *
		 * @param type
		 * @param listener
		 * @param eventClass
		 * @param useCapture
		 *
		 */
		protected function removeViewListener(type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false):void
		{
			if (viewComponent is starling.display.DisplayObjectContainer) {
				starling.display.DisplayObjectContainer(viewComponent).removeEventListener(type, listener);
			} else {
				eventMap.unmapListener(flash.events.IEventDispatcher(viewComponent), type, listener,	eventClass, useCapture);
			}
			
		}

		/**
		 * Syntactical sugar for mapping a listener to an <code>flash.events.IEventDispatcher</code> 
		 * 
		 * @param dispatcher
		 * @param type
		 * @param listener
		 * @param eventClass
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 * 
		 */		
		protected function addContextListener(type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
	 	{
			eventMap.mapListener(eventDispatcher, type, listener, 
				eventClass, useCapture, priority, useWeakReference); 									   
		}

		/**
		 * Syntactical sugar for unmapping a listener from an <code>flash.events.IEventDispatcher</code>
		 *
		 * @param dispatcher
		 * @param type
		 * @param listener
		 * @param eventClass
		 * @param useCapture
		 *
		 */
		protected function removeContextListener(type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false):void
	 	{
			eventMap.unmapListener(eventDispatcher, type, listener,
				eventClass, useCapture);
		}
	
	}
}
