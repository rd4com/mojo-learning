# ⌨️ introduction to types
> with v0.5.0
## Declaration of variables
```let```: immutable, constant, cannot be changed

```var```: variable, can re-assign it another value
## Types
defined after the semi column```:```
```python
def main():
    let x:Int = 1
    var y:Int = 1
    y = 2
```
##### common types:
- Int
- Float
- String
- Bool

##### important:
- once defined, the type of the variable cannot be changed for another one
## functions
##### passing an argument
```python
def PrintNumber(Number:Int):
    print(Number)
```
```python
def main():
    let TheNumber:Int = 1
    PrintNumber(TheNumber)
```
##### returning a value
the return type is written after the arrow ```->```
```python
def add(a,b):
    return a+b

def add(a:Int ,b: Int)->Int:
    return a+b

def add(a:Float64 ,b: Float64)->Float64:
    return a+b
```
##### default arguments value and named arguments
```python
def greet(name:String="learner" ,message: String = "Hello "):
    print(message+name)
```
```python
def main():
    greet() #Hello learner
    greet(name="") #Hello
    greet(message="Greetings ") #Greetings learner
```
##### modify an argument from within a function
add ```inout``` before the argument name

```python
def increase(inout Number: Int):
    Number+=1
```
```python
def main():
    var TheNumber:Int = 0
    increase(TheNumber)
    print(TheNumber) # 1
```

## Structures
The ```@value``` for a short example, it simply adds a few methods for us.

They can also be added manually as needed.
```python
@value
struct Computer:
    var cores: Int
    var is_running: Bool
    var ram_size: Int

    fn __init__(inout self,cores:Int = 4,state:Bool = False):
        self.cores = cores
        self.is_running = state
        self.ram_size = 1024

    fn start(inout self):
        self.is_running = True
        print("ram size:", self.ram_size)

def ImproveComputer(inout existing:Computer, improved: Computer):
    existing.cores = improved.cores
    existing.ram_size = improved.ram_size

def main():
    var MyComputer = Computer()

    var NextComputer = Computer(cores=8)
    NextComputer.ram_size *= 4

    ImproveComputer(MyComputer,NextComputer)
    
    MyComputer.start() #ram size: 4096
```