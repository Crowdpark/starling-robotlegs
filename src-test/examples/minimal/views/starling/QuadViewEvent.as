package examples.minimal.views.starling
{
    import starling.events.Event;

    /**
     * @author antonstepanov
     * @creation date Apr 3, 2013
     */
    public class QuadViewEvent extends Event
    {

        public static const UPDATE:String = "QuadViewEvent.UPDATE";

        public var updateMessage:String;

        public function QuadViewEvent(type:String, bubbles:Boolean = false, data:Object = null)
        {
            super(type, bubbles, data);
        }
    }
}
