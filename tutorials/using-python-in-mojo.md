# 🐍 using python in mojo: a to z

> with v0.4.0

👷 under active development, see [contributions](/contribute.md)
### Import python in mojo
```python
from python import Python
```
### create mutable variable res
```python
def main():
    var res:PythonObject 
```
### list comprehension
```python
    res = Python.evaluate("[x*x for x in range(1,4)]")

    for i in res: # i is a PythonObject
        let element:Float64 = i.to_float64()
        print(element) #1.0 4.0 9.0
```
### call methods
```python
    res = " and " #res is a PythonObject 

    #call join method
    res = res.join(["mojo","python"])

    print(res) #print: mojo and python
```
### list
```python
    res =[]
    res.append(Float64(1))
    res.append("hello world")
    res.append(True)
    res.pop()
    res.append(False)
    print(res) #[1.0, 'hello world', False]
```
### tuples
```python
    res = (True,0)
    print(res[0])
    print(res[1])
```
### get and call python functions
```python
    res = Python.evaluate("bin")
    print(res(15)) #0b1111
```
### types
```python
    res = 1.0
    print(res.__class__.__name__) #float
```

### instance
```python
    res = True
    let is_instance = Python.evaluate("isinstance")
    let float_type = Python.evaluate("bool")
    print(is_instance(res,float_type))
```

### convert to mojo types
```python
    res = "hello world"
    let res_b:String = res.upper().to_string()
    print(res_b) #HELLO WORLD

    res = 1.0
    let res_c:Float64 = res.to_float64()

    res = 123
    let res_d:Int = res.__index__()

    res = True
    let res_e:Bool = res.__bool__()

```

# with pip modules
### numpy linspace
```python
    res = Python.import_module("numpy").linspace(0, 1.0, 5)
    print(res) #[0.   0.25 0.5  0.75 1.  ]
```
### matplotlib plotting
```python
    res = Python.import_module("matplotlib.pyplot")
    res.plot([1.1,2.2,4.4])
    res.show()
```
# importing a custom python file
#### main.mojo:
```python
from python import Python

def main():
    #path to the file (current directory)
    Python.add_to_path("./")

    #name of the file without .py
    let my_module = Python.import_module("python_file")

    my_module.my_func(2, 3)
```
#### python_file.py:
```python
def my_func(a,b):
    print(a+b)
```


