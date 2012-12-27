package components 
{
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class GameActorpool 
	{
		private var allNames:Vector.<String>;
		private var allKinds:Dictionary;
		private var allActors:Dictionary;
		
		private var actor:GameActor;
		private var actorList:Vector.<GameActor>;
		
		public var actorCreated:uint = 0;
		public var actorActive:uint = 0;
		public var totalpolycount:uint = 0;
		public var totalrendered:uint = 0;
		
		
		public var active:Boolean = true;
		public var visible:Boolean = true;
		
		public function GameActorpool() 
		{
			allKinds = new Dictionary();
			allActors = new Dictionary();
			allNames = new Vector.<String>;
		}
		
		public function defineActor(name:String, cloneSource:GameActor):void
		{
			allKinds[name] = cloneSource;
			allNames.push(name);
		}
		
		public function step(ms:uint, collisionDetection:Function = null, collisionReaction:Function = null):void
		{
			if (!active)
				return;
				
			actorActive = 0;
			for each (actorList in allActors)
			{
				for each (actor in actorList)
				{
					if (actor.active)
					{
						actorActive++;
						actor.step(ms);
						
						if (actor.collides && (collisionDetection != null))
						{
							actor.touching = collisionDetection(actor);
							if (actor.touching && collisionReaction != null)
								collisionReaction(actor, actor.touching);
						}
					}
				}
			}
		}
		
		public function render(view:Matrix3D, projection:Matrix3D):void
		{
			if (!visible)
				return;
				
			totalpolycount = 0;
			totalrendered = 0;
			
			var stateGhange:Boolean = true;
			
			for each (actorList in allActors)
			{
				for each (actor in actorList)
				{
					if (actor.active && actor.visible)
					{
						totalpolycount += actor.polycount;
						totalrendered++;
						actor.render(view, projection, stateGhange);
					}
				}
			}
		}
		
		public function spawn(shootName:String, transform:Matrix3D):GameActor 
		{
			return new GameActor();
		}
		
	}

}