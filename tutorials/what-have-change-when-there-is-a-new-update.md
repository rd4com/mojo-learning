# 📫 find out changes and improvements when there is a new update

When there is a new update, a new changelog is available.

The changelogs are availables for us [here](https://docs.modular.com/mojo/changelog.html)

## What is a changelog
It is an entry that describe the changes made, new features and bug fixed of an update.

## How are they usefull

Provides a clear listing of new features that are now availables.

They also helps to maintain existing code by adapting to changes.

## Practical example

Lets understand how usefull it is by partially analysing a real changelog.

### [v0.5.0 (2023-11-2)](https://docs.modular.com/mojo/changelog.html#v0.5.0-2023-11-2)
From a glance, we can see that SIMD got a new function:
-  ```join()``` : allows concatenating two SIMD values

More features:
-  Tensor has new ```fromfile()``` and ```tofile()``` methods to save and load as bytes from a file.
-  Mojo now supports compile-time keyword parameters
   -  ```fn foo[a: Int, b: Int = 42]()```
-  Keyword parameters are also supported in structs
- The parameters for InlinedFixedVector have been switched. 
  - It now looks more like SIMD, let's make changes to existing codes to reflect the improvement, another benetits of changelogs.
-  The [benchmark](https://docs.modular.com/mojo/stdlib/benchmark/benchmark.html) module has been simplified and improved 
- ...more exciting features

A section is dedicated to list features that have been removed if any.

### ✅ Fixed section
That sections show all the bug reports made on the [github repository of mojo](https://github.com/modularml/mojo/issues) that have been fixed in that update.

Users can also create new bug reports if needed on that link.

The repository is also a place to create a feature request.


---

> People also usually discuss the changes on the [Discord channel](https://www.discord.gg/modular)

> There are also live Q/A, demonstrations and blog posts by mojo/modular team

