

# 📖 Learning mojo language
###  ⚠️  not affiliated with Modular or Mojo
&nbsp; 

### [🔍 Why](/why.md) 
### [🔦 Introduction](/introduction.md)
### [🫵 corrections and contributions](contribute.md) 
&nbsp; 

# [🔁 Python land and mojo land, PythonObject](tutorials/python-world-mojo-world.md) 
note: need revision for better accessibility


# [🛣️ 🚌 multi-core (parallelize) with simd](tutorials/multi-core-parallelize-with-simd%20.md) 
simd and parallelize.

# [🪄 calling mojo functions from python ](tutorials/calling-mojo-functions-in-python.md)
using pointers an ctype

# [🐍 using python in mojo: a to z](tutorials/using-python-in-mojo.md)
first steps and dancing

# [🏚️🏗️🏠 Moving owned values](tutorials/moving-owned-values.md) 

```__moveinit__``` ```__del__``` and many more !

# [📋 Traits: accept any types that comply to requirements](tutorials/traits.md)
accept types based on some requirements

# [SIMD: 🔢✖️2️⃣🟰❪2️⃣,4️⃣,6️⃣,8️⃣❫](tutorials/simd.md)
perform an operation on multiple numbers

# [👜 Variant, a type that can hold values of different types](./tutorials/variant.md)
The current type it holds can change and be checked

# [🐍🔍 type-checking a PythonObject](./tutorials/type-check-class-of-pythonobject.md)
For example, to iterate python arrays that might contains objects of various classes

# [🧬 Parameters, Alias, Struct parameter deduction, more](tutorials/parameters-alias-struct-parameter-deduction.md)
Parameterize! (compile time meta-programming) 

# [🪄🔮 Autotuned parametrized tests](tutorials/autotuned-parametrized-tests.md)
Testing for multiple ```SIMD``` sizes

# [🔥 With blocks: with my_struct(1) as v](tutorials/with-blocks-for-struct-parametric-minimal-raise.md)
with blocks from struct (parametric/minimal/raise)

# [🏃 (SPEED) Parametric struct through CPU registers](tutorials/parametric-struct-trough-cpu-registers.md)
the @register_passable decorator

# [🏞️ getattr: dynamic and static struct members](tutorials/getattr-dynamic-and-static-struct-members.md)
the_instance.method_not_defined() handled

# [🤹 making lists of structs with magic operators](tutorials/lists-of-structs-magic-operators-pre-lifetimes.md)
unsafe references abilities until lifetimes

# 🫙 [struct as a namespace (@staticmethod)](tutorials/struct-as-namespace.md)
example: wrap python functions

# [🏳️ make test builds using a custom flag](tutorials/make-test-builds-using-a-custom-flag.md)
mojo build program.mojo -D...

# [🕯️ reader.read\[Int32,"swap"\](3) in 45 lines](tutorials/reader-in-few-lines-with-endian-ness.md)
v0.4.0: powerfull magic 

# [🔮 Autotune: optimization made easy](tutorials/autotune-optimize-by-search-and-benchmark.md)
Easy to use


# [🔥 making compile time functions](tutorials/compile-time-functions.md)
Pointer[Int] of squared numbers

# [🧹 ASAP: will call ```__del__``` when last used](tutorials/memory-asap-and-destructor-behaviours.md)
when do del get called on instance

# [🏗️ moveinit 💿💿 copyinit 🐿️ non-destructing move](tutorials/moveinit-copyinit-takeinit.md)
implement in struct: copy of instance, move, taking move

# 🤙 [callbacks trough parameters](tutorials/callbacks-trough-parameters.md)
toy markdown generator as an example

# [🌊 256Hz: simd cosine and plot it](tutorials/vectorise-simd-cosine.md)
one cycle by vectorizing simd instructions, plot with python

# [🦜 env, argv and param_env (for alias)](tutorials/env-argv-param_env-for-parameters.md)
arguments: command-line, env, alias

# [⌨️ introduction to types](tutorials/introduction-to-types.md)
syntax and concepts: not complicated

# [Try & Except: ✋->⚠️->⛑️->🩹->👍 ](tutorials/try-and-except-errors-handling.md)
raise custom errors and recover (with example)

# [📫 find out changes and improvements when there is a new update](tutorials/what-have-change-when-there-is-a-new-update.md)
changelogs for new comers

