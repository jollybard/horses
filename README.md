# SUPER HORSE SIMULATOR 2000

This is a silly website I made in order to learn how to use [Yesod](yesodweb.com).

As of 2020-12-13, the website can be viewed [here](horses.jollybard.net).

Needless to say, since the website offers no filters or admin tools, I am not responsible for the horses created therein. Do contact me if there's anything illegal and I shall take it down.

## Haskell Setup

1. If you haven't already, [install Stack](https://haskell-lang.org/get-started)
	* On POSIX systems, this is usually `curl -sSL https://get.haskellstack.org/ | sh`
2. Install the `yesod` command line tool: `stack install yesod-bin --install-ghc`
3. Build libraries: `stack build`

If you have trouble, refer to the [Yesod Quickstart guide](https://www.yesodweb.com/page/quickstart) for additional detail.

## Development

Start a development server with:

```
stack exec -- yesod devel
```

As your code changes, your site will be automatically recompiled and redeployed to localhost.

## Tests

```
stack test --flag horses:library-only --flag horses:dev
```

(Because `yesod devel` passes the `library-only` and `dev` flags, matching those flags means you don't need to recompile between tests and development, and it disables optimization to speed up your test compile times).


