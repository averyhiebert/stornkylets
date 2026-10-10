// Some illustrative examples
INCLUDE stornkylets.ink

-> menu

=== menu ===
Pick an example game.
<- oregon_trail
<- park
<- procedural_village
-> DONE


VAR party_members = 4
=== oregon_trail ===
+ [Oregon Trail (random events demo)]
    ~party_members = 4
    Welcome to the Oregon Trail.
- (trail_loop)
You have {party_members} party members remaining.
+ {party_members > 0} [Continue...]
    -> storylet(-> events, 1) -> trail_loop
+ ->
    GAME OVER
    -> END

= events
{
-w(1): // w for 'weight'
    Someone dies of dysentery.
    ~party_members -= 1
    ->->
-w(2): // twice the weight
    Nothing interesting happens.
    ->->
-c(party_members == 1): // c for 'condition', default weight is 1
    You are feeling awfully lonely.
    ->->
-s(1,party_members == 4): // s for 'storylet,' with a weight *and* a condition
    You celebrate the fact that no one has died yet.
    ->->
-s(0.1,party_members < 4): // decimal weights are supported
    Someone returns from the dead(?)
    ~party_members += 1
    ->->
-w(1): // Events can contain choices, of course.
    You encounter a river.
    + [Attempt to ford the river.]
        You attempt to ford the river, but fail.
        Your entire party drowns.
        ~party_members = 0
        ->->
    + [Reroute to the nearest bridge.]
        It takes you 3 days to find a bridge.
        ->->
    // Note: unfortunately, you can't use gathers in a switch statement,
    //  so you'll probably want to use a separate knot for any events
    //  complicated enough to require gathers.
-s(100,not expressed_optimism): // one way to create a one-time event
    + (expressed_optimism) ->
    // Note: again, this is a workaround since a labeled gather won't work.
    You feel optimistic about your chances.
    ->->
}-> DONE

=== park ===
+ [Park (multiple storylets demo)]
- (park_loop)
You are in the park.
-> storylet(-> park_activities,2) ->
+ [Go home.]
- 
You go home.
+ [Go back to the park.]
    -> park_loop

= park_activities 
{
-w(1): There is a dog here.
    + [Pet the dog.]
        You pet the dog.
        ->->
-w(1): There is a tree here.
    + [Climb the tree.]
        You cannot reach the lowest branch.
        You fail to climb the tree.
        ->->
    + [Rest under the tree.]
        It is nice and shady under the tree.
        ->->
-w(1): There is a goose here.
    + [Look at the goose.]
        You look at the goose but don't pet it, because it is a wild animal.
        ->->
-w(1): You spot a penny lying on the ground.
    + [Take the penny.]
        You take the penny.
        ->->
}-> DONE

VAR market_state = ""
VAR landmarks_state = ""
=== procedural_village ===
+ [Procedural village (saving/loading)]
- (village_menu)
You are in the town square of a quaint, randomized village.
-> saved_storylet(-> possible_landmarks, 1, landmarks_state) ->
+ (market)[Visit the market.]
    You can purchase all sorts of stuff here at the market.
    <- saved_storylet(->market_options, 2, market_state)
    ++ [Leave market.]
+ [Re-randomize the town.]
    ~landmarks_state = ""
    ~market_state = ""
- -> village_menu

= possible_landmarks
{
-w(1): A giant statue of a bull looms over you. ->->
-w(1): Someone is playing the dulcimer. ->->
-w(1): The air smells like guava fruit. ->->
-w(1): Some sort of creeping vine covers most of the buildings. ->->
-w(1): There are an awful lot of rabbits around here. ->->
}-> DONE

= market_options
{
-w(1): <- buy("muffins","The muffins are delicious.")
-w(1): <- buy("mangoes","The mangoes are expensive.")
-w(1): <- buy("rubies","You can't afford the rubies.")
-w(1): <- buy("happiness","Money cannot buy happiness.")
-w(1): <- buy("potions","My potions are too strong for you.")
-w(1): <- buy("rabbits","You have nowhere to keep a rabbit.")
}-> DONE

= buy(item,outcome)
+ [Purchase some {item}]
    {outcome}
    ++ [Ok] -> market














