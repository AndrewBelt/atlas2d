# Atlas 2D Design Document
Codenamed Atlas 2D for now, this project is an HTML5 browser-based sandbox MMORPG with crafting, skills, multiplayer collaboration, and more.


## High Level Overview

### Landscape manipulation
Only one landscape tile can exist at each grid cell.
Each tile is a certain type (e.g. dirt, sand) and can contain arbitrary properties (e.g. damage).

Certain tile types can be destroyed by the player.
If destroyed, the tile turns into a different tile (e.g. tree tile to grass tile) and optionally drops an item.

Tiles that can be "passed under"... i.e. a bridge over a canyon, where you can pass under the canyon? Possible?


/* 
Luke brainstorming session, March 26th 2014
I suppose this wouldn't allow for any such thing as a "moving tile," like the fabled floating platform of old

Buildings? Inhabitable? Ownable?

Idea:  So, the game is based on the idea of it being 2d, right? 
How about this:  You own a house. Or a ladder. Something...
The game takes place on different planes. 
To advance from the "standard" plane to the next plane up
(think of this in a vertical advancement sort of way... jack & the beanstalk style)
You have to purchase a taller house, or bigger ladder, or bigger elevator... something.
You earn access to the "next level up."
Each of these "planes" gives access to something very practical; not just new enemies, but new spells, or items, as well.

If you don't use these spells, though, they go away. And so do the planes. you have to re-earn them if you don't use them, er maintain them.
The idea of practice. 
In this way the game, just like life, could be about balancing your use of spells?

And this way there is incentive to keep playing, and to enjoy the experience, rather than just playing to get to the next area... 
if you know you're going to lose your gear and your spells eventually, i'm guessing you'll try to enjoy the gameplay more...
I guess this is sort of forcing the concept of enjoying your journey and not your destination.
At the very least, this could cause players to have to make choices about their characters... 
(i.e. "will I be a fire character, or an ice character? I can't be both...")

This would also encourage creating a sort of "home base" where most of your creations are stored. I suppose it is like Minecraft in that way...

But what would be unlocked by these planes, exactly?
Crafting abilities?

Or maybe, maybe items with high combinability are found far away from eachother, and have expiration times...
so part of the game is rushing between items before they expire... resource management, I suppose


This is all Luke brainstorming with himself... so feel free to chime in... 
*/

### Inventory system
If a player picks up an item from the ground (how?), it is moved to his inventory.
Inventory items can be dropped, traded, or crafted into new items.

### Crafting
A crafting recipe contains three lists: ingredients, catalysts, and products.
For example, you can produce string from bark using a knife.

### Skills
Skills are used by the player for:
- Unlocking crafting recipes

### Multiplayer
Players can chat globally using the chat box on the bottom left of the gameplay screen.
  -I'd like to implement something like twitter's "tags" feature. Very far in the future, though. -LB
  


## Entity-Component Model

### Processes
Some examples of processes are the renderer, network communication routine, and the player movement routine.

### Entities
Entities are simply storage containters of components.
They contain no information themselves, except for a unique ID.

### Components
Components are somewhat rigid data containers with information used by a process.

Location
- position : Vector
- layer : Integer

Possession
- owner : ID
- tax?

Physics
- durability : Number
- collides : Bool
- weight : Number
- speed : Number (in pixels per frame)

Graphic
- name : String (see tilesets under Static assets)
- animating : Bool
- frame : Integer (if animating)

Audio
- filename


### Static assets
These are resources that do not change except during content update patches.
They are loaded from static YAML files by both the client and server.
These include:
- tilesets
  - graphic
	  - coord : Vector (if not animated)
	  - frames : [Vector] (if animated)
	  - size : Vector






