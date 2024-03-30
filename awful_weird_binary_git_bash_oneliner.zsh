# clean up repo to HEAD state
# WARNING: THIS WILL DELETE ALL UNTRACKED FILES IN YOUR GIT REPO!!!!!
#  git clean -fxd
# 
echo "$(find . -type f ! -size 0 ! -path './.git*' -exec grep -IL . "{}" \;)" | sed -e "s/^\.\///g" | while read line; do echo ">>>>>>>>$line"; echo "$(git log --follow --find-renames=40% --pretty=format:"%ad%x0A%h%x0A%an%x20<%ae>%x0A%s" -- $line | tail -n 4)"; echo "========"; binwalk -BAMre $line; echo "<<<<<<<<"; done | less
