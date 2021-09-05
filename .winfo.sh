
default_limit=40
limited_folders="\
    $HOME \
    $HOME/Downloads|60"

max_entries=""

print_warnings() {
    headline=$1
    warnings=$2
    if [[ "$warnings" != "" ]]; then
        echo -e "\033[0;33m$headline:"
        echo -e "$warnings\033[0m"
    fi

}

warnings=""
for folder in $limited_folders; do
    limit="$default_limit"
    if [[ "$folder" =~ "|" ]]; then
        limit="$(echo "$folder" | cut -d '|' -f2)"
        folder="$(echo "$folder" | cut -d '|' -f1)"
    fi
    n=$(ls -l "$folder" | wc -l)
    if [[ "$n" -gt $limit ]]; then
        warnings="$warnings\tMany files ($n > $limit) in '$folder'\n"
    fi
done

print_warnings "Folders to clean" "$warnings"
warnings=""

for d in ~/projects/*; do
    if [[ -e "$d/.git" ]]; then
        if [ ! -z "git -C "$d" status --porcelain)" ]; then
            warnings="$warnings\t$d is not clean\n"
        else
            let days="($(date +%s) - $(date +%s -d $(git log HEAD^..HEAD --format=%aI))) / 3600 / 24"
            if [[ "$days" -gt "31" ]]; then
                warnings="$warnings\tNo commits in $days days for $d"
            fi
        fi
    else
        warnings="$warnings\t$d is not a git repository\n"
    fi
done

print_warnings "Folders to clean" "$warnings"
warnings=""


