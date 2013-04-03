package examples.minimal.command
{
	import examples.minimal.views.displayList.ControlsView;
	import examples.minimal.views.starling.QuadView;

	import net.antonstepanov.srobotlegs.mvcs.SCommand;

	import starling.core.Starling;

	/**
	 * @author antonstepanov
	 * @creation date Apr 3, 2013
	 */
	public class StartupCommand extends SCommand
	{
		
		
		
		override public function execute() : void
		{
			Starling.current.showStats=true;
			
			//
			//INIT DISPLAY LIST VIEWS
			//
			
			var controls:ControlsView=new ControlsView();
			controls.y=210;
			contextView.addChild(controls);
			
			//
			//INIT STARLING VIEWS
			//
			starlingView.addChild(new QuadView());
			
			
		}
		
	}
}
