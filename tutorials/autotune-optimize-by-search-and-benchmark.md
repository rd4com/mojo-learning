# 🔮 Autotune: optimization made easy
> with 0.4.0
#### ⚠️ untested code, there might be bugs

### how it determine the optimal choice
By passing an evaluator function.

That function will determine if a choice is better or not.

It is needed because someone might want to optimise for ram usage instead of speed for example, or for another array size.

In that example, we are optimizing for speed, and will measure it using ```now()``` from time package.

```python
from autotune import autotune, search

#let's grab it to demonstrate the autotune
from algorithm import vectorize

#to determine the maximum value of an integer
from math.limit import max_finite

#to perform benchmarks (mojo also does provide a benchmark function if needed)
from time import now

#the signature of the function to optimize
#(the_function_implementation)
alias how_function_look_like = fn()->Int

#use another type by making one modification here
alias type_to_use = DType.int8
alias simd_width_of_type = simdwidthof[type_to_use]()

#optimize for 256 elements
alias total_elements = 2**8

#marked with adaptive
@adaptive
fn the_function_implementation()->Int:
    
    # use autotune: all potential values of width to test
    alias width_to_use = autotune(1, 2, 4, 8, 16, 32, 64 , 128)
    
    #allocate total_elements of type_to_use
    var elements = DTypePointer[type_to_use].alloc(total_elements)

    @parameter
    fn vectorization[group_size:Int](base_index:Int):
        var numbers = elements.simd_load[group_size](base_index)
        #simd squaring of group_size elements * group_size elements
        numbers = numbers * numbers
        elements.simd_store[group_size](base_index,numbers)
    
    #note the usage of width_to_use
    #autotune help to determine the optimal value of it
    vectorize[width_to_use,vectorization](total_elements)
    
    #deallocate
    elements.free()

    #just for printing later
    return width_to_use

#the function that gonna help determine what is the optimal choice
fn the_performance_evaluator(funcs: Pointer[how_function_look_like], total_candidates: Int) -> Int:

    #set the best performance(time spent) to the highest value
    var best_performance:Int = max_finite[DType.int64]().__int__()
    var best_candidate = 0
    
    print("start searching for best candidate")
    
    #loop over all candidate functions
    for candidate_number in range(total_candidates):
        #get the candidate function
        let candidate_function = funcs.load(candidate_number)
        var width_used = 0
        
        let start = now()
        
        #run the function 100000 times
        for i in range(100000):
            width_used = candidate_function()
        
        let time_it_took = now()-start

        #if it is better, store the index of the candidate
        if time_it_took<best_performance:
            #here check if the width is not too big
            #because we check for unusable values too in autotune() above
            #the reason is to be able to test different types
            if width_used <= simd_width_of_type:
                best_candidate = candidate_number
                best_performance = time_it_took
        
        #this is the width_to_use used in that benchmark:
        print("\t width used:",width_used)
        #how much time to run 100000 times the function
        print("\t\t benchmark: ",time_it_took)
    
    print("search is done")
    #return the index of the optimal candidate function
    return best_candidate

fn main():

    #will store the optimal function based on the benchmark
    alias most_performant_implementation: how_function_look_like

    #run the performance evaluator to determine most_performant_implementation
    search[
        how_function_look_like,
        VariadicList(the_function_implementation.__adaptive_set),
        the_performance_evaluator -> most_performant_implementation
    ]()

    print("")
    print("let's use the optimal function:")
    
    # call the best implementation
    let width_used = most_performant_implementation()
    
    print("\tbest implementation simdwidth is",width_used)
    
    #what is the actual maximal width of that type
    print("")
    print("max simdwidth of type_to_use is",simd_width_of_type)
```
## output:
```
start searching for best candidate
         width used: 1
                 benchmark:  12326435
         width used: 2
                 benchmark:  15592902
         width used: 4
                 benchmark:  6721930
         width used: 8
                 benchmark:  3742553
         width used: 16
                 benchmark:  3113805
         width used: 32
                 benchmark:  2480954
         width used: 64
                 benchmark:  2342148
         width used: 128
                 benchmark:  2249421
search is done

let's use the optimal function:
        best implementation simdwidth is 32

max simdwidth of type_to_use is 32
```
##### *this page is a community effort and may contains errors. please contribute any corrections if needed.*
For better examples, the official mojo website is the place to go:
- see how [Matmul](https://docs.modular.com/mojo/notebooks/Matmul.html) determine the perfect tile size.