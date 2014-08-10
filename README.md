# Reprise
[![Build Status](https://travis-ci.org/herenowcoder/reprise.svg?branch=master)](https://travis-ci.org/herenowcoder/reprise)

A simplified module reloader for Elixir.

It differs from its predecessors ([exreloader][1], mochiweb reloader)
in a way that it scans only beam files of the current mix project
and the current env.

[1]: http://github.com/yrashk/exreloader

### Usage

Reprise is best used on dev environment, that's usually where
you need reloading of modules. Here goes an example on how
to do this:

- add to deps: 
  `{:reprise, "~> 0.2.5", only: :dev}`

- add to apps:
    ```Elixir
    def application do
      dev_apps = Mix.env == :dev && [:reprise] || []
      [ applications: dev_apps ++ your_apps ]
    end
    ```

Then your modules will be reinjected into your node - iex session
for instance - with a nice log report, each time you recompile them.
Here's an example how it looks like:
```
iex> 12:14:59.163 [info] Reloaded modules: [Rockside.HTML.DSL, Rockside]
```

The default interval between scans for changed modules is 1 second.
You can check it and set a new one - the unit is milliseconds:
```Elixir
iex(1)> Reprise.Server.interval
1000
iex(2)> Reprise.Server.interval(2000)
{:ok, [prev: 1000]}
```

#### Loading a module for the first time

Please note that in some cases
you need to manually load modules for the first time into iex.
On Elixir versions before 0.15.0 the beams may have the wrong file
signature, pointing to the source file. This was fixed in 0.15.1,
but still your module can have :in_memory information instead of
the corresponding beam file.
The topic is discussed [here][beambug].

tl;dr: if your module doesn't show up as reloaded in iex,
just do once: `l MyModule`, then it'll be reloaded on successive changes.

[beambug]: https://github.com/elixir-lang/elixir/issues/2533

### License

The code is released under the BSD 2-Clause License.

