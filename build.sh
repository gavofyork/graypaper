set -e
xelatex -halt-on-error graypaper
biber graypaper
xelatex -halt-on-error graypaper
xelatex -halt-on-error graypaper
cp ./graypaper.pdf /data-ext/graypayper-dev.pdf
