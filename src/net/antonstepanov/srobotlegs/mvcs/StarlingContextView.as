package net.antonstepanov.srobotlegs.mvcs
{
	import starling.display.Sprite;

	/**
	 * @author antonstepanov
	 * @creation date Jul 4, 2012
	 */
	public class StarlingContextView extends Sprite
	{
		private static var _instance : StarlingContextView;
		
		public  var theme : *;

		public function StarlingContextView()
		{
			_instance = this;
		}
		
		public static function get instance() : StarlingContextView
		{
			return _instance;
		}

		
	}
}
