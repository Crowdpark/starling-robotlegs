package examples.minimal.views.displayList
{
    import org.robotlegs.mvcs.Mediator;

    import flash.events.DataEvent;
    import flash.events.Event;

    /**
     * @author antonstepanov
     * @creation date Apr 3, 2013
     */
    public class ControlsViewMediator extends Mediator
    {

        [Inject]
        public var view:ControlsView;

        override public function onRegister():void
        {
            addViewListener(Event.CHANGE, changeHandler);

            addContextListener("LOG_TOUCH_ACTIONS", logHandler);
            addContextListener("UDDATE_QUADVIEW_MOUSE_STATE", mouseStateHandler);
        }

        private function mouseStateHandler(e:DataEvent):void
        {
            view.setBtnLabel(e.data);
        }

        private function logHandler(e:DataEvent):void
        {
            view.addLog(e.data);
        }

        private function changeHandler(e:Event):void
        {
            dispatch(new Event("SWITCH_STARLING_TOUCH_STATE"));
        }

    }
}
