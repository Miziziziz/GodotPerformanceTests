# Godot Performance Experiments And Tests

A series of primarily 3d performance tests and experiments in the godot engine.

Full thread with videos and stuff: https://twitter.com/miziziziz/status/1406065809139679232

To use: just download and run the project, select a test and click "Start Test".

You can also run all tests back-to-back and configure the time each test is run.

The results will be displayed in a table after the tests are finished.


My PC specs:

Windows 10

Ryzen 3700x

Nvidia Geforce 2060  rtx

16 gb Ram

## AlphaScissorVsComplexGeometry

Tests performance difference between having models with a transparent texture and AlphaScissor set on their material vs having an identical looking but opaque model with more complex geometry.

**AlphaScissor** scene has simple models with transparent textures with AlphaScissor enabled

**ComplexGeo** scene has complex models with a default material

**ComplexGeoTwoMats** scene has complex models with two differet default materials

**BothGeoAndAlpha** has half of each of the above scenes


Results on my machine:

**AlphaScissor** scene has ~400 fps

**ComplexGeo** scene has ~420 fps

**ComplexGeoTwoMats** scene has ~360 fps

**BothGeoAndAlpha** has ~180 fps


## Pathfinding
Pathfinding tests done with 25 agents chasing a moving target through a complex navmesh.

**BasicPathfinding** scene has each agent call get_simple_path once per frame

**QueuedPathfinding** scene has a PathfindManager that queues requests from agents, calls get_simple_path once per frame, and sends the results back to each agent when their request is complete

**SepThreadQueuedPathfinding** scene is the same as QueuestPathfinding, except the get_simple_path calls are done on a separate thread


Results on my machine:

**BasicPathfinding** ~800 fps at start, goes up to ~1600 as they get closer to the target

**QueuedPathfinding** ~3000 fps at start, goes up to ~3200 as they get closer to the target

**SepThreadQueuedPathfinding** ~1000 to ~1200 fps, I think my implementation is broken because it crashes sometimes

## VisionCone
testing several different algorithms to see if a target point is within a vision cone of an agent. Each algorithm is run 1000 times each frame.

**VisionConeAngleCalc** Calls angle_to() method with the forward direction of the agent and the direction to the target 

**VisionConeDotProd** Gets the dot product of the direction to the target and the forward direction of the agent

**VisionConeDotProdNoSqrt** An optimization of the last algorithm that removes the need to normalize the vector of the  direction to the target


Results on my machine:

**VisionConeAngleCalc** takes 0.95 ms each frame

**VisionConeDotProd** takes 0.85 ms each frame

**VisionConeDotProdNoSqrt** takes 0.85 ms each frame when can see target, 0.42 ms each frame when can't. Easy to make it 2d as well, which is only 0.65 ms each frame when the agent can see the target


## LineOfSightChecks
Testing the performance cost of doing a bunch of raycasts to check for line of sight. There are 50 agents each doing one raycast per frame.

Results on my machine:
**RaycastLoS** between ~2400 fps to ~2900 fps. It's lower the more agents the target is behind cover for.

## Movement
tests comparing move_and_collide, move_and_slide, and move_and_slide_with_snap performance when moving 150 agents simultaneously.

**MoveAndCollide** agents use move_and_collide to move. Get stuck on slopes though.

**MoveAndSlide** agents use move_and_slide to move.

**MoveAndSlideWithSnap** agents use move_and_slide_with_snap to move. 

Results on my machine:

**MoveAndCollide** ~2350 fps

**MoveAndSlide** ~2250 fps when moving uphill, ~2450 fps when moving downhill

**MoveAndSlideWithSnap** ~2000 fps when moving uphill, ~2200 fps when moving downhill

## ArmIK
Performance tests on a custom arm ik system I wrote

**ArmIKBasic** has 30 characters each update their ik twice per frame (once for each arm)

**ArmIKQueue** has 30 characters that send ik update requests to an ik manager that does a fixed number of ik calculations each frame

Results on my machine:

**ArmIKBasic** ~560-600 fps

**ArmIKQueue** 2 calculations per frame(cpf) ~2200 fps, 4 cpf is ~2000 fps, 30 cpf is ~730-780 fps

## DistanceChecks
100 agents wander around randomly and turn red when within 4 units of another agent.

**DistCheckBasic.tscn** No optimization, every single agent calls get_distance_squared once for every other agent

**DistCheckAreaProcess.tscn** every agent has an Area node and calls get_overlapping_bodies every frame

**DistCheckAreaDetectAreaProcess.tscn** same as above but using get_overlapping_areas instead

**DistCheckAreaSignals.tscn** every agent has an Area node and uses the body_entered and body_exited signals to determine if there are others nearby

**DistCheckHashTable.tscn** custom hashtable implementation thing written in gdscript using dictionaries. 

**DistCheckQuery.tscn** uses intersect_shape() to get nearest objects

Results on my machine:

**DistCheckBasic.tscn** 220-240 fps

**DistCheckAreaProcess.tscn** 1600 fps, but Physics Time is ~6 ms in profiler, so you get large spikes every physics frame, looks like the calculations for get_overlapping_bodies are done every physics frame whether you call the method or not.

**DistCheckAreaDetectAreaProcess.tscn** Same as previous

**DistCheckAreaSignals.tscn** Same as previous

**DistCheckHashTable.tscn** 230-250 fps, probably would be a lot better in C#

**DistCheckQuery.tscn** in  \_physics_process it's 2500fps, but you get a 1ms spike on each physics frame.
Done in \_process it's smooth 900 fps. Also it's possible to do time slicing with this technique.

## ShootingBullets
Object pooling tests where a bunch of bullets are shot at a wall. 

**ShootBulletsBasic.tscn** bullets are instanced as they are shot, and queue_free() when they collide. Same with the spark hit effects.

**ShootBulletsPooling.tscn** bullets and hit effects come from object pools.

Results on my machine:

performance was completely identical in both scenes. All performance impact came from doing bullet collision.


## Font

This project uses the Lato font by Łukasz Dziedzic.
