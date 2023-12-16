# 🤙 callbacks trough parameters
```python
@value
struct markdown:
    var content: String

    fn __init__(inout self):
        self.content = ""

    def render_page[f: def()->object](self,file="none"):
        self.content = ""
        f()

    fn __ior__(inout self,t:String):
        self.content+=t

var md = markdown()

def readme():
    md |= '''
    # hello mojo
    this is markdown
    ```python
    fn main():
        print("ok")
    ```
    '''
    footer()

def footer():
    md |= '''
    > Page generated
    '''

def main():
    md = markdown()
    md.render_page[readme](file="README.md")
    print(md.content)
```

output:


# hello mojo
this is markdown
```python
fn main():
    print("ok")
```

> Page generated

