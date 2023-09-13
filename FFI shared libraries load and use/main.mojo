import sys.ffi
import builtin.io

struct lib_loader:
    var handler:ffi.DLHandle

    fn __init__(inout self: Self, file: StringRef):
        self.handler = ffi.DLHandle(file,ffi.RTLD.LAZY)

    fn get[T:AnyType](inout self,key:StringRef) -> T:
        return self.handler.get_function[T](key)

fn main():

    var lib = lib_loader("./lib.so")
    var my_func = lib.get[fn(Pointer[Int8])->Int]("my_func")

    var ptr = Pointer[Int8]().alloc(5)
    var int_result = my_func(ptr)

    print("hello "+String(ptr,5))
    print(int_result)
