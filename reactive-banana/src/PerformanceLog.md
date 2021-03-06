Performance Log
===============

The following procedure seems to be effective for improving performance:

* Run profiling tools to see where changes are needed.
* Change the code and record the new running time in a log to see how it improves.
* Rinse and repeat. Stop when the changes become too intrusive or are no longer worth the effort.

This is the log for sessions dedicated to the improvement of `reactive-banana`.

Jan 23, 2014
------------
Starting point

    > benchmark 100 3000

* Monomorphic queue
    ~ 2.09 secs

* Specialize `traverseDependencies`
    ~ 2.03 secs

* Remove writer from `EvalP` monad
    ~ 1.44 secs

* Choose better queue implementation from `pqeue` package
    ~ 1.10 secs

* Correct queue implementation so that it doesn't have duplicate elements anymore.
    ~ 1.26 secs
    ~ 20% of the running time seems to be spent in queue `insert` operation, so subsequent improvements cannot improve upon that.

* Turn `EvalP` into a reader monad to avoid lifting `Build` in many cases.
    ~ 1.03 secs
