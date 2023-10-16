# 🕯️ [reader.read\[Int32,"swap"\](3) in 45 lines]() 
> with mojo v0.4.0 

Theses mojo features are used:
- [alias](https://docs.modular.com/mojo/programming-manual.html#alias-named-parameter-expressions)
- [bitcasted](https://docs.modular.com/mojo/stdlib/memory/unsafe.html#bitcast) pointer to generic T
- [generic struct](https://docs.modular.com/mojo/programming-manual.html#defining-parameterized-types-and-functions) ([T] is a parameter)
- [@parameter if](https://docs.modular.com/mojo/programming-manual.html#powerful-compile-time-programming)
- [parameter with a default value](https://docs.modular.com/mojo/programming-manual.html#using-default-parameter-values)
- [extend lifetime](https://docs.modular.com/mojo/programming-manual.html#field-lifetimes-of-owned-arguments-in-__moveinit__-and-__del__) with _ = pointer
- [Raising errors: dynamic messages](https://docs.modular.com/mojo/changelog.html#v0.4.0-2023-10-05)
- [sizeof\[T\]()](https://docs.modular.com/mojo/stdlib/sys/info.html#sizeof) 
- [raising errors](https://docs.modular.com/mojo/stdlib/builtin/error.html)

It is nice to see how they work together.

*note: how productive and user friendly 🔥 is* 
> ⚠️ the code has not been tested, not ready for use

```python
def main():
    var reader = file_reader("data_from_ruby")
    
    #return a Pointer to four Uint32
    let LE_ui32 = reader.read[UInt32](4)

    for i in range(4):
        print(LE_ui32.load(i))

    #two Float32, converted from another endian-ness
    
    let BE_f32 = reader.read[Float32,"swap"](2)
    
    print(BE_f32.load(0))
    print(BE_f32.load(1))
    
    #free the pointers
    LE_ui32.free()
    BE_f32.free()

    #move the reader cursor back four bytes
    reader.offset -=4

    #Float32 (not pointer), converted from another endian-ness
    print(reader.read_one[Float32,"swap"]())
```



```python
from sys.info import sizeof

struct file_reader:
    var data:DTypePointer[DType.uint8]
    var size: Int
    var offset:Int

    fn __init__(inout self,filename:String) raises:
        #open the file
        var handler = open(filename,"r")

        #pointer with no allocation done:
        self.data = DTypePointer[DType.uint8]()
        self.size = 0
        self.offset = 0
        
        #read the file into tmp
        let tmp = handler.read()
        self.size = tmp._buffer.size
        self.data = self.data.alloc(self.size)
        
        #interpret the bytes as uint8 when .load(index)
        let tmp_ptr = tmp._as_ptr().bitcast[DType.uint8]()
        
        #copy the content of tmp into self.data
        for i in range(self.size):
            self.data.store(i,tmp_ptr.load(i))
        
        _=tmp #extending the lifetime to more than tmp_ptr
        #if dont do, tmp will be freed when last used
        #and tmp_ptr will point to freed memory
        
        #close the file
        handler.close()
    
    fn read_one[T:AnyType,endian:StringLiteral= "not_swap"](inout self) raises->T:
        let tmp = self.read[T,endian](1)
        let tmp2:T = tmp.load(0)
        tmp.free()
        return tmp2
    
    #"be" is default if no value is passed
    fn read[T:AnyType,endian:StringLiteral= "not_swap"](inout self,e: Int = 1) raises->Pointer[T]:
        
        #size of T in bytes multiplied by elements
        let fsize = e*sizeof[T]()
        
        if (self.offset+fsize-1)>self.size:
            raise Error("file is not that big")
        
        let tmp = Pointer[UInt8]().alloc(fsize)
        
        for i in range(fsize):
            tmp.store(i,self.data.load(i+self.offset))
        
        self.offset+=fsize
        
        #swapping the bytes if specified:
        @parameter
        #"not_swap" is the default parameter value!
        if endian == "swap":
            alias sizeoft=sizeof[T]()

            let tmp_for_swap = Pointer[UInt8]().alloc(sizeoft)
            
            for i in range(0,fsize,sizeoft):
                for i2 in range(0,sizeoft):
                    tmp_for_swap.store(i2,tmp.load(i+i2))
                for i2 in range(0,sizeoft):
                    tmp.store(i+i2,tmp_for_swap.load(sizeoft-1-i2))
            
            tmp_for_swap.free()
        #Pointer[UInt8] to Pointer[T]
        #does not modify the data, just provide "a viewer"
        return tmp.bitcast[T]()

    #when instance of file_reader is deleted
    fn __del__(owned self):
        #free memory
        self.data.free()
```
```ruby
# ruby code to generate data
File.write("name.extension",[1,2,3,4,1.1,2.5].pack("l<4g2"))
```