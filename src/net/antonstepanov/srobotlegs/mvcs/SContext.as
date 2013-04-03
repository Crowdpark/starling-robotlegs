package net.antonstepanov.srobotlegs.mvcs
{
	import net.antonstepanov.srobotlegs.base.SMediatorMap;

	import starling.core.Starling;
	import starling.events.Event;

	import org.robotlegs.core.IMediatorMap;
	import org.robotlegs.mvcs.Context;

	import flash.display.DisplayObjectContainer;

	/**
	 * @author antonstepanov
	 * @creation date Jul 4, 2012
	 */
	public class SContext extends Context
	{
		protected var _contextStarlingView : StarlingContextView;
		
		private var starlingInitialized : Boolean = false;
		private var autoStartup : Boolean = false;
		private var startStarling : Boolean = true;

		public function SContext(contextView : DisplayObjectContainer = null, autoStartup : Boolean = true, startStarling : Boolean = true)
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
		public function get contextStarlingView() : StarlingContextView
		{
			return _contextStarlingView;
		}

		override protected function get mediatorMap() : IMediatorMap
		{
			return _mediatorMap ||= new SMediatorMap(contextView, createChildInjector(), reflector);
		}

		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::
		// PUBLIC FUNCTIONS
		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::
		override public function startup() : void
		{
			if (!startStarling || (startStarling && starlingInitialized))
			{
				super.startup();
			}
			else
			{
				// starling not yet initialized, but startup was called
				autoStartup = true;
			}
		}

		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::
		// PROTECTED FUNCTIONS
		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::
		protected function createStarling() : void
		{
			Starling.handleLostContext = true;
			var renderingType : String = "auto";
			var starling : Starling = new Starling(StarlingContextView, contextView.stage, null, null, renderingType, "baseline");
			starling.shareContext = false;
			starling.antiAliasing = 1;

			starling.addEventListener(starling.events.Event.ROOT_CREATED, rootCreatedHandler);
			starling.start();
		}

		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::
		// PRIVATE FUNCTIONS
		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		/**
		 * initialize starling in robotlegs framework 
		 */
		private function setupStarlingView() : void
		{
			_contextStarlingView = StarlingContextView.instance;
			
			injector.mapValue(StarlingContextView, contextStarlingView);
			SMediatorMap(mediatorMap).contextStarlingView = contextStarlingView;
			
			starlingInitialized = true;
			if (autoStartup)
			{
				startup();
			}
		}

		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::
		// EVENT HANDLERS
		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::
		private function rootCreatedHandler(event : starling.events.Event) : void
		{
			event.target.removeEventListener(starling.events.Event.ROOT_CREATED, rootCreatedHandler);
			setupStarlingView();
		}
	}
}