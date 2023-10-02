#usage ./submit.sh "{commit message}"
git add .
git commit -m "$1"
git push -u origin main
# compiled it into web version
hugo --destination compiled_jojo_notes
git add .
git commit -m '$1 compiled'
git push -u origin main