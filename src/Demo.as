package 
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.adobe.utils.PerspectiveMatrix3D;
	import components.ObjParser;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	[SWF(width = "640", height = "480", frameRate = "60", backgroundColor = "#808080")]
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class Demo extends Sprite 
	{
		private var fpsLast:uint = getTimer();
		private var fpsTicks:uint = 0;
		private var fpsTf:TextField;
		
		private var drTf:TextField;
		
		private var scoreTf:TextField;
		private var score:uint = 0;
		
		private const swfWidth:int = 640;
		private const swfHeight:int = 480;
		private const textureSize:int = 512;
		
		private var context3D:Context3D;
		
		private var shaderProgram1:Program3D;
		private var shaderProgram2:Program3D;
		private var shaderProgram3:Program3D;
		private var shaderProgram4:Program3D;
		
		private var vertexBuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
		
		private var meshVertexData:Vector.<Number>;
		private var meshIndexData:Vector.<uint>;
		
		private var projectionMatrix:PerspectiveMatrix3D = new PerspectiveMatrix3D();
		private var modelMatrix:Matrix3D = new Matrix3D();
		private var viewMatrix:Matrix3D = new Matrix3D();
		private var terrainviewmatrix:Matrix3D = new Matrix3D();
		private var modelViewProjection:Matrix3D = new Matrix3D(); 
		
		private var t:Number = 0;
		private var looptemp:int = 0;
		
		//Ship Texture
		[Embed(source="../lib/ship.png")]
		private var myTextureBitmap:Class;
		private var myTextureData:Bitmap = new myTextureBitmap();
		
		
		
		
		////////////
		////////////
		//Cluster
		[Embed(source = "../lib/cluster.obj", mimeType = "application/octet-stream")]
		private var myObjData1:Class;
		
		private var myMesh1:ObjParser;
		private var myMesh2:ObjParser;
		private var myMesh3:ObjParser;
		private var myMesh4:ObjParser;
		private var myMesh5:ObjParser;
		
		//Leaf Texture
		[Embed(source="../lib/leaf.png")]
		private var myTextureBitmap1:Class;
		private var myTextureData1:Bitmap = new myTextureBitmap1();
		
		//Fire Texture
		[Embed(source="../lib/fire.jpg")]
		private var myTextureBitmap2:Class;
		private var myTextureData2:Bitmap = new myTextureBitmap2();
		
		//Flare Texture
		[Embed(source="../lib/flare.jpg")]
		private var myTextureBitmap3:Class;
		private var myTextureData3:Bitmap = new myTextureBitmap3();
		
		//Glow Texture
		[Embed(source="../lib/glow.jpg")]
		private var myTextureBitmap4:Class;
		private var myTextureData4:Bitmap = new myTextureBitmap4();
		
		//Smoke Texture
		[Embed(source="../lib/smoke.jpg")]
		private var myTextureBitmap5:Class;
		private var myTextureData5:Bitmap = new myTextureBitmap5();
		
		
		
		private var blendNum:int = -1;
		private var blendNumMax:int = 4;
		private var texNum:int = -1;
		private var texNumMax:int = 4;
		private var meshNum:int = 0;
		private var meshNumMax:int = 4;
		
		private var label1_:TextField;
		private var label2_:TextField;
		private var label3_:TextField;
		
		
		
		private var myTexture1:Texture;
		private var myTexture2:Texture;
		private var myTexture3:Texture;
		private var myTexture4:Texture;
		private var myTexture5:Texture;
		private var myTexture6:Texture;
		///////////////////////
		/////////////////////
		
		
		
		//Terrain Texture
		[Embed(source="../lib/terrain.png")]
		private var terrainTextureBitmap:Class;
		private var terrainTextureData:Bitmap = new terrainTextureBitmap();
		
		private var myTexture:Texture;
		private var terrainTexture:Texture;
		
		//Ship Mesh Data
		[Embed(source = "../lib/ship.obj", mimeType = "application/octet-stream")]
		private var myObjData:Class;
		private var myMesh:ObjParser;
		
		//Ship Mesh Data
		[Embed(source="../lib/terrain.obj", mimeType="application/octet-stream")]
		private var terrainObjData:Class;
		private var terrainMesh:ObjParser;
		private var myCubeTexture:Texture;
		
		
		public function Demo():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			if (hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, stage_resize);
			
			initGUI();
			
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
			stage.stage3Ds[0].requestContext3D();
		}
		
		private function initGUI():void 
		{
			var myFormat:TextFormat = new TextFormat();
			myFormat.color = 0xffffff;
			myFormat.size = 13;
			
			fpsTf = new TextField()
			fpsTf.x = 0;
			fpsTf.y = 0;
			fpsTf.selectable = false;
			fpsTf.autoSize = TextFieldAutoSize.LEFT;
			fpsTf.defaultTextFormat = myFormat;
			fpsTf.text = "Initializing Stage3D...";
			addChild(fpsTf);
			
			scoreTf = new TextField();
			scoreTf.x = 560;
			scoreTf.y = 0;
			scoreTf.selectable = false;
			scoreTf.autoSize = TextFieldAutoSize.LEFT;
			scoreTf.defaultTextFormat = myFormat;
			scoreTf.text = ("000000");
			addChild(scoreTf);
			
			drTf = new TextField()
			drTf.x = swfWidth * .5;
			drTf.y = 0;
			drTf.selectable = false;
			drTf.autoSize = TextFieldAutoSize.LEFT;
			drTf.defaultTextFormat = myFormat;
			drTf.text = "Ready Context3D...";
			addChild(drTf);
			
			var label1:TextField = new TextField();
			label1.x = 100;
			label1.y = 180;
			label1.selectable = false;
			label1.autoSize = TextFieldAutoSize.LEFT;
			label1.defaultTextFormat = myFormat;
			label1.text = "Shader 1: Textured";
			//addChild(label1);
			
			var label2:TextField = new TextField();
			label2.x = 400;
			label2.y = 180;
			label2.selectable = false;
			label2.autoSize = TextFieldAutoSize.LEFT;
			label2.defaultTextFormat = myFormat;
			label2.text = "Shader 2: Vertex RGB";
			//addChild(label2);
			
			var label3:TextField = new TextField();
			label3.x = 80;
			label3.y = 440;
			label3.selectable = false;
			label3.autoSize = TextFieldAutoSize.LEFT;
			label3.defaultTextFormat = myFormat;
			label3.text = "Shader 3: Vertex RGB + Textured";
			//addChild(label3);
			
			var label4:TextField = new TextField();
			label4.x = 340;
			label4.y = 440;
			label4.selectable = false;
			label4.autoSize = TextFieldAutoSize.LEFT;
			label4.defaultTextFormat = myFormat;
			label4.text = "Shader 4: Textured + setProgramConstants";
			//addChild(label4);
			
			label1_ = new TextField()
			label1_.x = 100;
			label1_.y = 50;
			label1_.selectable = false;
			label1_.autoSize = TextFieldAutoSize.LEFT;
			label1_.defaultTextFormat = myFormat;
			label1_.text = "///////B";
			addChild(label1_);
			
			label2_ = new TextField()
			label2_.x = 100;
			label2_.y = 70;
			label2_.selectable = false;
			label2_.autoSize = TextFieldAutoSize.LEFT;
			label2_.defaultTextFormat = myFormat;
			label2_.text = "///////M";
			addChild(label2_);
			
			label3_ = new TextField()
			label3_.x = 100;
			label3_.y = 90;
			label3_.selectable = false;
			label3_.autoSize = TextFieldAutoSize.LEFT;
			label3_.defaultTextFormat = myFormat;
			label3_.text = "///////T";
			addChild(label3_);
		}
		
		private function updateScore():void
		{
			var str:String;
			score++;
			if (score < 10)
				str = "Score: 00000" + score.toString();
			else if (score < 100)
				str = "Score: 0000" + score.toString();
			else if (score < 1000)
				str = "Score: 000" + score.toString();
			else if (score < 10000)
				str = "Score: 00" + score.toString();
			else if (score < 100000)
				str = "Score: 0" + score.toString();
			else
				str = "Score: " + score.toString();
				
			scoreTf.text = str;	
		}
		
		private function onContext3DCreate(e:Event):void 
		{
			removeEventListener(Event.ENTER_FRAME,enterFrame);
			
			var t:Stage3D = e.target as Stage3D;
			context3D = t.context3D;
			
			if (context3D == null)
				return;
			
			drTf.text = context3D.driverInfo + " driver";
			context3D.enableErrorChecking = true;
			
			initData();
			
			context3D.configureBackBuffer(swfWidth, swfHeight, 2, true);
			
			initShaders();
			
			//
			myTexture1 = context3D.createTexture(myTextureData1.width, myTextureData1.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(myTexture1, myTextureData1.bitmapData);
			
			myTexture2 = context3D.createTexture(myTextureData2.width, myTextureData2.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(myTexture2, myTextureData2.bitmapData);
			
			myTexture3 = context3D.createTexture(myTextureData3.width, myTextureData3.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(myTexture3, myTextureData3.bitmapData);
			
			myTexture4 = context3D.createTexture(myTextureData4.width, myTextureData4.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(myTexture4, myTextureData4.bitmapData);
			
			myTexture5 = context3D.createTexture(myTextureData5.width, myTextureData5.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(myTexture5, myTextureData5.bitmapData);
			
			
			
			myTexture = context3D.createTexture(textureSize, textureSize, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(myTexture, myTextureData.bitmapData);
			
			terrainTexture = context3D.createTexture(textureSize, textureSize, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(terrainTexture, terrainTextureData.bitmapData);
				
			projectionMatrix.identity();
			projectionMatrix.perspectiveFieldOfViewRH(45.0, swfWidth / swfHeight, 0.01, 5000);
			
			viewMatrix.identity();
			viewMatrix.appendTranslation(0, 0, -3);
			
			//terrainviewmatrix.identity();
			//terrainviewmatrix.appendRotation( -60, Vector3D.X_AXIS);
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
		}
		
		private function stage_keyDown(e:KeyboardEvent):void 
		{
			switch (e.keyCode)
			{
				case 66:   //B
					nextBlendmode();
					break;
				case 77:  //M
					nextMesh();
					break;
				case 84:  //T
					nextTexture();
					break;
			}
		}
		
		private function nextBlendmode():void 
		{
			blendNum++;
			if (blendNum > blendNumMax)
				blendNum = 0;
			switch(blendNum)
			{
				case 0:
					label1_.text = "[B] ONE, ZERO";
					break;
				case 1:
					label1_.text = "[B] SOURCE_ALPHA, ONE_MINUS_SOURSE_ALPHA";
					break;
				case 2:
					label1_.text = "[B] SOURCE_COLOR, ONE";
					break;
				case 3:
					label1_.text = "[B] ONE, ONE";
					break;
				case 4:
					label1_.text = "[B] DESTANETION_COLOR, ZERO";
					break;
			}	
		}
		
		private function nextMesh():void 
		{
			meshNum++;
			if (meshNum > meshNumMax)
				meshNum = 0;
			switch(meshNum)
			{
				case 0:
					label3_.text = "[M] Random Particle Cluster";
					break;
				case 1:
					label3_.text = "[M] Round Puff Cluster";
					break;
				case 2:
					label3_.text = "[M] Cube Model";
					break;
				case 3:
					label3_.text = "[M] Sphere Model";
					break;
				case 4:
					label3_.text = "[M] Spaceship Model";
					break;
			}
		}
		
		private function nextTexture():void 
		{
			texNum++;
			if (texNum > texNumMax)
				texNum = 0;
			switch (texNum)
			{
				case 0:
					label2_.text = "[T] Transparent Leaf Texture";
					break;
				case 1:
					label2_.text = "[T] Fire Texture";
					break;
				case 2:
					label2_.text = "[T] Lens Flare Texture";
					break;
				case 3:
					label2_.text = "[T] Glow Texture";
					break;
				case 4:
					label2_.text = "[T] Smoke Texture";
					break;
			}
		}
		
		
		
		public function uploadTextureWithMipmaps(dest:Texture, scr:BitmapData):void
		{
			var ws:int = scr.width;
			var hs:int = scr.height;
			var level: int = 0;
			var tmp:BitmapData;
			var transform:Matrix = new Matrix();
			tmp = new BitmapData(ws, hs, true, 0x00000000);
			while (ws >= 1 && hs >= 1)
			{
				tmp.draw(scr, transform, null, null, null, true);
				dest.uploadFromBitmapData(tmp, level);
				transform.scale(0.5, 0.5);
				level++;
				ws >>= 1;
				hs >>= 1;
				if (ws && hs)
				{
					tmp.dispose();
					tmp = new BitmapData(ws, hs, true, 0x00000000);
				}
			}
			tmp.dispose();
		}
		
		private function initData():void 
		{
			//Parse Ship and Terrain
			myMesh1 = new ObjParser(myObjData1, context3D, 0.2, false, true);
			myMesh2 = new ObjParser(myObjData1, context3D, 0.2, false, true);
			myMesh3 = new ObjParser(myObjData1, context3D, 0.2, false, true);
			myMesh4 = new ObjParser(myObjData1, context3D, 0.2, false, true);
			myMesh5 = new ObjParser(myObjData, context3D, 0.2, false, true);
			
			terrainMesh = new ObjParser(terrainObjData, context3D, 2, true, true);
		}
		
		private function initShaders():void 
		{
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			vertexShaderAssembler.assemble
			(
				Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" +		//coordinates of each vertex to match the camera to Output Pos
				"mov v0, va0\n" +			//XYZ to frag shader 
				"mov v1, va1\n" +			//UV to frag shader
				"mov v2, va2\n"				//RGBA to frag shader
			);
			
			var fragmentShaderAssembler1:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler1.assemble
			(
				Context3DProgramType.FRAGMENT,
				"tex ft0, v1, fs0 <2d,repeat,miplinear>\n" +	// grab the texture color from texture 0 and uv coordinates from v1
				"mov oc, ft0\n"									//store interpolated value to the Output Color
			);
			
			shaderProgram1 = context3D.createProgram();
			shaderProgram1.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler1.agalcode);
		}
		
		private function enterFrame(e:Event):void 
		{
			
			context3D.clear(0, 0, 0);
			
			t += 1.0;
			
			renderTerrain();
			
			renderMesh();
			
			context3D.present();
				
			//FPS
			fpsTicks++;
			var now:uint = getTimer();
			var delta:uint = now - fpsLast;
			if (delta >= 1000)
			{
				var fps:Number = fpsTicks / delta * 1000;
				fpsTf.text = fps.toFixed(1) + " fps";
				fpsTicks = 0;
				fpsLast = now;
			}
			
			updateScore();
		}
		
		private function renderMesh():void 
		{
			if (blendNum > 1)
				context3D.setDepthTest(false, Context3DCompareMode.LESS);
			else
				context3D.setDepthTest(true, Context3DCompareMode.LESS);
				
			modelMatrix.identity();
			context3D.setProgram(shaderProgram1);
			setTexture();
			setBlendmode();
			modelMatrix.appendRotation(t * 0.7, Vector3D.Y_AXIS);
			modelMatrix.appendRotation(t * 0.6, Vector3D.X_AXIS);
			modelMatrix.appendRotation(t * 1.0, Vector3D.Z_AXIS);
			
			modelViewProjection.identity();
			modelViewProjection.append(modelMatrix);
			modelViewProjection.append(viewMatrix);
			modelViewProjection.append(projectionMatrix);
			
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, modelViewProjection, true);
			
			switch(meshNum)
			{
				case 0:
					myMesh = myMesh1;
					break;
				case 1:
					myMesh = myMesh2;
					break;
				case 2:
					myMesh = myMesh3;
					break;
				case 3:
					myMesh = myMesh4;
					break;
				case 4:
					myMesh = myMesh5;
					break;
			}
			
			context3D.setVertexBufferAt(0, myMesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			context3D.setVertexBufferAt(1, myMesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(2, myMesh.colorsBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
			
			context3D.drawTriangles(myMesh.indexBuffer, 0, myMesh.indexBufferCount);
			
		}
		
		private function setTexture():void 
		{
			switch(texNum)
			{
				case 0:
					context3D.setTextureAt(0, myTexture1);
					break;
				case 1:
					context3D.setTextureAt(0, myTexture2);
					break;
				case 2:
					context3D.setTextureAt(0, myTexture3);
					break;
				case 3:
					context3D.setTextureAt(0, myTexture4);
					break;
				case 4:
					context3D.setTextureAt(0, myTexture5);
					break;
				case 5:
					context3D.setTextureAt(0, myCubeTexture);
			}
		}
		
		private function setBlendmode():void 
		{
			switch(blendNum)
			{
				case 0:
					context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
					break;
				case 1:
					context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
					break;
				case 2:
					context3D.setBlendFactors(Context3DBlendFactor.SOURCE_COLOR, Context3DBlendFactor.ONE);
					break;
				case 3:
					context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
					break;
				case 4:
					context3D.setBlendFactors(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ZERO);
					break;
					
			}
		}
		
		private function renderTerrain():void
		{
			context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			context3D.setDepthTest(true, Context3DCompareMode.LESS);
			
			context3D.setTextureAt(0, terrainTexture);
			context3D.setProgram(shaderProgram1);
			
			//Position
			context3D.setVertexBufferAt(0, terrainMesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			//UV
			context3D.setVertexBufferAt(1, terrainMesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			//RGBA
			context3D.setVertexBufferAt(2, terrainMesh.colorsBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
			
			modelMatrix.identity();
			modelMatrix.appendRotation( -90, Vector3D.Y_AXIS);
			
			modelMatrix.appendTranslation(Math.cos(t / 600) * 200, 0, Math.cos(t / 600) * 100);
			
			modelViewProjection.identity();
			modelViewProjection.append(modelMatrix);
			modelViewProjection.append(terrainviewmatrix);
			modelViewProjection.append(projectionMatrix);
			
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, modelViewProjection, true);
			context3D.drawTriangles(terrainMesh.indexBuffer, 0, terrainMesh.indexBufferCount);
			
		}
		
		private function stage_resize(e:Event):void 
		{
			this.width = stage.stageWidth;
			this.height = stage.stageHeight;
			if (this.scaleY > this.scaleX)
				this.scaleY = this.scaleX;
			else
				this.scaleX = this.scaleY;
			
			this.x = (stage.stageWidth - this.width) / 2;
			this.y = (stage.stageHeight - this.height) / 2;
			context3D.configureBackBuffer(this.width, this.height, 0, true);
			stage.stage3Ds[0].x = this.x;
			stage.stage3Ds[0].y = this.y;
		}
		
	}
	
}