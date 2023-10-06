## Version of mojo when written: v0.3.0
#### This is not an official documentation, this is a community effort, there could be incorrect infos here, please see [the official documentation of mojo](https://docs.modular.com/mojo/).
> There are links to the official documentation wich is very precise and awesome.
```python
from python import Python
from python import PythonObject

#The PythonObject is a mojo type that can store python objects of any class               https://docs.modular.com/mojo/stdlib/python/object.html

fn plot_from_mojo(values: PythonObject) raises:
    let plt = Python.import_module("matplotlib.pyplot")     #require matplotlib package to be installed
    plt.plot(values)                                        #theses values comes from numpy
                                                            #that python object class is ndarray: print(values.__class__.__name__)
    plt.show()

fn numpy_array_from_mojo() raises -> PythonObject:
    let np = Python.import_module("numpy")      #np is a PythonObject                      https://docs.modular.com/mojo/stdlib/python/python.html#import_module
                                                #let np:PythonObject...
   
    var x = PythonObject([])                    #x: PythonObject, class: list              https://docs.modular.com/mojo/stdlib/python/object.html#init__
                                                #initialized from an empty list literal    https://docs.modular.com/mojo/stdlib/builtin/builtin_list.html
                                                #note that [] is in mojo world!
    
    var range_size:Int = 256                    #Mojo Int!                                 https://docs.modular.com/mojo/stdlib/builtin/int.html
    for i in range(range_size):                 #i is a mojo Int                           https://docs.modular.com/mojo/stdlib/builtin/range.html
        x.append(i)                             #i is automatically converted to Python object by __init__ of PythonObject
                                                #note that append is a python method of the list class since x is a PythonObject!
                                                #append is in python land and mojo can call it!
                                                
                                                #note that append is not a method of PythonObject,  https://docs.modular.com/mojo/stdlib/python/object.html
                                                #It lives in python land and mojo is able to find it inside the python object.
                                                
                                                #This is why it is possible to import any created python file.
                                                #ex: var my_python_file = Python.import_module("my_python_file_name") #no .py needed
                                                #    my_python_file.my_function([1,2,3])
                                                                                           #https://docs.modular.com/mojo/stdlib/python/python.html#add_to_path
                                                                                           #https://docs.modular.com/mojo/stdlib/python/python.html#import_module
    
    return np.cos(np.array(x)*np.pi*2.0/256.0)  #np.cos return a python object of class ndarray


def main():            
    var results = numpy_array_from_mojo()       #numpy_array_from_mojo is a mojo function that return a PythonObject.
    plot_from_mojo(results)                     #plot_from_mojo is a mojo function that takes a PythonObject.
    
    #note that results "travel" trough mojo functions,as a PythonObject, but can also be passed to python land functions,as a PythonObject.
```
