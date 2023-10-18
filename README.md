

# 📖 Learning mojo language
###  ⚠️  not affiliated with Modular or Mojo
&nbsp; 

### [🔍 Why](/why.md) 
### [🔦 Introduction](/introduction.md)
### [🫵 corrections and contributions](contribute.md) 
&nbsp; 

# [🔁 Python land and mojo land, PythonObject](tutorials/python-world-mojo-world.md) 
there is also an example with a lot of comments using numpy and matplotlib. 

# [🛣️ 🚌 multi-core (parallelize) with simd](tutorials/multi-core-parallelize-with-simd%20.md) 
simd and parallelize.

# 🫙 [struct as a namespace (@staticmethod)](tutorials/struct-as-namespace.md)
example: wrap python functions

# [🏳️ make test builds using a custom flag](tutorials/make-test-builds-using-a-custom-flag.md)
mojo build program.mojo -D...

# [🕯️ reader.read\[Int32,"swap"\](3) in 45 lines](tutorials/reader-in-few-lines-with-endian-ness.md)
v0.4.0: powerfull magic 

# [🔥 making compile time functions](tutorials/compile-time-functions.md)
Pointer[Int] of squared numbers

# 🤙 [callbacks trough parameters](tutorials/callbacks-trough-parameters.md)
toy markdown generator as an example

# [🌊 256Hz: simd cosine and plot it](tutorials/vectorise-simd-cosine.md)
one cycle by vectorizing simd instructions, plot with python


&nbsp; 
## Need revision: 
# [simd cosine with np.linspace](tutorials/numpy-simd.md)
import numpy using ```try:``` and ```except:``` inside a struct wrapper, meta-programming with ```__getitem__``` to get linspace, conversion to ```SIMD[DType.float64,size]```, apply ```math.cos()```

