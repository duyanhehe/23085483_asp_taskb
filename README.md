# **ASP Assignment – Task B**

## **Build**

```bash
zig build
```

Executables produced:

* `zig-out/bin/task1a`
* `zig-out/bin/task1b`
* `zig-out/bin/task1c`

---

## **Run**

```
zig build run-task1a
zig build run-task1b
zig build run-task1c
```

It includes:
* Task 1a: Basic context capture + resume
* Task 1b: Simple fiber with custom stack
* Task 1c: Two fibers with stack alignment + red zone handling



---

## **Test**

Each task has test files:

* `task1a/test.zig`
* `task1b/test.zig`
* `task1c/test.zig`

These tests validate:

* Struct layout
* Stack growth direction
* Correct stack pointer arithmetic
* 16-byte alignment
* Red zone subtraction
* Correct function pointers (`foo`, `goo`) are assigned

The tests do *not* run actual fiber switching (because `set_context()` halts test execution), but instead simulate the logic safely.

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
#### Expected output
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
#### Expected output
```
you called foo
you entered goo
```
#### Explanation
Two switches occur: \
Switch 1: `main -> foo` at `set_context(&c);` \
Switch 2: `foo -> goo` at `set_context(&c2);` \
So the full flow is `main -> foo -> goo`


