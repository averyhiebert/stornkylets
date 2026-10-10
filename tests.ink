// Some fairly informal tests
// TODO Replace with closer to fully-automated tests, eventually

INCLUDE stornkylets.ink

-> test_menu

=== ok ===
+ [Continue] ->->

=== finished ===
Test over.
-> ok -> test_menu


=== test_menu ===
Select a test:
<- basic_test
<- event_tunnel_test
<- single_event_with_choice
<- n_exceeds_length
<- conditionals_and_empty
<- saved_results
<- composition
<- no_tunnel
-> DONE

=== basic_test ===
+ [Basic functionality]
-
Testing: basic functionality
Should show 4 random storylets.
-> storylet(-> long_list,4) ->
-> finished

=== event_tunnel_test ===
+ [Individual choiceless storylet]
-
Testing: tunnel to automatic storylets.
Should see 3 possibly-duplicate events in a row.
-> ok ->
-> storylet(-> event_list,1) ->
-> storylet(-> event_list,1) ->
-> storylet(-> event_list,1) ->
-> finished


=== single_event_with_choice ===
+ [Single event with choice]
-
Testing: Event with content and a choice.
You should have to pick A or B to advance.
-> ok ->
-> storylet(-> event_with_choice_list,1) ->
-> finished
= event_with_choice_list
{
-w(1):
    Choose A or B to continue.
    + [A] ->->
    + [B] ->->
} -> DONE

=== n_exceeds_length
+ [n exceeds length]
-
Testing: n exceeds list length.
Should see 8 options appear
-> ok ->
-> storylet(-> long_list, 10) ->

-> finished


=== conditionals_and_empty
+ [Conditionals_and_empty]
-
Testing: conditionals and empty lists.
Test should show one event and end immediately without interaction.
-> ok ->
-> storylet(-> event_list,1) ->
{NO_STORYLETS:
    Test FAILED!
    -> finished
}
-> storylet(-> empty_list,3) ->
-> storylet(-> empty_list,1) ->
{NO_STORYLETS:
    Test passed!
-else:
    Test FAILED!
}
-> finished

VAR save = ""
=== saved_results
+ [Saved results]
-
Testing: Saved results.
~save = "" // reset
Remember what options are selected:
-> saved_storylet(-> long_list,3,save) ->
New options should match previous options, except possibly now in a different order:
-> saved_storylet(-> long_list,3,save) ->
-> finished

=== composition
+ [Composition]
-
Testing: Composition of multiple lists in a single call.
Should see options 1, 2, and 3 (not necessarily in that order).
-> ok ->
-> storylet(-> combined,3) ->
-> finished


= comp1
{
-s(1,true):
    + Option 1 
        ->->
-s(1,true):
    + Option 2 
        ->->
}-> DONE

= comp2
{
-s(1,true):
    + Option 3 
        ->->
}-> DONE

= combined
<- comp1
<- comp2
-> DONE

=== no_tunnel ===
+ [Thread rather than tunnel]
-
Testing: use as thread rather than tunnel, used safely within a tunnel.
Should see 6 possibly-repeating lettered options.
-> test_tunnel ->
-> finished

= test_tunnel
<- storylet(-> long_list,3)
<- storylet(-> long_list,3)
{NO_STORYLETS: ->-> }

// Example lists ------------------------------------------------------

=== empty_list ===
{
-s(1,false): + opt A ->->
-c(false): + opt B ->->
} -> DONE

=== long_list ===
{
-w(1): + Option A
    ->->
-w(1): + Option B
    ->->
-w(1): + Option C
    ->->
-w(1): + Option D
    ->->
-w(1): + Option E
    ->->
-w(1): + Option F
    ->->
-w(1): + Option G
    ->->
-w(1): + Option H
    ->->
} -> DONE

=== event_list ===
{
- w(1):
    Event A occurs.
    ->->
- w(1):
    Event B occurs.
    ->->
- w(1):
    Event C occurs.
    ->->
} -> DONE





