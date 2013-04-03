package net.antonstepanov.srobotlegs.base
{
	import starling.display.DisplayObject;
	import starling.events.Event;

	import org.robotlegs.base.ContextError;
	import org.robotlegs.base.ViewMapBase;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IMediator;
	import org.robotlegs.core.IMediatorMap;
	import org.robotlegs.core.IReflector;

	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;




	/**
	 * @author antonstepanov
	 * @creation date Jul 5, 2012
	 */
	public class SMediatorMap extends ViewMapBase implements IMediatorMap
	{
		/**
		 * @private
		 */
		protected static const enterFrameDispatcher : Sprite = new Sprite();
		/**
		 * @private
		 */
		protected var mediatorByView : Dictionary;
		/**
		 * @private
		 */
		protected var mappingConfigByView : Dictionary;
		/**
		 * @private
		 */
		protected var mappingConfigByViewClassName : Dictionary;
		/**
		 * @private
		 */
		protected var mediatorsMarkedForRemoval : Dictionary;
		/**
		 * @private
		 */
		protected var hasMediatorsMarkedForRemoval : Boolean;
		/**
		 * @private
		 */
		protected var reflector : IReflector;
		protected var _contextStarlingView : starling.display.DisplayObject;

		// ---------------------------------------------------------------------
		// Constructor
		// ---------------------------------------------------------------------
		/**
		 * Creates a new <code>MediatorMap</code> object
		 *
		 * @param contextView The root view node of the context. The map will listen for ADDED_TO_STAGE events on this node
		 * @param injector An <code>IInjector</code> to use for this context
		 * @param reflector An <code>IReflector</code> to use for this context
		 */
		public function SMediatorMap(contextView : DisplayObjectContainer, injector : IInjector, reflector : IReflector)
		{
			super(contextView, injector);

			this.reflector = reflector;

			// mappings - if you can do it with fewer dictionaries you get a prize
			this.mediatorByView = new Dictionary(true);
			this.mappingConfigByView = new Dictionary(true);
			this.mappingConfigByViewClassName = new Dictionary(false);
			this.mediatorsMarkedForRemoval = new Dictionary(false);
		}

		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::
		// SETTERS AND GETTERS
		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::
		public function get contextStarlingView() : starling.display.DisplayObject
		{
			return _contextStarlingView;
		}

		public function set contextStarlingView(contextStarlingView : starling.display.DisplayObject) : void
		{
			_contextStarlingView = contextStarlingView;
			//add listeners if starling context wasn't defined from the start
			addStarlingListeners();
		}

		// ---------------------------------------------------------------------
		// API
		// ---------------------------------------------------------------------
		/**
		 * @inheritDoc
		 */
		public function mapView(viewClassOrName : *, mediatorClass : Class, injectViewAs : * = null, autoCreate : Boolean = true, autoRemove : Boolean = true) : void
		{
			var viewClassName : String = reflector.getFQCN(viewClassOrName);

			if (mappingConfigByViewClassName[viewClassName] != null)
				throw new ContextError(ContextError.E_MEDIATORMAP_OVR + ' - ' + mediatorClass);

			if (reflector.classExtendsOrImplements(mediatorClass, IMediator) == false)
				throw new ContextError(ContextError.E_MEDIATORMAP_NOIMPL + ' - ' + mediatorClass);

			var config : MappingConfig = new MappingConfig();
			config.mediatorClass = mediatorClass;
			config.autoCreate = autoCreate;
			config.autoRemove = autoRemove;
			if (injectViewAs)
			{
				if (injectViewAs is Array)
				{
					config.typedViewClasses = (injectViewAs as Array).concat();
				}
				else if (injectViewAs is Class)
				{
					config.typedViewClasses = [injectViewAs];
				}
			}
			else if (viewClassOrName is Class)
			{
				config.typedViewClasses = [viewClassOrName];
			}
			mappingConfigByViewClassName[viewClassName] = config;

			if (autoCreate || autoRemove)
			{
				viewListenerCount++;
				if (viewListenerCount == 1)
					addListeners();
			}

			// This was a bad idea - causes unexpected eager instantiation of object graph
			if (autoCreate && contextView && (viewClassName == getQualifiedClassName(contextView) ))
				createMediatorUsing(contextView, viewClassName, config);
		}

		/**
		 * @inheritDoc
		 */
		public function unmapView(viewClassOrName : *) : void
		{
			var viewClassName : String = reflector.getFQCN(viewClassOrName);
			var config : MappingConfig = mappingConfigByViewClassName[viewClassName];
			if (config && (config.autoCreate || config.autoRemove))
			{
				viewListenerCount--;
				if (viewListenerCount == 0)
					removeListeners();
			}
			delete mappingConfigByViewClassName[viewClassName];
		}

		/**
		 * @inheritDoc
		 */
		public function createMediator(viewComponent : Object) : IMediator
		{
			return createMediatorUsing(viewComponent);
		}

		/**
		 * @inheritDoc
		 */
		public function registerMediator(viewComponent : Object, mediator : IMediator) : void
		{
			var mediatorClass : Class = reflector.getClass(mediator);
			injector.hasMapping(mediatorClass) && injector.unmap(mediatorClass);
			injector.mapValue(mediatorClass, mediator);
			mediatorByView[viewComponent] = mediator;
			mappingConfigByView[viewComponent] = mappingConfigByViewClassName[getQualifiedClassName(viewComponent)];
			mediator.setViewComponent(viewComponent);
			mediator.preRegister();
		}

		/**
		 * @inheritDoc
		 */
		public function removeMediator(mediator : IMediator) : IMediator
		{
			if (mediator)
			{
				var viewComponent : Object = mediator.getViewComponent();
				var mediatorClass : Class = reflector.getClass(mediator);
				delete mediatorByView[viewComponent];
				delete mappingConfigByView[viewComponent];
				mediator.preRemove();
				mediator.setViewComponent(null);
				injector.hasMapping(mediatorClass) && injector.unmap(mediatorClass);
			}
			return mediator;
		}

		/**
		 * @inheritDoc
		 */
		public function removeMediatorByView(viewComponent : Object) : IMediator
		{
			return removeMediator(retrieveMediator(viewComponent));
		}

		/**
		 * @inheritDoc
		 */
		public function retrieveMediator(viewComponent : Object) : IMediator
		{
			return mediatorByView[viewComponent];
		}

		/**
		 * @inheritDoc
		 */
		public function hasMapping(viewClassOrName : *) : Boolean
		{
			var viewClassName : String = reflector.getFQCN(viewClassOrName);
			return (mappingConfigByViewClassName[viewClassName] != null);
		}

		/**
		 * @inheritDoc
		 */
		public function hasMediatorForView(viewComponent : Object) : Boolean
		{
			return mediatorByView[viewComponent] != null;
		}

		/**
		 * @inheritDoc
		 */
		public function hasMediator(mediator : IMediator) : Boolean
		{
			for each (var med:IMediator in mediatorByView)
				if (med == mediator)
					return true;
			return false;
		}

		// ---------------------------------------------------------------------
		// Internal
		// ---------------------------------------------------------------------
		/**
		 * @private
		 */
		protected override function addListeners() : void
		{
			if (contextView && enabled)
			{
				contextView.addEventListener(flash.events.Event.ADDED_TO_STAGE, onViewAdded, useCapture, 0, true);
				contextView.addEventListener(flash.events.Event.REMOVED_FROM_STAGE, onViewRemoved, useCapture, 0, true);
			}
			addStarlingListeners();
			
		}
		
		protected function addStarlingListeners() : void {
			if (contextStarlingView && enabled)
			{
				contextStarlingView.addEventListener(starling.events.Event.ADDED, onStarlingViewAdded);
//				contextStarlingView.addEventListener(starling.events.Event.ADDED_TO_STAGE, onStarlingViewAdded);
				contextStarlingView.addEventListener(starling.events.Event.REMOVED_FROM_STAGE, onStarlingViewRemoved);
			}
		}
		
		
		/**
		 * @private
		 */
		protected override function removeListeners() : void
		{
			if (contextView)
			{
				contextView.removeEventListener(flash.events.Event.ADDED_TO_STAGE, onViewAdded, useCapture);
				contextView.removeEventListener(flash.events.Event.REMOVED_FROM_STAGE, onViewRemoved, useCapture);
			}
			removeStarlingListeners();
		}
		
		protected function removeStarlingListeners() : void {
			if (contextStarlingView)
			{
				contextStarlingView.removeEventListener(starling.events.Event.ADDED, onStarlingViewAdded);
//				contextStarlingView.removeEventListener(starling.events.Event.ADDED_TO_STAGE, onStarlingViewAdded);
				contextStarlingView.removeEventListener(starling.events.Event.REMOVED_FROM_STAGE, onStarlingViewRemoved);
			}
			
		}
		
		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::
		// EVENT HANDLERS
		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::
		/**
		 * @private
		 */
		protected function onStarlingViewAdded(e : starling.events.Event) : void
		{
			if (mediatorsMarkedForRemoval[e.target])
			{
				delete mediatorsMarkedForRemoval[e.target];
				return;
			}
			var viewClassName : String = getQualifiedClassName(e.target);
			var config : MappingConfig = mappingConfigByViewClassName[viewClassName];
			if (config && config.autoCreate)
				createMediatorUsing(e.target, viewClassName, config);
		}

		/**
		 * @private
		 */
		protected function onStarlingViewRemoved(e : starling.events.Event) : void
		{
			var config : MappingConfig = mappingConfigByView[e.target];
			if (config && config.autoRemove)
			{
				mediatorsMarkedForRemoval[e.target] = e.target;
				if (!hasMediatorsMarkedForRemoval)
				{
					hasMediatorsMarkedForRemoval = true;
					enterFrameDispatcher.addEventListener(flash.events.Event.ENTER_FRAME, removeMediatorLater);
				}
			}
		}

		/**
		 * @private
		 */
		protected override function onViewAdded(e : flash.events.Event) : void
		{
			if (mediatorsMarkedForRemoval[e.target])
			{
				delete mediatorsMarkedForRemoval[e.target];
				return;
			}
			var viewClassName : String = getQualifiedClassName(e.target);
			var config : MappingConfig = mappingConfigByViewClassName[viewClassName];
			if (config && config.autoCreate)
				createMediatorUsing(e.target, viewClassName, config);
		}

		/**
		 * @private
		 */
		protected function createMediatorUsing(viewComponent : Object, viewClassName : String = '', config : MappingConfig = null) : IMediator
		{
			var mediator : IMediator = mediatorByView[viewComponent];
			if (mediator == null)
			{
				viewClassName ||= getQualifiedClassName(viewComponent);
				config ||= mappingConfigByViewClassName[viewClassName];
				if (config)
				{
					for each (var claxx:Class in config.typedViewClasses)
					{
						injector.mapValue(claxx, viewComponent);
					}
					mediator = injector.instantiate(config.mediatorClass);
					for each (var clazz:Class in config.typedViewClasses)
					{
						injector.unmap(clazz);
					}
					registerMediator(viewComponent, mediator);
				}
			}
			return mediator;
		}

		/**
		 * Flex framework work-around part #5
		 */
		protected function onViewRemoved(e : flash.events.Event) : void
		{
			var config : MappingConfig = mappingConfigByView[e.target];
			if (config && config.autoRemove)
			{
				mediatorsMarkedForRemoval[e.target] = e.target;
				if (!hasMediatorsMarkedForRemoval)
				{
					hasMediatorsMarkedForRemoval = true;
					enterFrameDispatcher.addEventListener(flash.events.Event.ENTER_FRAME, removeMediatorLater);
				}
			}
		}

		/**
		 * Flex framework work-around part #6
		 */
		protected function removeMediatorLater(event : flash.events.Event) : void
		{
			enterFrameDispatcher.removeEventListener(flash.events.Event.ENTER_FRAME, removeMediatorLater);
			// for each (var view:DisplayObject in mediatorsMarkedForRemoval)
			for each (var view:Object in mediatorsMarkedForRemoval)
			{
				if (!view["stage"])
					removeMediatorByView(view);
				delete mediatorsMarkedForRemoval[view];
			}
			hasMediatorsMarkedForRemoval = false;
		}
	}
}
class MappingConfig
{
	public var mediatorClass : Class;
	public var typedViewClasses : Array;
	public var autoCreate : Boolean;
	public var autoRemove : Boolean;
}
