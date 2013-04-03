package examples.minimal
{
	import flash.display.Sprite;

	/**
	 * @author antonstepanov
	 * @creation date Apr 3, 2013
	 */
	[SWF(backgroundColor="#a6a6a6", frameRate="31", width="640", height="480")]
	public class MinExampleMain extends Sprite
	{
		
		private var context:MinExampleContext;
		
		public function MinExampleMain()
		{
			
			context=new MinExampleContext(this);
			
		}
	}
}
