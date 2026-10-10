// Storylet system

/* 
Usage:

-> thread_storylets(-> example_list,1) ->
=== example_list() ===
{
-s(1,true):
    something
-s(3,some condition):
    something else
} ->->
*/

// Public API:

// call as tunnel, lists choices from up to n selected storylets
=== list_storylets(-> storylets, n) ===
-> tunnel(storylets,n) ->->

= tunnel(-> storylets, n)
<- s_thread_n_long(storylets,n,"")
-> DONE

// repeat a previous instance of thread_storylets from saved data, ASSUMING no individual storylet conditions have changed.
=== load_storylets(-> storylets, n, save_data) ===
-> tunnel(storylets,n,save_data) ->->

= tunnel(-> storylets,n,save_data)
<- s_thread_n_long(storylets, n, save_data)
-> DONE

// execute a random storylet event-style, assuming storylets consist of fallback choices.
=== execute_storylet(-> storylets) ===
<- s_thread_n_long(storylets,1,"")
-> DONE

=== function save_storylets() ===
// public: If called immediately after threading storylets, returns a data string that can be used with repeat_storylets to repeat the same selection, assuming that no conditions have changed.
~return s_ignore_storylets

// -----------------------------------------------------------------------------------------

CONST s_precision_multiplier = 1000 // To support fractions

VAR s_first_pass = true
VAR s_cumulative_weight = 0 // cumulative so far during a pass
VAR s_total_weight = 0 // total as calculated in first pass
VAR s_ignored_weight = 0 // total weight of items ignored so far this pass
VAR s_ignored_weight_total = 0 // total weight of items ignored on previous pass
VAR s_selected_weight = 0
VAR s_ignore_storylets = "" // Which storylets have already been shown so far.
VAR s_saved_storylets = "" // For replaying already-selected storylets.
VAR s_ran_out = false
=== s_thread_n_long(-> storylets, n, save_data) ===
// Thread storylets n times without replacement
// If preselected_string is not "", use it as preselected values.
// First pass: just counting total weight
~s_ran_out = false
~s_first_pass = true
~s_cumulative_weight = 0
~s_ignored_weight = 0
~s_ignored_weight_total = 0
~s_ignore_storylets = ""
~s_saved_storylets = save_data 
<- storylets
~s_total_weight = s_cumulative_weight
<- s_thread_n_helper(storylets,n) // subsequent passes
+ ->-> // fallback if no choices exist
-
-> DONE

= s_thread_n_helper(-> storylets,n)
{n <= 0: -> DONE }
~s_ran_out = true
~s_first_pass = false
~s_cumulative_weight = 0
~s_ignored_weight = 0
<- storylets
{not s_ran_out:
    <- s_thread_n_helper(storylets, n-1)
}
-> DONE

=== function w(weight) ===
~return s(weight,true)

=== function c(cond) ===
~return s(1,cond)

// TODO: Note that when threading multiple storylets, this approach currently increases the
//  weight of storylets immediately after a storylet that was already selected. Must figure out
//  how to handle this properly.
=== function s(my_weight,cond) ===
// public: Specify weight and selection condition for storylet 
{not cond:
    // Anything whose condition is not satisfied is entirely ignored. 
    ~return false
}
~s_cumulative_weight += my_weight
{
- s_first_pass:
    ~return false
- s_check_saved(s_ignore_storylets, s_cumulative_weight):
    // We are in the "ignore" list.
    ~s_ignored_weight += my_weight
    ~return false
- s_check_saved(s_saved_storylets, s_cumulative_weight):
    // We are auto-selected.
    ~s_save_item(s_ignore_storylets, s_cumulative_weight) // ignore in future

    ~s_ran_out = false
    ~return true
- (s_saved_storylets == "") and s_select_item(my_weight):
    // We have been selected!
    ~s_save_item(s_ignore_storylets, s_cumulative_weight) // ignore in future
    ~s_ignored_weight_total += my_weight 
    ~s_ran_out = false
    ~return true
- else:
    ~return false
}

=== function s_select_item(my_weight) ===
~temp remaining_weight = s_total_weight - s_cumulative_weight - (s_ignored_weight_total - s_ignored_weight) + my_weight
~temp prob = RANDOM(0,s_precision_multiplier)/FLOAT(s_precision_multiplier)
~temp thresh = (FLOAT(my_weight)/FLOAT(remaining_weight))
~return prob < thresh



// Saving/loading individual items

=== function s_save_item(ref saved,x) ===
// Insert x into data string of selected weights
~saved = saved + "[{x}]"

=== function s_check_saved(saved,x) ===
// Return true if the given weight has been saved
~return saved ? "[{x}]"





