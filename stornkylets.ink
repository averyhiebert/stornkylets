/******************************************************
MIT License

Copyright (c) 2026 Avery Em Hiebert

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*******************************************************/


VAR NO_STORYLETS = false // if the most recent call found no storylets

// Public/wrappers --------------------------------------

// call as tunnel, lists choices from up to n selected storylets
=== storylet(-> storylets, n) ===
-> tunnel(storylets,n) ->->
= tunnel(-> storylets, n)
<- s_start_first_pass(storylets,n,"")
-> DONE

// repeat a previous instance of thread_storylets from saved data, ASSUMING no individual storylet conditions have changed.
=== saved_storylet(-> storylets, n, ref save_data) ===
-> tunnel(storylets,n,save_data) ->->
= tunnel(-> storylets,n,ref save_data)
<- s_start_first_pass(storylets, n, save_data)
~save_data = s_already_displayed_storylets
-> DONE

// Shortcut for weight without condition
=== function w(weight) ===
~return s(weight,true)

// Shortcut for condition without weight
=== function c(cond) ===
~return s(1,cond)

// Private ---------------------------------------------------

// Sorry for relying on spooky action-at-a-distance with so many globals.
// This is Ink, after all.
VAR s_is_first_pass = true
VAR s_total_weight = 0
VAR s_remaining_weight = 0
VAR s_index = 0
VAR s_already_displayed_storylets = ""
VAR s_requested_storylets = "" // Preselected list of storylet indices (for loading saved data)
=== s_start_first_pass(-> storylets, n, save_data) ===
//~NO_STORYLETS = true
~s_is_first_pass = true
~s_total_weight = 0
~s_already_displayed_storylets = ""
~s_requested_storylets = save_data 
<- storylets
<- s_second_pass(storylets,n)
~NO_STORYLETS = (s_already_displayed_storylets == "")
+ ->
    ->-> // fallback for if no choices exist
- -> DONE

= s_second_pass(-> storylets,n)
{n <= 0: -> DONE }
~s_is_first_pass = false
~s_remaining_weight = s_total_weight
~s_index = 0
<- storylets
{s_total_weight > 0:
    // Don't continue if no weight remains
    <- s_second_pass(storylets, n-1)
} -> DONE


// TODO: Note that when threading multiple storylets, this approach currently increases the
//  weight of storylets immediately after a storylet that was already selected. Must figure out
//  how to handle this properly.
=== function s(my_weight,cond) ===
// Specify weight and selection condition for storylet 
~s_index += 1 // include *all* choices, for saving purposes
{
- not cond:
    ~return false
- s_is_first_pass:
    ~s_total_weight += my_weight
    ~return false
- s_list_contains(s_already_displayed_storylets, s_index):
    ~return false
- s_list_contains(s_requested_storylets, s_index):
    ~s_display_item(my_weight)
    ~return true
- s_requested_storylets != "":
    ~return false
- s_select_with_probability(FLOAT(my_weight)/s_remaining_weight):
    ~s_display_item(my_weight)
    ~return true
- else:
    ~s_remaining_weight -= my_weight
    ~return false
}

=== function s_select_with_probability(p) ===
~return RANDOM(0,1000)/1000.0 < p

// Saving/loading individual items

=== function s_display_item(weight) ===
//~NO_STORYLETS = false
~s_total_weight -= weight
~s_already_displayed_storylets = s_already_displayed_storylets + "[{s_index}]"

=== function s_list_contains(saved,x) ===
// Return true if the given weight has been saved
~return saved ? "[{x}]"





