from python import Python
from python import PythonObject
from math import math
from time import now

struct np_loader:
    var lib:PythonObject
    var loaded: Bool
    fn __init__(inout self):
        try:
            self.lib = Python.import_module("numpy")
            self.loaded = True
        except e:
            self.loaded = False
    fn __getitem__(inout self, key:StringLiteral)raises->PythonObject:
        return self.lib.__getattr__(key)

fn main() raises:
    var np = np_loader()
    if np.loaded:
        var python_result = np["linspace"](0, 255,256) #get linear space from python
        var simd_mojo_array = SIMD[DType.float64,256]() #simd is really fast

        var size:Int=python_result.size.to_float64().to_int() #convert arr size to mojo int
        for x in range(size):
            simd_mojo_array[x]=python_result[x].to_float64() #from python float object to mojo float

        var pi = np["pi"].to_float64()

        var start:Int64
        var after:Int64
        #compute one cycles of 256hz


        var backup = simd_mojo_array

        var min_cnt:Int64=99999999
        var tmp:Int64
        for i in range(1000000):
            simd_mojo_array = backup
            start= now()
            simd_mojo_array = math.cos(simd_mojo_array*(pi*2.0/256.0))
            after= now()
            tmp=after-start
            #print(tmp)
            if tmp<min_cnt:
                min_cnt=tmp


        print("------------------")
        print(min_cnt) #mincount is 71 nanoseconds using now()
                       #using readcyclecounter
                       #is its 124 clock cycles
        print("------------------")

        #-------------------------
        #with cyclecounts:
        #sometimes the value of after-start is huge because the counter overflow and wrap
        #because its increased on each cpu instruction and theres a lot
        ##
        #the reason to get the min is that there is more program than this one running on
        #the cpu so, by taking the smallest we left with only instructions execute by this one
        #i got I5 3400mhz
        #so that is:
        var mhz_1 = 1000000.0 #1 mhz is that amount on instruction per second
        var instructions_1_second:Float64 = 3400.0 * mhz_1

        var min_flt:Float64 = min_cnt.to_int()
        var result = min_flt / instructions_1_second
        print(result) #in seconds
        print(result*1000000000.0) #in nanosecond, 36 for me

