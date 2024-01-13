# 🏚️🏗️🏠 Moving ```owned``` values 

> Updated up to [Changelog v0.6.1 (2023-12-18)](https://docs.modular.com/mojo/changelog.html#v0.6.1-2023-12-18)

⚠️ The small tutorial could contains errors, see documentation on the website and repo of mojo!


&nbsp;

### 🟢 Introduction, then an example with many comments and colors 🎨!

```owned``` and ```inout``` are different:

If the value passed is **not** owned, it is **not** possible to delete it🗑️,

```MyType.__del__(owned self)``` require the argument passed as owned.

If a value is passed as ```inout```, it is possible to assign it a new value ✍:

```MyType.__init__(inout self)```.

This is great because the function can modify it, so it is named a mutable reference.

Additionally, the function could not free it, wich makes it safer🛡️. 

Like ```🗑️del```, owned arguments are require to ```🏗️move values```: 
- ```__del__(owned self)```
- ```__moveinit__(inout self,owned other:Self)```

Once the value got passed```^``` as owned to a function, we can't use it anymore !

Unless the function returns it back or store it somewhere.



```python
struct MyType:
    var value:Int
    fn __init__(inout self, v:Int): self.value = v
    fn __moveinit__(inout self, owned other: Self): #🏗️
        self.value = other.value

var BackupValue:MyType = 0

fn MoveIn(owned v:MyType):
    print(v.value)
    v.value = 123456
    BackupValue = v^
    
fn main():
    BackupValue = 0
    var a:MyType = 123
    MoveIn(a^)
    #print(a.value) # use of uninitialized value 'a'
    print(BackupValue.value) #✅ 123456
```
*(Note that global variables need to be initialized)*

>⚠️ If the type also implement ```copyinit``` , owned instances of a copy could be passed!

&nbsp;

### Here is a small example

```python
@value #⚠️ Synthesise also __copyinit__
struct StackOfBricks:
    var amount:Int
    fn __moveinit__(inout self,owned other:Self):
        self.amount = other.amount
```

```python
struct Home(Movable):
    var bricks:Int #🧱

    #🏚️👷🧱
    fn __init__(inout self, initialamount:Int=0):
            self.bricks = initialamount
    
    #🏠🏗️🏚️ Move bricks in
    fn __moveinit__(inout self,owned other:Self): #A_self=B_other^
        self.bricks = other.bricks

    #🏚️🏗️🏠 Move bricks out
    fn MoveTo(owned self,inout other:Self):
        other = self^ #Home.__moveinit__(other,self^)

    #🏠🏗️📈🏗️❔
    fn AddOneBrick(owned self)->Self:
        self.bricks+=1   #ex: var A = Home.increment(A^)
                        #ex: var B = A^.increment()
        return self^

    #🏠🏗️📈🏗️❔
    fn AddOneBrickFromStackOfBricks(owned self,inout s:StackOfBricks)->Self:
        if s.amount > 0:
            s.amount-=1             #ex: var x:Int = 10
            self.bricks+=1   #ex: var A = Home.increment(A^,x)
        return self^
    
    fn AddAllBricksFromStackOfBricks(inout self,owned other:StackOfBricks):
        self.bricks += other.amount
        # other is not used after, automatically __del__() here.

        #_ = other^ # manually
        #similar to: StackOfBricks.__del__(other^) manually

    fn AddBricksFrom(inout self,inout other:Self,amount: Int):
        if amount<= other.bricks:
            self.bricks+=amount
            other.bricks -= amount

    #🏠🏗️🗑️
    fn __del__(owned self): #Home.__del__(A^)
        #ex: self.somepointer.free()
        ...  

```
```python
#🏠🏗️📈🏗️❔    
fn AddBrick(owned arg:Home)->Home:
    arg.bricks+=1
    return arg^ #➡️🏗️

fn main():
    var location_a = Home(initialamount=10) #🟦
    var location_b = Home(initialamount=0)  #🟨

    print(location_a.bricks)  #🟦1️⃣0️⃣
    print(location_b.bricks)  #🟨0️⃣

    location_b = location_a^  #🟦➡️🏗️🟨
    print(location_b.bricks)  #🟨1️⃣0️⃣
    #print(location_a.bricks) #🟦❌✋ use of uninitialized value 'location_a'
                              
                              #🟨🏠   #1️⃣0️⃣
                              #🟦🏚️   #__del__() been called on it

    location_b = AddBrick(location_b^)  #🟨🏗️📈🏗️🟨
    print(location_b.bricks)  #🟨1️⃣1️⃣


    location_a = Home(0)              #🟦0️⃣
    var BrickStack = StackOfBricks(4) #🧱4️⃣
    
    #Bricks stack argument is inout:
    location_a = location_a^.AddOneBrickFromStackOfBricks(BrickStack)
    print(location_a.bricks)        #🟦1️⃣
    print(BrickStack.amount)        #🧱3️⃣
    
    #Bricks stack argument is owned:
    location_a.AddAllBricksFromStackOfBricks(BrickStack^)
    print(location_a.bricks)        #🟦4️⃣
    #print(BrickStack.amount)       #🧱❌✋ use of uninitialized value 'BrickStack'


    location_a^.MoveTo(location_b)  #🟦➡️🏗️🟨
    print(location_b.bricks)        #🟨4️⃣
    #print(location_a.bricks)       #🟦❌✋
    
    location_a = Home(0)     #🟦0️⃣
    location_b = Home(10)    #🟨1️⃣0️⃣
    
    #location a and b are inout argument:
    location_a.AddBricksFrom(location_b,5)
    location_a.AddBricksFrom(location_b,1)
    
    #inout arguments are not moved, only owned ones
    print(location_a.bricks) #🟦6️⃣
    print(location_b.bricks) #🟨4️⃣
    
    location_b.AddBricksFrom(location_a,6)
    print(location_a.bricks) #🟦0️⃣
    print(location_b.bricks) #🟨1️⃣0️⃣

    var BrickStackOne = StackOfBricks(30)#🧱🔵3️⃣0️⃣
    var BrickStackTwo = StackOfBricks(20)#🧱🟡2️⃣0️⃣
    var BigStackOfBrick = JoinBrickStacks(BrickStackOne^,BrickStackTwo^)
    print(BigStackOfBrick.amount)        #🧱🟢5️⃣0️⃣
    
    #print(BrickStackOne.amount)          #🧱🔵❌✋
    #print(BrickStackTwo.amount)          #🧱🟡❌✋
    
    _ = BigStackOfBrick # ⚠️ will not delete it
                        # @value generate __copyinit()__
                        # so it will delete a copy

    # Successful with the ^ suffix
    BigStackOfBrick^.__del__() 
    #similar to:
    #   _ = BigStackOfBrick^
    #   StackOfBricks.__del__(BigStackOfBrick^)           
    #print(BigStackOfBrick.amount)        #🧱🟢❌✋
    
    #The ^suffix allow to treat the value as owned! 

    # 🏗️ Movable trait (see 🔸function below):

    var Val_C = StackOfBricks(10)
    var Val_D = StackOfBricks(0)
    MoveTo(Val_C^,Val_D)

    #StackOfBricks also implement __moveinit__() (@value also make it!)

    Val_C = StackOfBricks(10)
    #T is passed explicitely, but mojo can deduce it(see above)
    MoveTo[StackOfBricks](Val_C^,Val_D)

#🔸
fn MoveTo[T:Movable](owned a:T,inout b:T):
    #The Movable trait means the type passed implement __moveinit__()
    #similar to: T.__moveinit__(b,a^)
    b=a^

fn JoinBrickStacks(owned a:StackOfBricks, owned b:StackOfBricks) -> StackOfBricks:
    var total = a.amount + b.amount
    return StackOfBricks(total)
```

### 🎉 That is how to move```^``` owned values!

&nbsp;

> ⚠️ *Could contains errors, make sure to see mojo repo or documentation website for better materials*

### Thanks to contributors, hope it is helpfull ❤️‍🔥