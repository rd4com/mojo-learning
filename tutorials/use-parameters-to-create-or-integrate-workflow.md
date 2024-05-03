 # 🟢 Let's ```mojo build -D your="own" version=1 app.🔥``` with ``` 🛡️Constrained```


You gonna learn how to parametrize your app, starting from the ```🔨 mojo build``` command ⬅️🟤🟣🔵.

We then will pass thoses input parameters to the 🟤🟣🔵➡️```🛡️constrained``` function.

This will allow us to validate our inputs during the building process.



If our inputs are validated (thus not tell mojo to stop building),

we will parametrize an if statement with one of the inputs 🔵🔀,

it will tell mojo-build if it should use main_1 or main_2!

Once the program has been ✅ built, we can start it ▶️!

Let's start parametrizing!

&nbsp;

# 🌴🧋 ```my_app.mojo``` 🧉🌴

```python
from sys.param_env import env_get_int, env_get_string
from sys.param_env import is_defined

fn main():
    alias app_version = 
        env_get_int["app_version"]() # ⬅️🟤

    constrained[ # 🛡️
        app_version > 0,
        "app_version cannot be 0 or below"
    ]()

    constrained[ # 🛡️
        app_version < 100,
        "Version 99 is the maximum !"
    ]()

    alias app_name = 
        env_get_string["app_name"]() # ⬅️🟣
    
    constrained[ # 🛡️
        len(app_name)<32,
        "The app name cannot be > 31 ! "
    ]()

    constrained[ # 🛡️
        len(app_name)>0,
        "The app name is too small"
    ]()

    alias app_use_simd:Bool = is_defined["app_use_simd"]() # ⬅️🔵

    print("Welcome to", str(app_name))
    print("the version is", str(app_version))
    print("simd:", str(app_use_simd))

    @parameter
    if app_use_simd:       # 🔵🔀 what should mojo build? 
        app_start_simd()     # 🔨❓   
    else:
        app_start_not_simd() # 🔨❓

fn app_start_simd():
    var values = SIMD[DType.uint8]()
    print("app started")

fn app_start_not_simd():
    var values = List[UInt8]()
    print("app started")
```
🔨```mojo build my_app.mojo -D app_name="Todo list" -D app_version=100 -D app_use_simd```⬅️🟤🟣🔵
> 🛡️ constraint failed: Version 99 is the maximum !

🔨```mojo build my_app.mojo -D app_name="Todo list" -D app_version=1 -D app_use_simd```⬅️🟤🟣🔵

> ✅ Built!

👍 my_app has been built from my_app.mojo

▶️```./my_app```
```
Welcome to Todo list
the version is  1
simd:  True
app started
```

&nbsp;

#### 💘 Excellent! You can now make your app and use ```🛡️constrained```!

> Make sure to read the mojo language [Documentation: manual](https://docs.modular.com/mojo/manual/)


&nbsp;

### 🎉 end of the small tutorial