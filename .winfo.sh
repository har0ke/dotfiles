
default_limit=25
limited_folders="\
    $HOME \
    $HOME/Pictures \
    $HOME/Music \
    $HOME/Documents \
    $HOME/Desktop|0 \
    $HOME/Videos \
    $HOME/Downloads|40"

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
    let n="($(ls -l "$folder" | wc -l) - 1)"
    if [[ "$n" -gt $limit ]]; then
        warnings="$warnings\tMany files ($n > $limit) in '$folder'\n"
    fi
done

print_warnings "Folders to clean" "$warnings"
warnings=""

for d in ~/projects/*; do
    if [[ -e "$d/.git" ]]; then
        if [ ! -z "$(git -C "$d" status --porcelain)" ]; then
            warnings="$warnings\t$d has uncommited changes clean\n"
        else
            if [ ! -z "$(git -C "$d" log  --branches --not --remotes)" ]; then
                warnings="$warnings\t$d has not yet pushed commits\n"
            else
                let days="($(date +%s) - $(date +%s -d $(git -C "$d" log -n 1 --format=%aI))) / 3600 / 24"
                if [[ "$days" -gt "31" ]]; then
                    warnings="$warnings\t$d hasn't seen a commit in $days days\n"
                fi
            fi
        fi
    else
        warnings="$warnings\t$d is not a git repository\n"
    fi
done

print_warnings "Folders to clean" "$warnings"
warnings=""


