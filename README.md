# Godot Performance Experiments And Tests
A series of primarily 3d performance tests and experiments in the godot engine.
To use: just download the project and run the scenes in each folder.

## AlphaScissorVsComplexGeometry

Tests performance difference between having models with a transparent texture and AlphaScissor set on their material vs having an identical looking but opaque model with more complex geometry.

**AlphaScissor** scene has simple models with transparent textures with AlphaScissor enabled
**ComplexGeo** scene has complex models with a default material
**BothGeoAndAlpha** has half of each of the above scenes

Results on my machine:
**AlphaScissor** scene has ~400 fps
**ComplexGeo** scene has ~420 fps
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
**VisionConeDotProdNoSqrt** takes 0.85 ms each frame when can see target, 0.42 ms each frame when can't
