
# 🫙 struct as a namespace (@staticmethod)


Using python functions from mojo with a wrapper:

```python   
fn main():
    print(strings.contains("hello world","hello"))
    print(strings.endswith("hello world","world"))
    print(strings.count("hello world","l"))
    print(strings.find("hello world","l"))
    print(strings.replace("hello world world","world","planet"))
```

>  *the global scope is clean, not cluttered*

A function marked by the decorator ```@staticmethod``` is called on the struct.

> *the struct act as a namespace !*

No need to instantiate an object.



```python
struct strings:
    
    @staticmethod   #without try: except
    def center(a:String,b:Int) -> String:
        return PythonObject(a).center(PythonObject(b)).to_string()
    
    @staticmethod
    fn replace(a:String,b:String,c:String)->String:
        try:
            return PythonObject(a).replace(PythonObject(b),PythonObject(c)).to_string()
        except e:
            print(e)
            return ""

    @staticmethod
    fn contains(a:String,b:String)->Bool:
        try:
            if PythonObject(a).find(PythonObject(b)) == -1:
                return False
            else:
                return True
        except e:
            print(e)
            return False
    
    @staticmethod
    fn endswith(a:String,b:String)->Bool:
        try:
            return PythonObject(a).endswith(PythonObject(b)).__bool__()
        except e:
            print(e)
            return False
    
    @staticmethod
    fn count(a:String,b:String)->Int:
        try:
            return PythonObject(a).count(PythonObject(b)).to_float64().__int__()
        except e:
            print(e)
            return -1
    
    @staticmethod
    fn find(a:String,b:String)->Int:
        try:
            return PythonObject(a).find(PythonObject(b)).to_float64().__int__()
        except e:
            print(e)
            return -1
```

```try: except:``` could be left unused, but it is a good habit for later!

# 🗃️ organised

- packages
- modules
- struct
  - @staticmethod
