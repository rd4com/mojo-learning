# Foreign function interface
> part of the effort for the community
> https://github.com/Lynet101/Mojo_community-lib

> ./mojo.sh && ./main
```
var lib = lib_loader("./lib.so")
var my_func = lib.get[fn(Pointer[Int8])->Int]("my_func")

var ptr = Pointer[Int8]().alloc(5)
var int_result = my_func(ptr)

print("hello "+String(ptr,5))
print(int_result)
```
