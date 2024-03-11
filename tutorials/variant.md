# 👜 Variant, a type that can hold values of different types

[Variant](https://docs.modular.com/mojo/stdlib/utils/variant) is a type, just like Bool, Int32 and DynamicVector, .. 

But the type of the value it holds can vary, thus the name, Variant.

&nbsp;

A ```Variant[Int,Bool]``` can hold a value of either ```Int``` or ```Bool```, for example.

The type of the **current value** it holds can be **checked**, and it's value retrieved.

&nbsp;

We can also **reassign** it a **value**, either of the **current type**, or **another types** it supports.

&nbsp;

It is **kind of** like an object in python, but for struct. (a way to think about it, in order to understand)

&nbsp;

At the end of the small tutorial, we will create a list that can contain a mixture of any types.

 just like a list in python, with only two lines of mojo code:
 ```python
alias MyObject = Variant[Bool,Int,String,Float64]
var list = DynamicVector[MyObject]()
 ```
 (It is exciting, reading the page in a top to bottom order is recommended)

&nbsp;


### ✈️ overview  of usage 

```python
var BuddyInLivingRoom: Variant[Dog,Cat,Bool] #Dog and Cat types in example section

#Assign a value of type Bool
BuddyInLivingRoom = False

#Check if the current value type is Bool (and not Cat or Dog)
if BuddyInLivingRoom.isa[Bool](): print("Nobody there")
#(Note that we check if it is a Bool, NOT the value it contains)

#Assign a value of another type
BuddyInLivingRoom.set(Dog("Sweetheart"))

#Check if the value type is Dog
if BuddyInLivingRoom.isa[Dog](): print("It must be sweetheart") 

#Dereference the value as Dog type and interact with it
if BuddyInLivingRoom.get[Dog]()[].name == "Sweetheart": print("knew it !")
```

&nbsp;

# ⚠️ important and easy
Before retrieving a value of type cat,

It is important to check if the variant is currently holding a value of cat type:
1. ### 🛂 check type ```if BuddyInLivingRoom.isa[Cat]() == True```
2. ### 🛄 get the reference: ```v = BuddyInLivingRoom.get[Cat]()```
3. ### 🛃 dereference and get a copy: ```the_cat = v[]```
4. ### 🛜 (a) interact with the copy: ```print(the_cat.name)```
5. ### 🛜 (b) interact with the original: ```v[].name = "new name"```

&nbsp;
# The methods of the variant type

- ```.set(Dog("name"))```
    
    It is important to use that function when **re-assigning** a value,
    
    because the **destructor** of the previous value need to be called. (ensure cleanup logic in ```__del__```)
- ```.isa[Cat]()```
    
    Necessary to check the type of the current value of the variant.

    That way, ```.get[Cat]()``` can saferly returns a reference to a ```Cat``` value.


- ```.get[Dog]()```

    Returns a reference (of type ```Dog```) to the value stored in the variant.
    
    Can be dereferenced with square brackets(```[]```)

    Example: ```name = v.get[Dog]()[].name```

- ```.take[Cat]()```
    
    move the value out of the variant.

    that way, the destructor is **not** called and we can move it elsewhere again (into a function for example).

    Type checking is necessary in order to avoid dereferencing as the wrong type. (```.isa[Dog]()```)
  
    ⚠️ *Be mindfull that ```.set```  assume that a previous value exist and call the destructor on it.*
    
    *If the value was taken out,
    there is no valid value to call a destructor on.*
    
    *It is possible to re-assign another value to the variant with ```=``` instead of ```set```.*

    *That way, the destructor won't be called.* ⚠️

    

&nbsp;

# Happy relationship between ```.Get[T]()``` and ```Reference```
```.get[T]()``` returns a reference to a value of type ```T```.

it is possible to mutate the original value in an easy manner,
by dereferencing on the left side of the ```=``` sign. (see 🔵)



```python
from utils.variant import Variant

def main():
    var V:Variant[Int,String]
    V = String("hello world")

    #Mutate the original, trough the reference
    V.get[String]()[]="new"                     #🔵
    print(V.get[String]()[]) #"new"
    
    #Dereference and create a copy
    V_copy = V.get[String]()[]
    V_copy = "won't mutate original"

    print(V.get[String]()[]) #"new"
```
⚠️ Note that 🔵 operate on a String reference, so assigning an Int would implicitely convert it to a String.

The type of the current value of the variant would still be of String type and it's value would be String("123")

It makes more sense to use ```V.set[Int](123)``` in that case.

&nbsp;

# 👨‍🏭 Example
```python
from utils.variant import Variant

@value
struct Cat(CollectionElement):
    var name: String
@value
struct Dog(CollectionElement):
    var name: String

def buddy_name(buddy: Variant[Dog,Cat])->String:
    if buddy.isa[Dog]():
        ref_to_buddy = buddy.get[Dog]()
        the_buddy = ref_to_buddy[] #dereference it
        return the_buddy.name
    if buddy.isa[Cat]():
        ref_to_buddy = buddy.get[Cat]()
        the_buddy = ref_to_buddy[]
        return the_buddy.name
    return "some return that could be replaced by an optional or variant"

def main():
    #Declare a variable of type Variant, 
    #can hold a value of either Dog or Cat type.
    var MyBuddy:Variant[Dog,Cat]

    MyBuddy = Dog("sweetheart")
    print(buddy_name(MyBuddy))

    MyBuddy.set(Cat("mona"))
    print(buddy_name(MyBuddy))

    #Getting the type it currently holds:
    if MyBuddy.isa[Cat](): print("Cat!")
    if MyBuddy.isa[Dog](): print("Dog!")

    #It can be changed any time !
    for i in range(3):
        MyBuddy.set(Dog("minisweetheart "+String(i)))
        print(buddy_name(MyBuddy))
    for i in range(3):
        MyBuddy.set(Cat("minimona "+String(i)))
        print(buddy_name(MyBuddy)) 

    #In addition to Dog and Cat,
    #It is possible to add another type to the variant
    #Bool could be added as an hint that it is an empty value(neither cat or dog)

    var BuddyInLivingRoom: Variant[Dog,Cat,Bool]
    BuddyInLivingRoom = False
    if BuddyInLivingRoom.isa[Bool](): print("Nobody there")
    
    BuddyInLivingRoom.set(Dog("Sweetheart"))
    if BuddyInLivingRoom.isa[Dog](): print("It must be Sweetheart") 
    if BuddyInLivingRoom.get[Dog]()[].name == "Sweetheart": print("knew it !")
```
&nbsp;

### ```Variant``` is user-friendly and usefull, make sure to put it in your toolbox where you can see it.

### Both ```Variant``` and ```traits``` allows for passing values of multiples type to functions, for example.

&nbsp;


&nbsp;

# Starting point exercice to make friend with Variant 

Feel free to meet ```Variant``` in a brand new ```def main():``` function, 

it wants to play "guess what's in the box" with it's new friend.

```python
from utils.variant import Variant

def main():
    seed()
    var V:Variant[Int,Float32,Bool] = get_box()
    if V.isa[Bool]():
        print(V.get[Bool]()[])
        ref = V.get[Bool]()
        ref[] = not ref[]
        print(V.get[Bool]()[])
    #Improve the game, Variant is always playful
    #It takes very little time to complete it.
    #Once done, Variant will always be there for you!

from random import seed, random_si64
def get_box()->Variant[Int,Float32,Bool]:
    var tmp = Variant[Int,Float32,Bool](True)
    v = random_si64(0,2)
    if v == 0: tmp.set[Int](0)
    if v == 1: tmp.set[Float32](1.0)
    if v == 2: tmp.set[Bool](random_si64(0,1)==1)
    return tmp
```

&nbsp;

# 💝 ```Variant[Bool,Int,String,Float64]```


With variant, it is possible create a type, that appears to be an object.

Just decide a big variant of all the types you want it to be able to be.

In combination with ```alias```, the big  and powerful variant, can be given sort of a short name.  

Let's create a list of it, so that we can store different types in the same list.


```python
from utils.variant import Variant
alias MyObject = Variant[Bool,Int,String,Float64]

def main():
    var list = DynamicVector[MyObject]() #🔥
    list.push_back(MyObject(True))
    list.push_back(MyObject(Float64(1.1)))
    list.push_back(MyObject(9))
    list.push_back(MyObject(String("hello world")))

    for i in range(len(list)):
        v = list[i]
        if v.isa[Bool](): print("Bool:  ",v.get[Bool]()[])
        if v.isa[Int]():  print("Int: " , v.get[Int]()[])
        if v.isa[String]():  print("String:  ", v.get[String]()[])
        if v.isa[Float64](): print("Float64: ", v.get[Float64]()[])
```
### output
```
Bool:   True
Float64:  1.1000000000000001
Int:  9
String:   hello world
```
&nbsp;

# 👏🌴

If you never did low-level code before, congratulation.

What you now can do would be called a "vector of typesafe union" in C++.

Let's just call it pizza.

At the end of the day, it is just a type that can sort-of vary, and we can give it a short name.

Two concepts: ```alias``` and 
```Variant```

&nbsp;

### Interesting interaction with a function
```python
from utils.variant import Variant
alias MyObject = Variant[Bool,Int,String,Float64]

def main():
    v = MyObject(True)  #Bool
    mutate(v)           #Change to Float64
    if v.isa[Float64](): print(v.get[Float64]()[]) #prints 1.0

def mutate(inout arg: MyObject):
    arg.set[Float64](1.0)
```

&nbsp;

---

### Hope that small tutorial was helpful and enjoyable.


### Happy coding with ```Variant```!

&nbsp;


#### *👍 Please consider contributing ideas, corrections, discussions, suggestions ❤️‍🔥*