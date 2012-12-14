package components 
{
	import away3d.loaders.parsers.OBJParser;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix3D;
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class Particle3D extends Stage3DEntity 
	{
		public var active:Boolean = true;
		public var age:uint = 0;
		public var ageMax:uint = 1000;
		public var stepCounter:uint = 0;
		
		private var mesh2:OBJParser;
		private var ageScale:Vector.<Number> = new Vector.<Number>([1, 0, 1, 1]);
		private var rgbaScale:Vector.<Number> = new Vector.<Number>([1, 1, 1, 1]);
		private var startSize:Number = 0;
		private var endSize:Number = 1;
		
		private static var particleshadermesh1:Program3D = null;
		private static var particleshadermesh2:Program3D = null;
		
		
		public function Particle3D(mydata:Class = null, mycontext:Context3D = null, myTexture:Texture = null, mydata2:Class = null) 
		{
			transform = new Matrix3D();
			context = mycontext;
			texture = myTexture;
			
			if (context && mydata2)
				initParticleShader(true);
			else if (context)
				initParticleShader(false);
				
			if (mydata && context)
			{
				mesh = new ObjParser(mydata, context, 1, false, true);
				polycount = mesh.indexBufferCount;
				trace(polycount + " poligons.");
			}
			
			if (mydata2 && context)
				mesh2 = new OBJParser(mydata2, context, 1, false, true);
				
			blendScr = Context3DBlendFactor.ONE;		
			blendDst = Context3DBlendFactor.ONE;	
			cullingMode = Context3DTriangleFace.NONE;
			depthTestMode = Context3DCompareMode.ALWAYS;
			depthTest = false;
		}
		
	}

}