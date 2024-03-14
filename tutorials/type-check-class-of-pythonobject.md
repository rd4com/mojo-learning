# 🐍🔍 type-checking a PythonObject

> This repo is a community effort, it could contains errors that requires [contributing](/contribute.md) a correction!

&nbsp;

[```Python.type```](https://docs.modular.com/mojo/stdlib/python/python#type) is a function to get the type/class of a PythonObject.



It makes it possible to check if a PythonObject is of the int python class,

before getting it's value as a mojo Int, for example.

&nbsp;

```python
from python import Python

def main():
    #get the class objects
    var int_type  = Python.evaluate("int")      #<class 'int'>
    var bool_type = Python.evaluate("bool")     #<class 'bool'>
    var str_type  = Python.evaluate("str")      #<class 'str'>
    var float_type= Python.evaluate("float")    #<class 'float'>
    var none_type = Python.evaluate("type(None)") #<class 'NoneType'>
    
    #create a python object
    var x = PythonObject("test")

    print(Python.type(x) is str_type) #True

    #change to a bool
    x = True 
    print(Python.type(x) is bool_type) #True

    #change to none
    x = None
    print(Python.type(x) is none_type) #True
```
## 👍 Practical use:

*(the below code is a continuation of the main function above)*
```python
    x = 123
    #1. perform a type-check 
    if Python.type(x) is int_type:
        #2. Create a mojo Int with it 
        var y: Int = int(x) 
        print(y)
    else: 
        print("It is not an Int.")

    #Another example
    x = None
    if Python.type(x) is none_type:
        x = 1234
    
    if Python.type(x) is int_type:
        print(x) #1234, great!
```
#### output
```
123
1234
```

&nbsp;

#### with  ```is not``` :
*(also a continuation of the main function above)*
```python
    x = None
    if Python.type(x) is not int_type:
        x = 123
    print(x) #123, Great!
```

&nbsp;

#### simple method summarized:
```python
from python import Python
def main():     
    #1. get the class to check for
    float_class = Python.evaluate("float")
    #2. possibility to check/validate if needed
    #   below is just a simple check to avoid small typos
    if str(float_class)!= "<class 'float'>":
        raise("It is not the float class")
    #3. start type-checking using that class
    x = PythonObject(0.1)
    if Python.type(x) is float_class:
        print("ok")
```
In *step #1*, the class is obtained using ```Python.evaluate```.

The reason the tutorial uses that way is that we can see a class name right from the start.

&nbsp;

It is possible to get it from an existing PythonObject of that class, just like in python.

but could be less clear about what is being checked, if the reader is not familiar with python.

```python
from python import Python
def main():     
    float_class = Python.type(3.14)
    x = PythonObject(0.1)
    if Python.type(x) is float_class:
        print("ok")
```
*see  [Mojo documentation: Python types](https://docs.modular.com/mojo/manual/python/types#python-types-in-mojo)*

&nbsp; 

## **👍🐍 This is consistent with how python works**:

```python
# 🐍 python_code_example.py
#    meant to be runned by a python interpreter

float_class = float
if str(float_class)!= "<class 'float'>":
    raise("It is not the float class")
x = 0.1
if type(x) is float_class:
    print("ok")


float_class = type(3.14)
x = 0.1
if type(x) is float_class:
    print("ok")
```

*see [Python 3 documentation](https://docs.python.org/3/library/stdtypes.html)*


&nbsp;

### Type checking and imported modules
Lets type check a custom user-created python class:
```python
# 🐍 mycustomclass.py
class MyClass:
    x = 123
```
```python
# 🔥 mymojofile.mojo
from python import Python
def main():     
    # import the module from the current path
    Python.add_to_path(".")
    MyModule = Python.import_module("mycustomclass")
    
    MyInstance = MyModule.MyClass()
    print(MyInstance.x) #123

    if Python.type(MyInstance) is MyModule.MyClass:
        print("ok")

    y = 1.1
    if Python.type(y) is MyModule.MyClass:
        print("Should not print")
```

```Python.import_module``` will raise and error if it fails to import, 

```try:``` and ```except e:``` can also handle errors raised from python, right within mojo!

see [Mojo documentation: Python integration](https://docs.modular.com/mojo/manual/python)

&nbsp;

# ```is```, the identity operator in Python

Once this concept is understood, there are less confusion in understanding that code:
```python
from python import Python
def main():     
    float_class = Python.type(3.14)
    x = PythonObject(0.1)
    if Python.type(x) is float_class:
        print("ok")
```

In python, objects have a unique identifier, it is a number.


If two objects have the same identity, they share the same value.

For example, in python:
```python
a = [1,2]
b = [a,[4,5,6]]

#Changes in a, are reflected in b
a.append(3)
print(b)        #[[1, 2, 3], [4, 5, 6]]

#It is because a and b[0] have the same identity
print(id(a),id(b[0])) #print two same numbers
print(a is b[0])      #True, a is b! 
```

&nbsp;

#### Conclusion to solidify understanding:

in python:
```python
a = 1.5
float_type = float
a_type = type(a)

print(a_type is float_type)         #True
print(id(a_type) == id(float_type)) #True

print(type(5.5) is type(0.1))       #True
```

In mojo now:
```python
from python import Python
def main():     
    a = PythonObject(1.5)
    float_type = Python.evaluate("float")
    a_type = Python.type(a)

    print(a_type is float_type)                             #True
    id_function = Python.evaluate("id")
    print(id_function(a_type) == id_function(float_type))   #True

    print(Python.type(5.5) is Python.type(0.1))             #True
```

Hopefully, you are now able to understand and do type checking with and without ```Python.evaluate``` !

Thanks for reading,

feel free to express feedbacks in order to ameliorate the tutorial and gauge it's helpfulness. 




&nbsp;


> 🗓️🔃 Tutorial updated during the mojo [v24.1.0](https://docs.modular.com/mojo/changelog#v241-2024-02-29) era

🔥 To learn more and better, make sure to read Mojo's [documentation and manual](https://docs.modular.com/mojo/manual/)



# ❤️‍🔥

&nbsp;

&nbsp;

### Going the extra mile with a concrete use case

```python
from python import Python

def main():     
    p_arr = Python.evaluate("[1.1,True,5,'hello']")
    
    if Python.type(p_arr) is Python.evaluate("list"):
        p_arr.append("world")
    else: p_arr = []

    var x = Int(0)
    var y = Float64(0.0)
    var z = False
    for e in p_arr:
        if Python.type(e) is Python.type(99):
            x = int(e)
        if Python.type(e) is Python.type(False):
            z = e.__bool__()
        if Python.type(e) is Python.type(1.1):
            y = e.to_float64()
        if Python.type(e) is Python.type(""):
            print(str(e))
    
    #output: hello
    #output: world
    print(x,y,z) #5 1.1000000000000001 True
```