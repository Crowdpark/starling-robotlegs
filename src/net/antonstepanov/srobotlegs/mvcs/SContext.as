package net.antonstepanov.srobotlegs.mvcs
{
    import flash.display.DisplayObjectContainer;
    import flash.events.IEventDispatcher;

    import net.antonstepanov.srobotlegs.base.SMediatorMap;

    import org.robotlegs.base.EventMap;

    import org.robotlegs.core.ICommandMap;
    import org.robotlegs.core.IEventMap;

    import org.robotlegs.core.IInjector;

    import org.robotlegs.core.IMediatorMap;
    import org.robotlegs.core.IReflector;
    import org.robotlegs.core.IViewMap;
    import org.robotlegs.mvcs.Context;

    import starling.core.Starling;
    import starling.events.Event;
    import starling.events.EventDispatcher;

    /**
     * @author antonstepanov
     * @creation date Jul 4, 2012
     */
    public class SContext extends Context
    {
        protected var _contextStarlingView:StarlingContextView;

        protected var starlingInitialized:Boolean = false;
        protected var autoStartup:Boolean = false;
        protected var startStarling:Boolean = true;
        protected var startWhenStarlingInitComplete:Boolean = false;

        protected var _sEventDispatcher:EventDispatcher;

        public function SContext(contextView:DisplayObjectContainer = null, autoStartup:Boolean = true, startStarling:Boolean = true)
        {
            this.startStarling = startStarling;
            this.autoStartup = autoStartup;
            super(contextView, false);

            if (startStarling)
            {
                //check if starling already exists
                if (Starling.current)
                {
                    setupStarlingView();
                }
                else
                {
                    createStarling();
                }
            }
        }

        // ::::::::::::::::::::::::::::::::::::::::::::::::::::::
        // SETTERS AND GETTERS
        // ::::::::::::::::::::::::::::::::::::::::::::::::::::::
        public function get contextStarlingView():StarlingContextView
        {
            return _contextStarlingView;
        }

        override protected function get mediatorMap():IMediatorMap
        {
            _mediatorMap ||= new SMediatorMap(contextView, createChildInjector(), reflector);
            return _mediatorMap;
        }

        protected function get sEventDispatcher():EventDispatcher
        {
            return _sEventDispatcher ||= new EventDispatcher();
        }

        // ::::::::::::::::::::::::::::::::::::::::::::::::::::::
        // PUBLIC FUNCTIONS
        // ::::::::::::::::::::::::::::::::::::::::::::::::::::::
        override public function startup():void
        {
            if (!startStarling || (startStarling && starlingInitialized))
            {
                super.startup();
            }
            else
            {
                // starling not yet initialized, but startup was called
                startWhenStarlingInitComplete = true;
            }
        }

        override public function shutdown():void
        {
            _contextStarlingView = null;
            injector.unmap(StarlingContextView);
            SMediatorMap(mediatorMap).contextStarlingView = null;

            super.shutdown();
        }

        protected function createStarling():void
        {
            Starling.handleLostContext = true;
            var renderingType:String = "auto";
            var starling:Starling = new Starling(StarlingContextView, contextView.stage, null, null, renderingType, "baselineConstrained");
            starling.shareContext = false;
            starling.antiAliasing = 1;

            starling.addEventListener(Event.ROOT_CREATED, rootCreatedHandler);
            starling.start();
        }

        /**
         * Injection Mapping Hook
         *
         * <p>Override this in your Framework context to change the default configuration</p>
         *
         * <p>Beware of collisions in your container</p>
         */
        override protected function mapInjections():void
        {
            super.mapInjections();
            injector.mapValue(EventDispatcher, sEventDispatcher);
        }

        // ::::::::::::::::::::::::::::::::::::::::::::::::::::::
        // PRIVATE FUNCTIONS
        // ::::::::::::::::::::::::::::::::::::::::::::::::::::::

        /**
         * initialize starling in robotlegs framework
         */
        protected function setupStarlingView():void
        {
            _contextStarlingView = StarlingContextView.instance;
            if (_contextStarlingView)
            {
                injector.mapValue(StarlingContextView, contextStarlingView);
                SMediatorMap(mediatorMap).contextStarlingView = contextStarlingView;
            }
            starlingInitialized = true;
            if (autoStartup)
            {
                startup();
            }
            else if (startWhenStarlingInitComplete)
            {
                super.startup();
            }
        }

        // ::::::::::::::::::::::::::::::::::::::::::::::::::::::
        // EVENT HANDLERS
        // ::::::::::::::::::::::::::::::::::::::::::::::::::::::
        protected function rootCreatedHandler(event:Event):void
        {
            event.target.removeEventListener(Event.ROOT_CREATED, rootCreatedHandler);
            setupStarlingView();
        }
    }
}
