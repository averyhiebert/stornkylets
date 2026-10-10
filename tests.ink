INCLUDE storylets.ink

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
<- n_exceeds_length
<- conditionals_and_empty
<- saved_results
<- composition
-> DONE

=== basic_test ===
+ [Basic functionality]
-
Testing: basic functionality
Should show 4 random storylets.
-> list_storylets(-> long_list,4) ->
-> finished

=== event_tunnel_test ===
+ [Automatic storylets]
-
Testing: tunnel to automatic storylets.
Should see 8 possibly-repeating events in a row.
-> ok ->
-> execute_storylet(-> event_list) ->
-> execute_storylet(-> event_list) ->
-> execute_storylet(-> event_list) ->
-> execute_storylet(-> event_list) ->
-> execute_storylet(-> event_list) ->
-> execute_storylet(-> event_list) ->
-> execute_storylet(-> event_list) ->
-> execute_storylet(-> event_list) ->

-> finished

=== n_exceeds_length
+ [n exceeds length]
-
Testing: n exceeds list length.
Should see 8 options appear
-> ok ->
-> list_storylets(-> long_list, 10) ->

-> finished


=== conditionals_and_empty
+ [Conditionals_and_empty]
-
Testing: conditionals and empty lists.
Test should end immediately.
-> ok ->
-> list_storylets(-> empty_list,3) ->
-> execute_storylet(-> empty_list) ->
-> finished


=== saved_results
+ [Saved results]
-
Testing: Saved results.
Remember what options are selected:
-> list_storylets(-> long_list,3) ->
~temp saved = save_storylets()
New options should match previous options, except possibly now in a different order:
-> load_storylets(-> long_list,3,saved) ->
-> finished

=== composition
+ [Composition]
-
Testing: Composition of multiple lists.
Should see options 1, 2, and 3 (not necessarily in that order).
-> ok ->
-> list_storylets(-> combined,3) ->
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
- s(1,true): + ->
    Event A occurs.
    ->->
- s(1,true): + ->
    Event B occurs.
    ->->
- s(1,true): + ->
    Event C occurs.
    ->->
} -> DONE




