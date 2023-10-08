
# 📸 pre-calculate fibonacci at compilation   
```python
@nonmaterializable(Int)
struct ComptimeFibonnaci:
    var value: Int
    var prev: Int
    fn __init__(inout self,n:Int):
        self.value = 1
        self.prev = 0
        
        for i in range(n):
            let tmp = self.value
            let new = self.value+self.prev
            self.value = new
            self.prev = tmp

    fn as_int(self) -> Int:
        return self.value

    fn as_string(self) -> String:
        return String(self.value)

def some_function[comptime:ComptimeFibonnaci]():

    @parameter
    if comptime.value > 255:
        print("saved on tons of time")

    let str = comptime.as_string()
    print(str)

def main():
    alias the_index = ComptimeFibonnaci(45)
    some_function[the_index]() 
```
