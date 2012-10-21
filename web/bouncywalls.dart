import 'dart:html';
import 'package:box2d/box2d_browser.dart';
import 'dart:math';


num rotatePos = 0;

class BouncyWalls {
  /** Scale of the viewport. */
  static const num _VIEWPORT_SCALE = 10;
  /** The drawing canvas. */
  CanvasElement canvas;

  /** The canvas rendering context. */
  CanvasRenderingContext2D ctx;

  /** The transform abstraction layer between the world and drawing canvas. */
  IViewportTransform viewport;

  /** The debug drawing tool. */
  DebugDraw debugDraw;

  /** The physics world. */
  World world;
  
  num viewportScale;
  
  /** All of the bodies in a simulation. */
  List<Body> bodies;
  
  /** The gravity vector's y value. */
  static const num GRAVITY = -10;
  
  /** The default canvas width and height. */
  static const int CANVAS_WIDTH = 500;
  static const int CANVAS_HEIGHT = 500;
  
  // For timing the world.step call. It is kept running but reset and polled
  // every frame to minimize overhead.
  Stopwatch _stopwatch;
  
  /** The timestep and iteration numbers. */
  static const num TIME_STEP = 1/60;
  static const int VELOCITY_ITERATIONS = 10;
  static const int POSITION_ITERATIONS = 10;
  
  BouncyWalls([Vector gravity, this.viewportScale = _VIEWPORT_SCALE])
  : bodies = new List<Body>() {
    bool doSleep = true;
    if (null === gravity) gravity = new Vector(0, GRAVITY);
    world = new World(gravity, doSleep, new DefaultWorldPool());
  }
  
  static void main() {
    final boxTest = new BouncyWalls();
    boxTest.initialize();
    boxTest.initializeAnimation();
    boxTest.runAnimation();
  }
  
  void initialize() {
    assert (null !== world);
    _createGround();
    _createBox();
  }
  
  void initializeAnimation() {
    // Setup the canvas.
    canvas = new Element.tag('canvas');
    canvas.width = CANVAS_WIDTH;
    canvas.height = CANVAS_HEIGHT;
    document.body.nodes.add(canvas);
    ctx = canvas.getContext("2d");

    // Create the viewport transform with the center at extents.
    final extents = new Vector(CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2);
    viewport = new CanvasViewportTransform(extents, extents);
    viewport.scale = viewportScale;

    // Create our canvas drawing tool to give to the world.
    debugDraw = new CanvasDraw(viewport, ctx);

    // Have the world draw itself for debugging purposes.
    world.debugDraw = debugDraw;
  }
  
  void _createGround() {
    // Create shape
    final PolygonShape shape = new PolygonShape();

    // Define body
    final BodyDef bodyDef = new BodyDef();
    bodyDef.position.setCoords(0.0, 0.0);

    // Create body
    final Body ground = world.createBody(bodyDef);

    final num borderWidth = 0.09;
    final num lineLength = 500.0;
    // Top
    shape.setAsBoxWithCenterAndAngle(lineLength, borderWidth, new Vector( 0.0, 25.0), 0.0);
    ground.createFixtureFromShape(shape);
    // Bottom
    shape.setAsBoxWithCenterAndAngle(lineLength, borderWidth, new Vector(0.0, -25.0), 0.0);
    ground.createFixtureFromShape(shape);
    // Left
    shape.setAsBoxWithCenterAndAngle(borderWidth, lineLength, new Vector(-25.0, 0.0), 0.0);
    ground.createFixtureFromShape(shape);
    // Right
    shape.setAsBoxWithCenterAndAngle(borderWidth, lineLength, new Vector( 25.0, 0.0), 0.0);
    ground.createFixtureFromShape(shape);
    

    // Add composite body to list
    bodies.add(ground);
  }

  void _createBox() {
    // Create shape
    final PolygonShape shape = new PolygonShape();
    shape.setAsBoxWithCenterAndAngle(3.0, 1.5, new Vector(0, 0), PI / 2);

    // Define fixture (links body and shape)
    final FixtureDef activeFixtureDef = new FixtureDef();
    activeFixtureDef.restitution = 0.5;
    activeFixtureDef.density = 0.05;
    activeFixtureDef.shape = shape;

    // Define body
    final BodyDef bodyDef = new BodyDef();
    bodyDef.type = BodyType.DYNAMIC;
    bodyDef.position = new Vector(0, 30.0);

    // Create body and fixture from definitions
    final Body fallingBox = world.createBody(bodyDef);
    fallingBox.createFixture(activeFixtureDef);

    // Add to list
    bodies.add(fallingBox);
  }
  
  void runAnimation() {
    window.requestAnimationFrame((num time) { step(time); });
  }
  
  /** Advances the world forward by timestep seconds. */
  void step(num timestamp) {
    //_stopwatch.reset();
    world.step(TIME_STEP, VELOCITY_ITERATIONS, POSITION_ITERATIONS);

    // Clear the animation panel and draw new frame.
    ctx.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    world.drawDebugData();

    window.requestAnimationFrame((num time) { step(time); });
  }
}

void main() {
  BouncyWalls.main();
}