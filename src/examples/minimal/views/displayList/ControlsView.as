package examples.minimal.views.displayList
{
	import com.bit101.components.VBox;
	import com.bit101.components.TextArea;
	import flash.events.Event;
	import com.bit101.components.PushButton;
	import flash.display.Sprite;

	/**
	 * @author antonstepanov
	 * @creation date Apr 3, 2013
	 */
	public class ControlsView extends Sprite
	{
		
		private var btn:PushButton;
		private var btnLabelBase:String="Starling Touch Events:";
		
		private var logWindow:TextArea;
		
		public function ControlsView()
		{
			init();
		}

		
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//SETTERS AND GETTERS
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//PUBLIC FUNCTIONS
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::
		public function addLog(msg:String):void {
			logWindow.text+=msg+"\n";
			logWindow.draw();
			logWindow.textField.scrollV=logWindow.textField.maxScrollV;
		}
		
		public function setBtnLabel(state:String):void 
		{
			btn.label=btnLabelBase+state;
			
		}
		
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//PRIVATE FUNCTIONS
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::
		private function init() : void
		{
			var box:VBox=new VBox(this);
			btn=new PushButton(box,0,0,btnLabelBase,btnHandler);
			btn.width=150;
			logWindow=new TextArea(box);
			
		}

		//::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//EVENT HANDLERS
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::		
		private function btnHandler(e:Event) : void
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
	}
}
