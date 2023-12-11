# 🧹 ASAP: will call ```__del__``` when last used
> with v0.4.0

##### *this page is a community effort and may contains errors. please contribute any corrections if needed.*

It's wonderful because mojo free memory as soon as possible.

Lifetimes is on the roadmap: [Ownership and Lifetimes](https://docs.modular.com/mojo/roadmap.html#ownership-and-lifetimes).

source: [Behavior of destructors](https://docs.modular.com/mojo/programming-manual.html#behavior-of-destructors) 


### using that struct as an example:
```python
@value
struct ValuePointer:
    
    var pointer: Pointer[Int]

    #instantiate
    def __init__(inout self):
        #allocate memory
        self.pointer = Pointer[Int].alloc(1)
        #store 123
        self.pointer.store(0,123)

    #delete
    def __del__(owned self):
        #free memory
        self.pointer.free()
```
### the challenge:
```python
def main():

    var original = ValuePointer()

    #original is deleted here after last use/access:
    var copy_of_pointer = original.pointer

    #copy now point to freed memory
    print(copy_of_pointer.load(0))
```
1. original will get deleted after it's last use, the pointer inside will be freed by
our ```__del__``` function.
2. copy_of_pointer now point to freed memory and unknown data is printed 


### the solution:
```python
def main():

    var original = ValuePointer()

    var copy_of_pointer = original.pointer

    print(copy_of_pointer.load(0))

    #original is deleted here after last use/access:
    _ = original
```

by assigning original to ```_``` , it's last use will be there.

copy_of_pointer no will longer point to freed memory.

123 got printed.

