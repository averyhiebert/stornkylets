# Stornkylets

A simple but reasonably usable and robust storylet system in pure Ink.

Features:
- does not require defining a knot or a list item for each individual storylet
- supports selecting a single "random event"
- supports listing multiple options sampled without replacement
- flexible choice of threading or tunneling
- supports saving/loading a specific random selection
- supports dynamically combining lists of storylets
- the syntax is *relatively* pleasant (by Ink standards, at least)

## Setup

Download the single file `stornkylets.ink`, place it somewhere in your project, and `INCLUDE` it at the top of your main file.

## Random events

The simplest use case is selecting a single random event.

Create a list of storylets using a big switch statement, specifying either weights, selection conditions, or both:
```
=== example_event_list ===
{
-w(1): // w for 'weight', up to 3 decimal places supported
    A simple event which does not require its own knot. ->->
-cond(2 + 2 == 4): // c for 'condition', default weight is 1
    Looks like math is still working. ->->
-s(1,true): // s for 'storylet,' specifies both weight and condition
    Another storylet. ->->
}-> DONE
```

Then use the `storylet(-> storylets, n)` tunnel to select n = 1 random event:
```
-> storylet(-> example_event_list, 1) ->
```

You'll probably want to put large/complicated events in a dedicated knot.  Note that you can't use gathers in switch statements, so that's one case where you'll definitely need a dedicated knot.

See "Oregon Trail" in [examples.ink](examples.ink) for a more complex example.

### Checking whether anything actually happened

If the list of possible storylets is empty, execution will return from the tunnel as usual. The variable `NO_STORYLET` can be used to check whether storylets were actually found:

```
+ [Check your mailbox.]
    -> storylets(-> mailbox,3) ->
    {NO_STORYLET:
        You have no new messages.
    }
```


## Sampling multiple options

You can also sample multiple storylets (without replacement), gathering text and choices from all of them to present to the user, as seen in the Park demo:

```
=== park ===
You are in the park.
-> storylet(-> park_activities,2) ->
+ [Go home.]
- 
You go home.
+ [Go back to the park.]
    -> park

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
```

Note that if you are selecting multiple storylets, each one should eventually lead to either a choice, `-> DONE`, or `-> END`.  Otherwise, strange things will happen.


## Saved storylets

You can save and replay a storylet selection using `saved_storylet(-> storylets, n, ref savestate`.  You must provide a reference to a string variable in which to store the storylet selection data.  If this string is empty (or otherwise evaluates to false) then a new selection will be made and the result will be saved.

```
VAR landmarks = ""
= procedural_town
You are in a procedurally-generated town.
-> saved_storylet(-> possible_landmarks,1,landmarks) ->
+ [Leave town.]
    The town will be as you left it when you return.
    ++ [Return to town.] -> procedural_town
+ [Re-randomize town.]
    ~landmarks = ""
    -> procedural_town

= possible_landmarks
{
-w(1): A giant statue of a bull looms over you. ->->
-w(1): Someone is playing the dulcimer. ->->
-w(1): The air smells like guava fruit. ->->
-w(1): Some sort of creeping vine covers most of the buildings. ->->
-w(1): There are an awful lot of rabbits around here. ->->
}-> DONE
```

This has a caveat: it will only work if the list of storylets passed into `storylet` is the same at save time as at load time.  If you are not dynamically constructing this list, then you should be safe.

It's okay for the availability of individual choices to change based on their conditions; in this case, choices that were originally included but have since become unavailable will simply not be displayed.

This should be very helpful for e.g. generating complex randomized locations that you can leave and return to without them changing.

The saved list of selections is based on indices relative to the overall list of storylets, so hypothetically you should be able to swap out "equivalent" lists (e.g. where the n-th item in one list corresponds in some way with the n-th item in the other list) with the same save data, which could be used to interesting effect if you're feeling adventurous.

Finally, note that the order in which the options are *displayed* may change when loading; specifically, after loading the order of the storylets will match the order in which they appear in the source code, not the random order in which they were originally displayed.


## Dynamically composing lists of storylets

You can combine multiple lists before feeding them to the `storylet` function using threads.

This could be handy for grouping sets of storylets to avoid repeating conditions, e.g. using an if statement to group events by location, instead of needing to add a `location == london` condition to all of your "london

```
-> storylet(-> all_possible_events,1) ->
// Assuming that each of the threads mentioned below is itself a valid thread:
=== all_possible_events ===
<- always_available_events
{companion:
- Fogg:
    <- fogg_events
- Passepartout:
    <- passepartout_events
}
{location:
- london:
    <- london_events
- paris:
    <- paris_events
}
->DONE
```

## Threading vs. tunneling.

You can also use `storylet()` as a thread instead of a tunnel, allowing other forms of composition.  This should be safe to do if you are already inside a tunnel:

```
What opportunities await you today?
-> show_activities -> // note that show_activities is a tunnel!

=== show_activities ===
<- storylet(-> generic_activities,1)
{location:
- london:
    <- storylet(-> london_activities,3)
- paris:
    <- storylet(-> paris_activities,3)
}
-> DONE
```

If you do not want to use a tunnel or a thread, you could also just use a plain divert, and divert to wherever you like within each storylet.  However, be warned that this will cause undefined behaviour if there are no available storylets.


## Misc. other notes 

### Nesting storylets

It should be okay to call `storylet` from within another storylet *only if* it is gated behind some sort of choice.  Otherwise, it will cause undefined behaviour.

In some cases, for invidually-sampled "random events" not gated behind a chice, a fallback choice `+ ->` may be a useful workaround. I'm not sure this would reliably work in settings where you are sampling more than one storylet, though.


### Efficiency

The selection algorithm runs in `O(nk^2)` time, where `n` is the total number of possible storylets and `k` is the number of storylets actually selected.  So if the number of storylets you're selecting is bounded by some constant (e.g. you never select more than 5 storylets at a time), then the efficiency is `O(n)`.

However, if you want to show *all* available storylets (e.g. by setting the number of storylets requested to something very large), then in general this is `O(n^3)`.  So if you're planning on frequently displaying *all* available storylets from a long-ish list, then it might make more sense to just use conventional choices/conditions/threads.


### Priority

I have not implemented a priority system, because I feel that this is likely to be fairly game-specific.

Some thoughts:
- Manually-assigned priority can be easily approximated by using weights of substantially varying scales.
- Alternatively, you could keep high, medium, and low-priority events in separate lists, and then sample the lists in decreasing order of priority until you find something.
- Finally, a higher-effort (but still not difficult) solution would be to add a priority function to the conditions for the list items (e.g. `s(1,priority(5))`) that checks priority against some `required_priority_level` variable, and then repeatedly sample while decreasing the priority level until you find something.

