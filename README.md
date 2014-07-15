## Reprise

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
  `{:reprise, "~> 0.2.1", only: :dev}`

- add to apps:
    ```Elixir
    def application do
      dep_apps = [your_apps] 
      if Mix.env == :dev, do: dep_apps = [:reprise | dep_apps]
      [ applications: dep_apps ]
    end
    ```

Then your modules will be reinjected into your node - iex session
for instance - with a nice log report, each time you recompile them.

The default interval between scans for changed modules is 1 second.
You can check it and set a new one - the unit is milliseconds:
```Elixir
iex(1)> Reprise.Server.interval
1000
iex(2)> Reprise.Server.interval(2000)
{:ok, [prev: 1000]}
```

#### Loading a module for the first time

Please note that until Elixir [bug #2553](https://github.com/elixir-lang/elixir/issues/2533)
is fixed, you need to manually load modules for the first time into iex.
This is because your application has wrong bytecode signatures at start,
they point to the source files not the beams.

Just do: `l MyModule` in iex, then your stuff will be reloaded.

### License

The code is released under the BSD 2-Clause License.

