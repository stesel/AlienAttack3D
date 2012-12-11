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
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	[SWF(width = "762", height = "480", frameRate = "60", backgroundColor = "#808080")]
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class Demo1 extends Sprite 
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
		[Embed(source="../lib/craters.jpg")]
		private var myTextureBitmap:Class;
		private var myTextureData:Bitmap = new myTextureBitmap();
		
		//Terrain Texture
		[Embed(source="../lib/terrain.png")]
		private var terrainTextureBitmap:Class;
		private var terrainTextureData:Bitmap = new terrainTextureBitmap();
		
		private var myTexture:Texture;
		private var terrainTexture:Texture;
		
		//Ship Mesh Data
		[Embed(source="../lib/asteroids.obj", mimeType="application/octet-stream")]
		private var myObjData:Class;
		private var myMesh:ObjParser;
		
		//Ship Mesh Data
		[Embed(source="../lib/terrain.obj", mimeType="application/octet-stream")]
		private var terrainObjData:Class;
		private var terrainMesh:ObjParser;
		
		
		public function Demo1():void 
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
			addChild(label1);
			
			var label2:TextField = new TextField();
			label2.x = 400;
			label2.y = 180;
			label2.selectable = false;
			label2.autoSize = TextFieldAutoSize.LEFT;
			label2.defaultTextFormat = myFormat;
			label2.text = "Shader 2: Vertex RGB";
			addChild(label2);
			
			var label3:TextField = new TextField();
			label3.x = 80;
			label3.y = 440;
			label3.selectable = false;
			label3.autoSize = TextFieldAutoSize.LEFT;
			label3.defaultTextFormat = myFormat;
			label3.text = "Shader 3: Vertex RGB + Textured";
			addChild(label3);
			
			var label4:TextField = new TextField();
			label4.x = 340;
			label4.y = 440;
			label4.selectable = false;
			label4.autoSize = TextFieldAutoSize.LEFT;
			label4.defaultTextFormat = myFormat;
			label4.text = "Shader 4: Textured + setProgramConstants";
			addChild(label4);
			
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
			
			myTexture = context3D.createTexture(128, 128, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(myTexture, myTextureData.bitmapData);
			
			terrainTexture = context3D.createTexture(textureSize, textureSize, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(terrainTexture, terrainTextureData.bitmapData);
				
			projectionMatrix.identity();
			projectionMatrix.perspectiveFieldOfViewRH(45.0, swfWidth / swfHeight, 0.01, 5000);
			
			viewMatrix.identity();
			viewMatrix.appendTranslation(0, 0, -3);
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
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
			myMesh = new ObjParser(myObjData, context3D, 0.2, false, true);
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
			
			
			var vertexShaderAssembler2:AGALMiniAssembler = new AGALMiniAssembler();
			
			vertexShaderAssembler2.assemble
			(
				Context3DProgramType.VERTEX,
				"m44 vt0, va0, vc0\n" +		//coordinates of each vertex to match the camera to Output Pos
				"add vt1, vt0, vc2\n" +
				"mov op, vt1\n" + 
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
			
			var fragmentShaderAssembler2:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler2.assemble
			(
				Context3DProgramType.FRAGMENT,
				"mov oc, v2\n"				//grab RGBA form v2 to Output Color
			);
			
			var fragmentShaderAssembler3:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler3.assemble
			(
				Context3DProgramType.FRAGMENT,
				"tex ft0, v1, fs0 <2d,repeat,miplinear>\n" +	//grab the texture color from texture 0 and uv coordinates from v1
				"mul ft1, v2, ft0\n" +							//multiply by the value stored in v2(RGBA)
				"mov oc, ft1\n"									//move ft1 to oc
			);
			
			var fragmentShaderAssembler4:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler4.assemble
			(
				Context3DProgramType.FRAGMENT,
				"tex ft0 v1, fs <2d,repeat,miplinear>\n" +
				"add ft1, ft0, fc0\n" +
				"mov oc, ft1\n"
			);
			
			shaderProgram1 = context3D.createProgram();
			shaderProgram1.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler1.agalcode);
			
			shaderProgram2 = context3D.createProgram();
			shaderProgram2.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler2.agalcode);
			
			shaderProgram3 = context3D.createProgram();
			shaderProgram3.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler3.agalcode);
			
			shaderProgram4 = context3D.createProgram();
			shaderProgram4.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler4.agalcode);
		}
		
		private function enterFrame(e:Event):void 
		{
			
			context3D.clear(0, 0, 0);
			
			t += 1.0;
			
			renderTerrain();
			
			var dist:Number = 0.8;
			for (looptemp = 0; looptemp < 4; looptemp++)
			{
				modelMatrix.identity();
				switch(looptemp)
				{
					case 0:
						context3D.setTextureAt(0, myTexture);
						context3D.setProgram(shaderProgram1);
						modelMatrix.appendRotation(t * 0.7, Vector3D.Y_AXIS);
						modelMatrix.appendRotation(t * 0.6, Vector3D.X_AXIS);
						modelMatrix.appendRotation(t * 1.0, Vector3D.Y_AXIS);
						modelMatrix.appendTranslation( -dist, dist, 0);
						break;
					case 1:
						context3D.setTextureAt(0, null);
						context3D.setProgram(shaderProgram2);
						modelMatrix.appendRotation(t * - 0.2, Vector3D.Y_AXIS);
						modelMatrix.appendRotation(t * 0.4, Vector3D.X_AXIS);
						modelMatrix.appendRotation(t * 0.7, Vector3D.Y_AXIS);
						modelMatrix.appendTranslation(dist, dist, 0);
						break;
					case 2:
						context3D.setTextureAt(0, myTexture);
						context3D.setProgram(shaderProgram3);
						modelMatrix.appendRotation(t * 1.0, Vector3D.Y_AXIS);
						modelMatrix.appendRotation(t * 0.2, Vector3D.X_AXIS);
						modelMatrix.appendRotation(t * 0.3, Vector3D.Y_AXIS);
						modelMatrix.appendTranslation( -dist, -dist, 0);
						break;
					case 3:
						context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([1, Math.abs(Math.cos(t / 50)) * 0.4, 0, 5]));
						context3D.setTextureAt(0, myTexture);
						context3D.setProgram(shaderProgram4);
						modelMatrix.appendRotation(t * 0.3, Vector3D.Y_AXIS);
						modelMatrix.appendRotation(t * 0.3, Vector3D.X_AXIS);
						modelMatrix.appendRotation(t * -0.3, Vector3D.Y_AXIS);
						modelMatrix.appendTranslation(dist, -dist, 0);
						break;
				}
				
				modelViewProjection.identity();
				modelViewProjection.append(modelMatrix);
				modelViewProjection.append(viewMatrix);
				modelViewProjection.append(projectionMatrix);
				
				context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, modelViewProjection, true);
				
				//position
				context3D.setVertexBufferAt(0, myMesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
				//tex coord
				context3D.setVertexBufferAt(1, myMesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				//vertex rgba
				context3D.setVertexBufferAt(2, myMesh.colorsBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
				//render
				context3D.drawTriangles(myMesh.indexBuffer, 0, myMesh.indexBufferCount);
				
			}
				
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
		
		private function renderTerrain():void
		{
			
			context3D.setTextureAt(0, terrainTexture);
			context3D.setProgram(shaderProgram1);
			
			//Position
			context3D.setVertexBufferAt(0, terrainMesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			//UV
			context3D.setVertexBufferAt(1, terrainMesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			//RGBA
			context3D.setVertexBufferAt(2, terrainMesh.colorsBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
			
			modelMatrix.identity();
			//modelMatrix.appendRotation( -90, Vector3D.Y_AXIS);
			
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