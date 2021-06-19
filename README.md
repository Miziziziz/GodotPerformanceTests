# Godot Performance Experiments And Tests
A series of primarily 3d performance tests and experiments in the godot engine.
To use: just download the project and run the scenes in each folder.

My PC specs:

Windows 10

Ryzen 3700

2060 Geforce

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
