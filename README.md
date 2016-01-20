# Reprise
[![Build Status](https://travis-ci.org/herenowcoder/reprise.svg?branch=master)](https://travis-ci.org/herenowcoder/reprise)
[![hex.pm version](https://img.shields.io/hexpm/v/reprise.svg)](https://hex.pm/packages/reprise)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/reprise.svg)](https://hex.pm/packages/reprise)
[![hex.pm downloads/week](https://img.shields.io/hexpm/dw/reprise.svg)](https://hex.pm/packages/reprise)
[![hex.pm license](https://img.shields.io/hexpm/l/reprise.svg)](https://github.com/herenowcoder/reprise/raw/master/LICENSE)

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
  `{:reprise, "~> 0.5, only: :dev}`

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

### License

The code is released under the BSD 2-Clause [License](https://raw.githubusercontent.com/herenowcoder/reprise/master/LICENSE).

