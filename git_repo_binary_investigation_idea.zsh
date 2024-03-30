# ruby's git repo investigation zsh one-liner-ish thingy
# (a starting point for investigating anomalous contributions in git repositories)

echo "$(find . -type f ! -size 0 ! -path './.git*' -exec grep -IL . "{}" \;)" | \
sed -e "s/^\.\///g" | \
while read line; \
do \
echo ">>>>>>>>$line"; \
echo "$(git log --follow --find-renames=40% --pretty=format:"%ad%x0A%h%x0A%an%x20<%ae>%x0A%s" -- "$line" | head -n 4)"; \
commitdates="$(git log --follow --find-renames=40% --pretty=format:"%ae" -- "$line" | head -n 1 | xargs -I {} git log --author={} --pretty=format:"%ad")"; \
echo "$(echo -n "$commitdates" | grep -c '^') commits authored by email (first commit on $(echo -n "$commitdates" | tail -n 1))"; \
echo "========binwalk"; \
binwalk --disasm --signature --opcodes --extract --matryoshka --depth=32 --rm $line; \
echo "^^^^^^^^strings"; \
echo "$(strings $line | grep -E "^.*([a-z]{3,}|[A-Z]{3,}|[A-Z][a-z]{2,}).*$" | sort | uniq -c | sort -nr | awk '{$1="";print}' | sed 's/^.//' | head -n 25)"; \
echo "<<<<<<<<"; \
done | less # or save it to a file with ">> output.txt", up to you!

# before/after running you might want to clean up the repo to HEAD state
# if there's untracked files (especially matroyshka extractions etc) the commit data might just be completely wrong 
# WARNING: THIS WILL DELETE ALL UNTRACKED FILES IN YOUR GIT REPO!!!!!
#  git clean -fxd
#
# what it does:
# - for each binary files in the current git HEAD
#   - prints the filenamename
#   - get the last commit changing it and prints commit sha, date, author name/email and commit msg
#   - does very crude stats about the authors contribution from that email (first date and number of commits - bear in mind this couuuuld be spoofed)
#   - prints binwalk output running in matroyshka extraction mode (it'll keep extracted nested archives etc...)
#   - print top 25 strings that look of interest (ABC, abc, Abc or longer words)
#   - pipe it to less or whatever you prefer
#
# caveats/warnings:
# - only tested on macos zsh with my local env
# - i dont remember which grep/git/posix utils etc i have
# - incredibly unoptimizied 
# - you will need at least binwalk, git, strings for this?
#
# revisions:
# - better instructions, clean up slightly and expand it over multiple lines (thank you Raven!)
# - add strings and committer stats
# - add sample output for easier sharing
# - added another sample output showing some of the benign files in the project containing an actual compressed ELF binary
#
# future ideas:
# - structured outputting (🥲)
# - automate running this on repositories that security critical software is dependent on (like sshd -> systemd -> xz)
# - use git(hub|lab) APIs to enhance the contributor information shown
# - cluster results by contributor 
# - time bound investigation (get recently changed files from git) and include non-binary but anomalous extensions
#
