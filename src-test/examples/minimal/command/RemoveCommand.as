package examples.minimal.command
{
    import examples.minimal.views.displayList.ControlsView;
    import examples.minimal.views.starling.QuadView;

    import flash.utils.setTimeout;

    import net.antonstepanov.srobotlegs.mvcs.SCommand;

    import starling.core.Starling;

    /**
     * @author antonstepanov
     * @creation date Apr 3, 2013
     */
    public class RemoveCommand extends SCommand
    {
        override public function execute():void
        {
            setTimeout(remove, 1000 * 5)
        }

        private function remove():void
        {
            starlingView.removeChildren();
            contextView.removeChildren();
        }

    }
}
