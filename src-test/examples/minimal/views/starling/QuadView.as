package examples.minimal.views.starling
{
    import starling.display.Quad;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;

    /**
     * @author antonstepanov
     * @creation date Apr 3, 2013
     */
    public class QuadView extends Sprite
    {

        private var q:Quad;

        private var _mouseEnabled:Boolean = false;

        public function QuadView()
        {
            init();
            mouseEnabled = true;
        }

        //::::::::::::::::::::::::::::::::::::::::::::::::::::::
        //SETTERS AND GETTERS
        //::::::::::::::::::::::::::::::::::::::::::::::::::::::

        public function get mouseEnabled():Boolean
        {
            return _mouseEnabled;
        }

        public function set mouseEnabled(mouseEnabled:Boolean):void
        {
            _mouseEnabled = mouseEnabled;
            updateMouseState();
        }

        //::::::::::::::::::::::::::::::::::::::::::::::::::::::
        //PUBLIC FUNCTIONS
        //::::::::::::::::::::::::::::::::::::::::::::::::::::::

        //::::::::::::::::::::::::::::::::::::::::::::::::::::::
        //PRIVATE FUNCTIONS
        //::::::::::::::::::::::::::::::::::::::::::::::::::::::
        private function init():void
        {
            q = new Quad(200, 200);
            q.setVertexColor(0, 0x000000);
            q.setVertexColor(1, 0xAA0000);
            q.setVertexColor(2, 0x00FF00);
            q.setVertexColor(3, 0x0000FF);
            addChild(q);

        }

        private function updateMouseState():void
        {
            if (mouseEnabled)
            {
                q.addEventListener(TouchEvent.TOUCH, touchHandler);
            }
            else
            {
                q.removeEventListener(TouchEvent.TOUCH, touchHandler);
            }
        }

        //::::::::::::::::::::::::::::::::::::::::::::::::::::::
        //EVENT HANDLERS
        //::::::::::::::::::::::::::::::::::::::::::::::::::::::
        private function touchHandler(e:TouchEvent):void
        {
            //get all touch info into one String
            var touchLogStr:String = "";
            var n:int = e.data.length;
            for (var i:int = 0; i < n; i++)
            {
                touchLogStr += Touch(e.data[i]).phase + " x:" + Touch(e.data[i]).globalX + " y:" + Touch(e.data[i]).globalY + ",";
            }

            //dispatch starling.event
            var updateEvent:QuadViewEvent = new QuadViewEvent(QuadViewEvent.UPDATE);
            updateEvent.updateMessage = touchLogStr;
            dispatchEvent(updateEvent);
        }
    }
}
