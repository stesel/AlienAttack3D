package  
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.adobe.utils.PerspectiveMatrix3D;
	import components.GameInput;
	import components.GameTimer;
	import components.Stage3DEntity;
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
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	[SWF(width = "762", height = "480", frameRate = "66", backgroundColor = "#808080")]
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class Main extends Sprite 
	{
		private var gameTimer:GameTimer;
		
		private var gameInput:GameInput;
		
		private var chaseCamera:Stage3DEntity;
		
		private var player:Stage3DEntity;
		private var props:Vector.<Stage3DEntity>;
		private var enemies:Vector.<Stage3DEntity>;
		private var bullets:Vector.<Stage3DEntity>;
		
		private var particles:Vector.<Stage3DEntity>;
		
		private var entity:Stage3DEntity;
		
		private var asteroid1:Stage3DEntity;
		private var asteroid2:Stage3DEntity;
		private var asteroid3:Stage3DEntity;
		private var asteroid4:Stage3DEntity;
		private var engineGlow:Stage3DEntity;
		private var sky:Stage3DEntity;
		
		private const moveSpeed:Number = 1.0;
		private const asteroidRotationSpeed:Number = 0.01;
		
		private var fpsLast:uint = getTimer();
		private var fpsTicks:uint = 0;
		private var fpsText:TextField;
		private var scoreText:TextField;
		private var score:uint = 0;
		
		private var context3D:Context3D;
		
		private var shaderProgram1:Program3D;
		
		private var projectionMatrix:PerspectiveMatrix3D = new PerspectiveMatrix3D();
		private var viewMatrix:Matrix3D = new Matrix3D();
		
		
		//////////////// 
		////////////////
		[Embed(source = "../lib/ship.jpg")]
		private var playerTextureBitmap:Class;
		private var playerTextureData:Bitmap = new playerTextureBitmap() as Bitmap;
		
		[Embed(source="../lib/terrain.jpg")]
		private var terrainTextureBitmap:Class;
		private var terrainTextureData:Bitmap = new terrainTextureBitmap() as Bitmap;
		
		[Embed(source="../lib/craters.jpg")]
		private var cratersTextureBitmap:Class;
		private var cratersTextureData:Bitmap = new cratersTextureBitmap() as Bitmap;
		
		[Embed(source = "../lib/sky.jpg")]
		private var skyTextureBitmap:Class;
		private var skyTextureData:Bitmap = new skyTextureBitmap() as Bitmap;
		
		[Embed(source = "../lib/engine.jpg")]
		private var puffTextureBitmap:Class;
		private var puffTextureData:Bitmap = new puffTextureBitmap() as Bitmap;
		
		[Embed(source = "../lib/hud.png")]
		private var hudData:Class;
		private var hud:Bitmap = new hudData as Bitmap;
		
		////////////////
		private var playerTexture:Texture;
		private var terrainTexture:Texture;
		private var cratersTexture:Texture;
		private var skyTexture:Texture;
		private var puffTexture:Texture;
		
		////////////////
		[Embed(source = "../lib/ship.obj", mimeType = "application/octet-stream")]
		private var shipObjData:Class;
		
		[Embed(source = "../lib/puffCluster.obj", mimeType = "application/octet-stream")]
		private var puffObjData:Class;
		
		[Embed(source="../lib/terrain.obj", mimeType="application/octet-stream")]
		private var terrainObjData:Class;
		
		[Embed(source = "../lib/asteroids.obj", mimeType = "application/octet-stream")]
		private var asteroidsObjData:Class;
		
		[Embed(source = "../lib/sphere.obj", mimeType = "application/octet-stream")]
		private var skyObjData:Class;
		
		
		public function Main() 
		{
			if (stage)
				init(null);
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			if (hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			///////////
			gameTimer = new GameTimer(heartBeat);
			gameInput = new GameInput(stage);
			
			///////////
			props = new Vector.<Stage3DEntity>();
			enemies = new Vector.<Stage3DEntity>();
			bullets = new Vector.<Stage3DEntity>();
			particles = new Vector.<Stage3DEntity>();
			
			///////////
			initGUI();
			
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
			stage.stage3Ds[0].requestContext3D();
		}
		
		
//--------------------------------------------------------------------------
//
//  Update Methods
//
//--------------------------------------------------------------------------
		
		
		private function heartBeat():void 
		{
			 trace("heartbeat at " + gameTimer.gameElapsedTime + 'ms');
			trace("player " + player.posString());
			trace("camera " + chaseCamera.posString());
		}
		
		private function initGUI():void 
		{
			addChild(hud);
			
			///////////
			var myFormat:TextFormat = new TextFormat();
			myFormat.color = 0xffffaa;
			myFormat.size = 16;
			
			///////////
			fpsText = new TextField();
			fpsText.x = 4;
			fpsText.y = 0;
			fpsText.selectable = false;
			fpsText.autoSize = TextFieldAutoSize.LEFT;
			fpsText.defaultTextFormat = myFormat;
			fpsText.text = "Initialization Stage3D...";
			addChild(fpsText);
			
			///////////
			scoreText = new TextField();
			scoreText.x = 600;
			scoreText.y = 0;
			scoreText.selectable = false;
			scoreText.autoSize = TextFieldAutoSize.LEFT;
			scoreText.defaultTextFormat = myFormat;
			scoreText.text = "Initialization Stage3D...";
			addChild(scoreText);
		}
		
		
		private function onContext3DCreate(e:Event):void 
		{
			if (hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, enterFrame);
			
				
			
			var t:Stage3D = e.target as Stage3D;
			context3D = t.context3D;
			
			if (context3D == null)
			{
				fpsText.text = "ERROR: no context3D - video driver problem?";
				trace("ERROR: no context3D - video driver problem?");
				return;
			}
			
			context3D.enableErrorChecking = true;
			
			context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 3, true);
			
			initShaders();
			
			playerTexture = context3D.createTexture(playerTextureData.width, playerTextureData.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(playerTexture, playerTextureData.bitmapData);
			
			terrainTexture = context3D.createTexture(terrainTextureData.width, terrainTextureData.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(terrainTexture, terrainTextureData.bitmapData);
			
			cratersTexture = context3D.createTexture(cratersTextureData.width, cratersTextureData.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(cratersTexture, cratersTextureData.bitmapData);
			
			puffTexture = context3D.createTexture(puffTextureData.width, puffTextureData.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(puffTexture, puffTextureData.bitmapData);
			
			skyTexture = context3D.createTexture(skyTextureData.width, skyTextureData.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(skyTexture, skyTextureData.bitmapData);
			
			
			
			initData();
			
			projectionMatrix.identity();
			projectionMatrix.perspectiveFieldOfViewRH(45, stage.width / stage.stageHeight, 0.01, 300000.0); 
			
			stage.addEventListener(Event.RESIZE, stage_resize);
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function uploadTextureWithMipmaps(dest:Texture, scr:BitmapData):void
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
			chaseCamera = new Stage3DEntity();
			
			player = new Stage3DEntity(shipObjData, context3D, shaderProgram1, playerTexture, 0.6, false, true);
			player.rotationDegreesX = -90;
			player.z = 2100;
			
			var terrain:Stage3DEntity = new Stage3DEntity(terrainObjData, context3D, shaderProgram1, terrainTexture, 1, false, true);
			terrain.rotationDegreesX = 90;
			terrain.cullingMode = Context3DTriangleFace.NONE;
			terrain.scaleX = 10;
			terrain.scaleY = 10;
			terrain.y = -50;
			props.push(terrain);
			
			var terrain2:Stage3DEntity = terrain.clone();
			terrain.z = -4000;
			terrain2.cullingMode = Context3DTriangleFace.NONE;
			props.push(terrain2);
			
			asteroid1 = new Stage3DEntity(asteroidsObjData, context3D, shaderProgram1, cratersTexture, 1, false, true);
			asteroid1.scaleXYZ = 200;
			asteroid1.y = 500;
			asteroid1.z = -1000;
			props.push(asteroid1);
			
			asteroid2 = asteroid1.clone();
			asteroid2.z = -5000;
			props.push(asteroid2);
			
			asteroid3 = asteroid1.clone();
			asteroid3.z = -9000;
			props.push(asteroid3);
			
			asteroid4 = asteroid1.clone();
			asteroid4.z = -9000;
			asteroid4.y = -500;
			props.push(asteroid4);
			
			engineGlow = new Stage3DEntity(skyObjData, context3D, shaderProgram1, puffTexture, 0.3, false, true);
			
			engineGlow.follow(player);
			engineGlow.blendScr = Context3DBlendFactor.ONE;
			engineGlow.blendDst = Context3DBlendFactor.ONE;
			engineGlow.depthTest = false;
			engineGlow.cullingMode = Context3DTriangleFace.NONE;
			engineGlow.y = -2;
			engineGlow.scaleXYZ = 0.5;
			particles.push(engineGlow);
			
			sky = new Stage3DEntity(skyObjData, context3D, shaderProgram1, skyTexture, 1, false, true);
			sky.follow(player);
			sky.depthTest = false;
			sky.depthTestMode = Context3DCompareMode.LESS;
			sky.cullingMode = Context3DTriangleFace.NONE;
			sky.z = 2000;
			sky.scaleX = 4000;
			sky.scaleY = 4000;
			sky.scaleZ = 3000;
			sky.rotationDegreesX = 30;
			props.push(sky);
			
		}
		
		private function initShaders():void 
		{
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble
			(
				Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" +
				"mov v0, va0\n" +
				"mov v1 va1\n" +
				"mov v2, va2"
			);
			
			var fragmentShaderAssembler1:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler1.assemble
			(
				Context3DProgramType.FRAGMENT,
				"tex ft0, v1, fs0 <2d, lenear, repeat, miplinear>\n" +
				"mov oc, ft0"
			);
			
			shaderProgram1 = context3D.createProgram();
			shaderProgram1.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler1.agalcode);
		}
		
		private function enterFrame(e:Event):void 
		{
			context3D.clear(0, 0, 0);
			gameTimer.tick();
			gameStep(gameTimer.frameMs);
			
			renderScene();
			
			context3D.present();
			
			
			//FPS
			fpsTicks++;
			var now:uint = getTimer();
			var delta:uint = now - fpsLast;
			if (delta >= 1000)
			{
				var fps:Number = fpsTicks / delta * 1000;
				fpsText.text = fps.toFixed(1) + " fps";
				fpsTicks = 0;
				fpsLast = now;
			}
			
			updateScore();
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
				
			scoreText.text = str;	
		}
		
		private function renderScene():void
		{
			viewMatrix.identity();
			
			viewMatrix.append(chaseCamera.transform);
			viewMatrix.invert();
			
			viewMatrix.appendRotation(15, Vector3D.X_AXIS);
			
			viewMatrix.appendRotation(gameInput.cameraAngleX, Vector3D.X_AXIS);
			viewMatrix.appendRotation(gameInput.cameraAngleY, Vector3D.Y_AXIS);
			viewMatrix.appendRotation(gameInput.cameraAngleZ, Vector3D.Z_AXIS);
			
			player.render(viewMatrix, projectionMatrix);
			
			for each (entity in props)
				entity.render(viewMatrix, projectionMatrix);
			for each (entity in enemies)
				entity.render(viewMatrix, projectionMatrix);
			for each (entity in bullets)
				entity.render(viewMatrix, projectionMatrix);
			for each (entity in particles)
				entity.render(viewMatrix, projectionMatrix);
		}
		
		private function gameStep(frameMS:uint):void
		{
			var moveAmount:Number = moveSpeed * frameMS;
			
			if (gameInput.pressing.up)
				player.z -= moveAmount; 
				
			if (gameInput.pressing.down)
				player.z += moveAmount;
				
			if (gameInput.pressing.left)
				player.x -= moveAmount;
				
			if (gameInput.pressing.right)
				player.x += moveAmount;
				
			chaseCamera.x = player.x;
			chaseCamera.y = player.y + 2;
			chaseCamera.z = player.z + 5;
			
			asteroid1.rotationDegreesX += asteroidRotationSpeed * frameMS;
			asteroid2.rotationDegreesX -= asteroidRotationSpeed * frameMS;
			asteroid3.rotationDegreesX += asteroidRotationSpeed * frameMS;
			asteroid4.rotationDegreesX -= asteroidRotationSpeed * frameMS;
			
			engineGlow.rotationDegreesZ += 10 * frameMS;
			engineGlow.scaleXYZ = Math.cos(gameTimer.gameElapsedTime / 66) / 20 + 0.5;
				
		}
		
		private function stage_resize(e:Event):void 
		{
			this.width = stage.stageWidth;
			this.height = stage.stageHeight;
			//
			if (this.scaleY > this.scaleX)
				this.scaleY = this.scaleX;
			else
				this.scaleX = this.scaleY;
				
			this.x = (stage.stageWidth - this.width) / 2;
			this.y = (stage.stageHeight - this.height) / 2;
			if (stage.stageWidth > 50 && stage.stageHeight > 50)
			{
				context3D.configureBackBuffer(this.width, this.height, 0, true);
				stage.stage3Ds[0].x = this.x;
				stage.stage3Ds[0].y = this.y;
			}
		}
		
	}

}