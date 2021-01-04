## Intro

This site is built with [Hugo](https://gohugo.io/). 

### Install hugo

```bash
yay -S hugo
```

### Init this repo

```
git submodule sync
git submodule update --init
```

### Deploy site

Site is hosted on GitHub pages. Site files are located in gh-pages branch of this repo.

To deployed updated site, run:

```
hugo -D
./deploy.sh
```