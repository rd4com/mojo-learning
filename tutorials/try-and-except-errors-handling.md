# [Try & Except: ✋->⚠️->⛑️->🩹->👍 ]()
> with v0.4.0

There are explanations further down the page,

This example accompany those:

```python
from random import random_float64,seed
alias flip_a_coin = random_float64
alias tail = 0.5

def say_three():
    raise Error("⚠️ no time to say three")

fn count_to_5() raises:
    print("count_to_5: one")
    print("count_to_5: two")
    try:
        say_three()
    except e:
        print("\t count_to_5: error",e)
        
        if flip_a_coin()>tail:
            raise Error("⚠️ we stopped at three")
        else:
            print("count_to_5: three ⛑️")
    
    print("count_to_5: four")
    print("count_to_5: five")


fn main() raises:
    seed()
    
    try:
        count_to_5()
    except e:
        print("error inside main(): ",e)
        #main: error e
        if e.__repr__() == "⚠️ we stopped at three":
            print("main: three ⛑️")
            print("main: four ⛑️")
            print("main: five ⛑️")

    print("✅ main function: all good")
```
In order to illustrate Except and Try, 

The code will randomely produce one of those two scenarios:
#### Fix the error from count_to_5:

    count_to_5: one
    count_to_5: two
            count_to_5: error ⚠️ no time to say three
    count_to_5: three ⛑️
    count_to_5: four
    count_to_5: five
    ✅ main function: all good

#### Fix the error from main:

    count_to_5: one
    count_to_5: two
            count_to_5: error ⚠️ no time to say three
    error inside main():  ⚠️ we stopped at three
    main: three ⛑️
    main: four ⛑️
    main: five ⛑️
    ✅ main function: all good

# More

#### Raising
- ```def()``` functions can call raising functions and can raise by default
-  ```fn() raises``` is necessary in order to raise
- ```fn()``` cannot call functions that might raise, for example: a def function that raises by default

#### Try:
Inside the try block, we can call functions that could raise and error. It is also possible to Raise an error.

If and error is thrown, the execution continue at the beginning of the Except: block just below

#### Except e:
Here it is possible to inspect the error e, based on that, we can fix it.

If fixed, the the execution continue on the first line after the except block.

If it is not possible to fix it, it is possible to Raise an error: either the same or another.

The error will be transferred to the next Except: block. (see example)
