## HeapqTimer

* Algorithm Description:<br>
Link the same touch interval timernode to one unidirectional list and push the head node into min heap queue

* API Description:
```
TimerMgr:add_timer(func, T, N)  --new a timer per T(ms) interval proc func one time, total touch n times. Return value is the allocate session associated with timer
TimerMgr:remove_timer( session ) --delete a timer by associated session
TimerMgr:size()  --the node num in heap, equal to the num of different timer interval
TimerMgr:timer_num() --the total timer num
TimerMgr:set_time( T )  --set T as specify time, and the get_time() will return T
TimerMgr:get_time()     --return T if use set_time(T) to specify time, else return the real millisecond
TimerMgr:min_wakeup_spacing()  --get the interval between get_time() time and the top node wakeup time
TimerMgr:update( cur_time )  --check all timer nodes whether wakeup at cur_time(default value is get_time())
```

## PreEnv
```
lua5.3
```

## Build(linux):
```
make -C dep/
```

## Test:
```
lua test.lua  --functional testing
lua benchtest.lua  --performance testing
```