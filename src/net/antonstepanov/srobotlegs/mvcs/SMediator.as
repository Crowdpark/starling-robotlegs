package net.antonstepanov.srobotlegs.mvcs
{
    import net.antonstepanov.srobotlegs.base.SEventMap;
    import net.antonstepanov.srobotlegs.core.ISEventMap;

    import org.robotlegs.base.EventMap;
    import org.robotlegs.base.MediatorBase;
    import org.robotlegs.core.IEventMap;
    import org.robotlegs.core.IMediatorMap;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.IEventDispatcher;

    import starling.events.EventDispatcher;

    /**
     * Abstract MVCS <code>IMediator</code> implementation
     */
    public class SMediator extends MediatorBase
    {
        [Inject]
        public var contextView:DisplayObjectContainer;

        [Inject]
        public var mediatorMap:IMediatorMap;

        /**
         * @private
         */
        protected var _fEventDispatcher:IEventDispatcher;

        /**
         * @private
         */
        protected var _sEventDispatcher:EventDispatcher;

        /**
         * @private
         */
        protected var _fEventMap:IEventMap;

        /**
         * @private
         */
        protected var _sEventMap:ISEventMap;

        public function SMediator()
        {
        }

        /**
         * @inheritDoc
         */
        override public function preRemove():void
        {
            if (_sEventMap)
            {
                _sEventMap.unmapListeners();
            }

            if (_fEventMap)
            {
                _fEventMap.unmapListeners();
            }
            super.preRemove();
        }

        /**
         * @inheritDoc
         */
        public function get fEventDispatcher():IEventDispatcher
        {
            return _fEventDispatcher;
        }

        [Inject]
        /**
         * @private
         */
        public function set fEventDispatcher(value:IEventDispatcher):void
        {
            _fEventDispatcher = value;
        }

        /**
         * @inheritDoc
         */
        public function get sEventDispatcher():EventDispatcher
        {
            return _sEventDispatcher;
        }

        [Inject]
        /**
         * @private
         */
        public function set sEventDispatcher(value:EventDispatcher):void
        {
            _sEventDispatcher = value;
        }

        /**
         * Local EventMap
         *
         * @return The EventMap for this Actor
         */
        protected function get fEventMap():IEventMap
        {
            return _fEventMap || (_fEventMap = new EventMap(fEventDispatcher));
        }

        /**
         * Local EventMap
         *
         * @return The EventMap for this Actor
         */
        protected function get sEventMap():ISEventMap
        {
            return _sEventMap || (_sEventMap = new SEventMap(sEventDispatcher));
        }



        /**
         * Dispatch helper method
         *
         * @param event The Event to dispatch on the <code>IContext</code>'s <code>flash.events.IEventDispatcher</code>
         */
        protected function dispatch(event:Event):Boolean
        {
            if (fEventDispatcher.hasEventListener(event.type))
            {
                return fEventDispatcher.dispatchEvent(event);
            }
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
            if (viewComponent is EventDispatcher)
            {
                sEventMap.mapListener(EventDispatcher(viewComponent), type, listener, eventClass);
            }
            else
            {
                fEventMap.mapListener(IEventDispatcher(viewComponent), type, listener, eventClass, useCapture, priority, useWeakReference);
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
            if (viewComponent is EventDispatcher)
            {
                sEventMap.unmapListener(EventDispatcher(viewComponent), type, listener, eventClass);
            }
            else
            {
                fEventMap.unmapListener(IEventDispatcher(viewComponent), type, listener, eventClass, useCapture);
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
            fEventMap.mapListener(fEventDispatcher, type, listener, eventClass, useCapture, priority, useWeakReference);
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
            fEventMap.unmapListener(fEventDispatcher, type, listener, eventClass, useCapture);
        }

    }
}
