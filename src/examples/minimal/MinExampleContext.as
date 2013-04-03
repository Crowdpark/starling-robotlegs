package examples.minimal
{
	import examples.minimal.command.StartupCommand;
	import examples.minimal.views.displayList.ControlsView;
	import examples.minimal.views.displayList.ControlsViewMediator;
	import examples.minimal.views.starling.QuadView;
	import examples.minimal.views.starling.QuadViewMediator;

	import net.antonstepanov.srobotlegs.mvcs.SContext;

	import org.robotlegs.base.ContextEvent;

	import flash.display.DisplayObjectContainer;

	/**
	 * @author antonstepanov
	 * @creation date Apr 3, 2013
	 */
	public class MinExampleContext extends SContext
	{
		public function MinExampleContext(contextView : DisplayObjectContainer = null, autoStartup : Boolean = true)
		{
			super(contextView, autoStartup);
		}
		
		
		
		override public function startup() : void
		{
			
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, StartupCommand);
			
			/*
			 * QuadViewMediator must extend from SMediator for view componet events
			 */
			mediatorMap.mapView(QuadView, QuadViewMediator);
			
			/*
			 * ControlsViewMediator can extend normal RL mediator
			 */
			mediatorMap.mapView(ControlsView, ControlsViewMediator);
			
			
			super.startup();
		}
	}
}
