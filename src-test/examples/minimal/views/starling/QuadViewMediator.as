package examples.minimal.views.starling
{
    import net.antonstepanov.srobotlegs.mvcs.SMediator;

    import flash.events.DataEvent;
    import flash.events.Event;

    /**
     * @author antonstepanov
     * @creation date Apr 3, 2013
     */
    public class QuadViewMediator extends SMediator
    {

        [Inject]
        public var view:QuadView;

        override public function onRegister():void
        {
            //listen to starling.event from view
            addViewListener(QuadViewEvent.UPDATE, quadViewUpdateHandler);

            //listen to flash.event from context
            addContextListener("SWITCH_STARLING_TOUCH_STATE", switchStateHandler);
        }

        override public function onRemove():void
        {
            trace("--->QuadViewMediator.onRemove(",[],")");
        }

        private function quadViewUpdateHandler(e:QuadViewEvent):void
        {
            dispatch(new DataEvent("LOG_TOUCH_ACTIONS", false, false, e.updateMessage));
        }

        private function switchStateHandler(e:Event):void
        {
            view.mouseEnabled = !view.mouseEnabled;

            dispatch(new DataEvent("UDDATE_QUADVIEW_MOUSE_STATE", false, false, String(view.mouseEnabled)));

        }

    }
}
