# flu-type-a
Incubation of [fluent type for nix modules](https://github.com/NixOS/nixpkgs/pull/234990)

This project have two objectives:

1. Make the interface stable for that PR.
2. Create the documentation (**help wanted**).


**Summary**

Fluent options declaration function to make easier define new options.

**Motivation**

Inspired by Eelco Dolstra talk of NixCon 2020¹ and @DavHau pkgs-modules² project and my own user experince, I could say that modules are fun but define new options aren't. And maybe is the reason for some `extraOptions`, lack of typing in NixOS Modules³.

**Detailed design**

Define a new fluent interface for options definition where no function call is required for most common cases (type, listOf, attrsOf, options).

The logic is:
- if it has `attrsOf`, is attrOf
```nix
lib.types.fluent {
  options.FOO.attrsOf  = types.str;
} == {
  options.FOO.type     = types.attrsOf types.str;
}
```
- if it has `enum`, is enum
```nix
lib.types.fluent {
  options.FOO.enum  = [ "foo" "bar" ];
} == {
  options.FOO.type  = types.enum [ "foo" "bar" ];
}
```
- if it has `listOf`, is listOf
 ```nix
lib.types.fluent {
  options.BAR.listOf    = types.str;
} == {
  options.BAR.type      = types.listOf types.str;
}
```
- if it has `oneOf`, is oneOf
```nix
lib.types.fluent {
  options.FOO.oneOf  = [ types.str types.int];
} == {
  options.FOO.type  = types.oneOf [ types.str types.int ];
}
```
- if it has `options`, is a submodule: 
```nix
lib.types.fluent {
  options.EGGS.options.SPAM.type = types.str;
} == {
  options.EGGS.SPAM.type         = types.str;
} == {
  options.EGGS.type = submodule { options.SPAM.type = types.str; };
}
```
- or else `type` is required
```nix
lib.types.fluent {
  options.TICO-TICO.type        = types.str;
} == {
  options.TICO-TICO.type        = types.str;
}
```

Create a helper function that translates this new (experimental) interface so no initial retro compatibility problem (except function not available) is created.

It looks not so different unless we add some nested example like options of attrs of options of list of string
```nix
lib.types.fluent {
  options.FOO.attrsOf.options.BAR.listOf        = types.str;
} == {
  options.FOO.type = types.attrsOf ( types.submodule { options.BAR.type = types.listOf types.str; } );
}
```


**Example**:
This code (current way)

```nix
{ lib, ...}:
let
  Node = lib.types.submodule {
    options.tags = lib.mkOption {
      type        = lib.types.listOf lib.types.str;
      example     = ["logstash"];
      default     = [];
      description = "Define the tags of this node in the project cluster";
    };
  };
  env = lib.mkOption {
    type        = lib.types.attrsOf Node;
    default     = {};
    example     = { logstash01 = { tags = ["logstash"]; }; };
    description = "nodes of this environment";
  };

  Project = lib.types.submodule {
    options.git  = lib.mkOption {
      default     = "";
      type        = lib.types.str;
      example     = "https://github.com/DavHau";
      description = "git project url";
    };
    options.desc = lib.mkOption {
      default     = "";
      type        = lib.types.str;
      example     = "Elastic stack config files";
      description = "Description of the project";
    };
    options.docs = lib.mkOption {
      default     = "";
      type        = lib.types.str;
      example     = "https://google.com";
      description = "url of main documentations";
    };
    options.dev = env;
    options.prd = env;
  };
in
{
  options.project = lib.mkOption {
    type        = lib.types.attrsOf Project;
    default     = {};
    example     = { elk.desc = "elastic stack"; elk.dev.logstash01.tags = ["logstash"]; };
    description = "Information about our git projects";
  };
}
```

After proposed solution could be like this:

```nix
{lib, ...}:
let
  env.default      = {};
  env.example      = { logstash01 = { tags = ["logstash"]; }; };
  env.description  = "nodes of this environment";
  env.attrsOf.options.tags.listOf      = lib.types.str;
  env.attrsOf.options.tags.example     = ["logstash"];
  env.attrsOf.options.tags.default     = [];
  env.attrsOf.options.tags.description = "Define the tags of this node in the project cluster";
in
lib.types.fluent {
  options.project.default     = {};
  options.project.example     = { elk.desc = "elastic stack"; elk.dev.logstash01.tags = ["logstash"]; };
  options.project.description = "Information about our git projects";
  options.project.attrsOf.options = {
    git.default      = "";
    git.type         = lib.types.str;
    git.example      = "https://github.com/DavHau/pkgs-modules";
    git.description  = "git project url";
    desc.default     = "";
    desc.type        = lib.types.str;
    desc.example     = "Elastic stack config files";
    desc.description = "Description of the project";
    docs.default     = "";
    docs.type        = lib.types.str;
    docs.example     = "https://google.com";
    docs.description = "url of main documentations";
    dev = env;
    prd = env;
  };
}
```

**Drawbacks**

"I think the module system already has too much syntax sugar. Every time you add syntax sugar, you introduce at least one corner case." - @roberth

"Furthermore, you obfuscate the original data model. You might flatten the very start of the learning curve, but a newcomer will have learned the wrong thing, and still needs to learn the original syntax before they become proficient." - @roberth

**Alternatives**

- Implement a [nickel-nix](https://github.com/nickel-lang/nickel-nix) modules translator.
- ~~Create a stand alone project to mature the idea and documentation~~ (this project )

**Future work**

~~Should we have other types like `oneOf`, `nullOr`~~

We did it in another [PR](https://github.com/cruel-intentions/nixpkgs/pull/2), this branch is copied here.

This also means we have mdDoc alias:

```nix
lib.types.fluent {
  options.BAR.type  = types.str;
  options.BAR.mdDoc = "Markdown description";
} == {
  options.BAR.type  = types.str;
  options.BAR.description = lib.mdDoc "Markdown description";
}
```

And type inference based on default value:

```nix
lib.types.fluent {
  options.BOO.default = true;                             # bool
  options.FLT.default = 0.0;                              # float
  options.INT.default = 0;                                # int
  options.PTH.default = ./.;                              # path
  options.STR.default = "TYP-STR";                        # str
  options.LST.default = [ "TYP-LST" ];                    # list of anything
  options.NUL.default = null;                             # null or anything
  options.ATT.default = {};                               # attr of anything
  options.PKG.default = (import <nixpkgs> {}).emptyFile;  # package
} == {
  options.ATT.default = {};
  options.ATT.type    = types.attrOf types.anything
  options.BOO.default = true;
  options.BOO.type    = types.bool
  options.FLT.default = 0.0;
  options.FLT.type    = types.bool;
  options.INT.default = 0;
  options.INT.type    = types.int;
  options.LST.default = [ "LST" ];
  options.LST.type    = types.listOf types.anything;
  options.NUL.default = null;
  options.NUL.type    = types.nullOr types.anything;
  options.PKG.default = (import <nixpkgs> {}).emptyFile;
  options.PKG.type    = types.package;
  options.PTH.default = ./.;
  options.PTH.type    = types.path;
  options.STR.default = "TYP-STR";
  options.STR.type    = types.str;
}
```


**TODO**:

- [X] Configure tests
- [ ] Documentation
- [ ] Format code



¹. https://www.youtube.com/watch?v=dTd499Y31ig

². https://github.com/DavHau/pkgs-modules/issues/1

³. https://discourse.nixos.org/t/nixpkgs-nixos-is-an-expert-system-database/671/7

ª. https://www.cdc.gov/flu/symptoms/flu-vs-covid19.htm

