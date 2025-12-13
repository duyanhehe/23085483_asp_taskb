# **ASP Assignment – Task B**

## **Build**

```bash
zig build
```

Executables produced:

* `zig-out/bin/task1a`
* `zig-out/bin/task1b`
* `zig-out/bin/task1c`
* `zig-out/bin/task2`
* `zig-out/bin/task2test`

---

## **Run**

```
zig build run-task1a
zig build run-task1b
zig build run-task1c
zig build run-task2
zig build test-task2
```

It includes:
* Task 1a: Basic context capture + resume
* Task 1b: Simple fiber with custom stack
* Task 1c: Two fibers with stack alignment + red zone handling
* Task 2: Cooperative Fiber Runtime

---

## **Test**

Each task has test files:

* `task1a/test.zig`
* `task1b/test.zig`
* `task1c/test.zig`
* `task2/test.zig`
- For task 1, use testing function built in Zig file. 
- For task 2, run `zig build test-task2`
---

## **Task 1**
### Task 1a
#### Expected output
```
a message
a message
```
#### Explanation

- In task 1a, `get_context` saves the current CPU state, and `set_context` restores it. Both occur inside function `main`. 
- The control switch happens at this line:
`set_context(@ptrCast(&c));` 
- `set_context` makes the program resume as though `get_context` returned again, making it produce the output twice.

### Task 1b
#### Expected Output
```
you called foo
```
#### Explanation
Switch happens at `set_context(&c);` where it is set as
```
c.rip = @ptrCast(@alignCast(@constCast(&foo)));
c.rsp = @ptrCast(@alignCast(sp));
```
so control switches from `main -> foo`, this is the first actual fiber jump

### Task 1c
#### Expected Output
```
you called foo
you entered goo
```
#### Explanation
Two switches occur: \
Switch 1: `main -> foo` at `set_context(&c);` \
Switch 2: `foo -> goo` at `set_context(&c2);` \
So the full flow is `main -> foo -> goo`

### Task 2
#### Expected Output
Running `main.zig` by `zig build run-task2`
```
Foo is running
```
Running `test.zig` by `zig build test-task2`
```
fiber 1: 10
fiber 2: 11
```

#### Explanation
Task 2 implements a lightweight cooperative fiber runtime in Zig. \
The runtime includes:
- A `fiber` type in `fiber.zig`
- A round-robin Scheduler in `schedule.zig`, support for:
    - `spawn()`
    - `do_it()`
    - `fiber_exit()`
    - `get_data()`
- Context switching using the provided low-level assembly library `libcontext.a`
- Sys V ABI-compliant stack alignment and red-zone handling
- Passing data between fibers
1. **Fiber Implementation** \
In this design, a fiber is defined by:
- Its own stack
- A context struct (`rip`, `rsp`, and other registers)
- A pointer to optional data \
- Each fiber:
    1. Allocates a private 4096-byte stack
    2. Aligns the top of stack to 16 bytes (Sys V ABI)
    3. Reserves 128 bytes red zone under the stack pointer
    4. Initializes the context so that `rip = func` and `rsp = aligned stack pointer` \
- Stack setup summary:
```
// stack grows DOWNWARD
var sp: usize = @intFromPtr(mem.ptr) + stack_size;

// align to 16 bytes
sp = sp & ~(@as(usize, 16 - 1));

// subtract 128 red-zone
sp -= 128;
```
- Without these 2 adjustments, control transfer using `set_context` would crash unpredictably

2. **Scheduler Design** \
The scheduler:
- Manages a queue of pending fibers
- Tracks the currently running fiber
- Uses `get_context` and `set_context` to switch between scheduler and fibers
- Runs each fiber exactly once
- Round-robin scheduling. Fibers must run in the order they are spawned, so a `FIFO` structure is required. \
`fibers_: std.ArrayListUnmanaged(*Fiber)` is used, supports `append()` and `orderedRemoved(0)`.

3. **Reasons to make `s` global**
- Fibers run on a separate stack
    - A fiber can't return to a caller through normal function return semantics. When a fiber is running, we have no call chain connecting it to `main()`.
    - So if a fiber needs to call `fiber_exit()` or `get_data()`,  it can't receive a scheduler reference through arguments or return values
- `set_context` jumps erase the call stack
    - It completely replaces the current execution context. All normal caller/callee relationships vanish so a fiber can't "remember" who invoked it
- Conclusion: `s` is made global so fibers have a way to access the scheduler after control flow has jumped using `set_context`, which breaks normal function call structure.

4. **Example: Passing data between fibers** \
Running `test.zig` by `zig build test-task2` demonstrates shared state mutation: \
Expected Output
```
fiber 1: 10
fiber 2: 11
``` 
Fiber 1 increments shared data (`dp.* += 1`) before exiting. \
Fiber 2 observes the updated value. \
The implementation is accomplished using
```
// RETURNS pointer passed to fiber OR null
    pub fn get_data(self: *Scheduler) ?*i32 {
        if (self.current_) |fiber| {
            return fiber.data_;
        }
        return null;
    }
```

5. **Notes**
- Implementing stacked-based coroutines requires manual context management
- Context switching breaks normal call stack assumptions
- SysV ABI rules for stack alignment and red zone are non-optional
- Global scheduler access is mandatory for fibers
- Cooperative scheduling makes concurrency predictable and deterministic