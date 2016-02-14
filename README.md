This is a tool for computing the individual and team results of a collegiate figure skating competition and publishing them to a website. This works by processing files in the `results` directory to generate `scores` files which contain a listing of all the points that each skater and team received. These `scores` files are further processed to generate `html` files that show the team results in a tabular format.

## OSX Usage
This only discusses blind usage, e.g., you're running a Collegiate Figure Skating competition and want to publish results to a website.

Open up a terminal and install homebrew with the following command:

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install git using homebrew. You can do this with the following command after homebrew is installed:

```
brew install git
```

Login to GitHub or [create a GitHub account](https://github.com/join?source=header-home)

Fork a copy of this repository by clicking "Fork" in the top right on using [this link](https://github.com/seldridge/ulysses#fork-destination-box)

Grab a local copy of your forked version of this repository. You will need to use your GitHub username, which I will indicate as `<USERNAME>`:

```
cd ~
git clone git@github.com:<USERNAME>/ulysses
```

Create a new results file in the `results` directory or edit `2016_02_competition.results`. The format for this is extremely strict but is documented in `2016_02_competition.results` and you will get warnings if you mess up the format.

From the top level directory, run `make` to generate `scores` and `html` files in the `build` directory. To publish these to the website `https://<USERNAME>.github.io/ulysses`, run `make publish`.
